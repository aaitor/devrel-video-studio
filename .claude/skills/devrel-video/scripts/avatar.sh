#!/usr/bin/env bash
# avatar.sh — face-only talking-head from a plate + audio, via LatentSync on Melkor (AMD ROCm).
#
# Produces a SQUARE, muted, 30fps face crop (drop it into the #avatar seam; the circle is CSS
# border-radius:50%). The mouth is lip-synced to <audio> — feed it the exact narration segment
# the bubble should "say" (e.g. one line trimmed from narration-mix.mp3), so it matches what's heard.
#
# Usage:  avatar.sh <plate> <audio.wav> <out.mp4> [face_scale]
#   plate       local video, OR  melkor:/abs/path  (a plate already on Melkor, e.g. a demo clip)
#   audio.wav   the speech the mouth should say (>= plate is NOT required; plate must be >= audio)
#   out.mp4     local output path for the cropped face video
#   face_scale  square crop = face_height * this (default 2.0 → head + a little shoulder)
#
# The face is PINNED by per-frame face-tracking (track_crop.py) so a lively plate doesn't jitter
# in the small circle. Env overrides:  MELKOR (aitor@melkor)  LS_DIR (spike env, on Melkor)
#
# Recipe proven 2026-08-26 (see references/production-notes.md → Avatar):
#   RX 9060 XT is HIP device 1 (device 0 = Ryzen iGPU) → HIP_VISIBLE_DEVICES=1 is mandatory.
#   256 path (stage2.yaml) peaks ~14GB → free idle Ollama models first (Orpheus stays up).
set -euo pipefail

PLATE="${1:?plate}"; AUDIO="${2:?audio.wav}"; OUT="${3:?out.mp4}"; FACE_SCALE="${4:-2.0}"
STEPS="${STEPS:-20}"          # LatentSync diffusion steps; raise (e.g. 30) for a crisper mouth
MELKOR="${MELKOR:-aitor@melkor}"
LS_DIR="${LS_DIR:-\$HOME/Projects/AI/latentsync-spike/LatentSync}"   # \$HOME expands on Melkor
REMOTE="/tmp/devrel-avatar"
SSHO=(-o ConnectTimeout=120 -o ServerAliveInterval=15 -o ServerAliveCountMax=8 -o BatchMode=yes)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[avatar] staging inputs on Melkor…"
ssh "${SSHO[@]}" "$MELKOR" "mkdir -p $REMOTE"
if [[ "$PLATE" == melkor:* ]]; then
  RPLATE="${PLATE#melkor:}"
else
  RPLATE="$REMOTE/plate.mp4"; scp "${SSHO[@]}" "$PLATE" "$MELKOR:$RPLATE"
fi
scp "${SSHO[@]}" "$AUDIO" "$MELKOR:$REMOTE/audio.wav"
scp "${SSHO[@]}" "$SCRIPT_DIR/track_crop.py" "$MELKOR:$REMOTE/track_crop.py"

echo "[avatar] lip-sync + face-crop on Melkor (this is the slow GPU step, ~10 min cold)…"
# Ship the remote script as a FILE (scp is integrity-checked) instead of piping via 'ssh bash -s' <<EOF —
# on a flaky link that stream corrupts (we saw echo→cho and a dropped line-continuation → command not found).
REMOTE_SH="$(mktemp)"
cat > "$REMOTE_SH" <<'REMOTE_EOF'
set -euo pipefail
cd "$(eval echo "$LS_DIR")"
export HIP_VISIBLE_DEVICES=1 HF_HUB_DISABLE_TELEMETRY=1
export PYTORCH_ALLOC_CONF=expandable_segments:True PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

# free VRAM without touching Orpheus (Ollama models can reload on demand — stop them right before we grab VRAM)
for m in $(ollama ps 2>/dev/null | awk 'NR>1{print $1}'); do ollama stop "$m" >/dev/null 2>&1 || true; done
sleep 2

# LatentSync is a 25fps model (stage2.yaml video_fps:25; feature2chunks maps whisper at 25fps).
# A plate at any other fps makes the mouth drift against the audio → normalize to 25fps first.
ffmpeg -y -i "$RPLATE" -vf fps=25 -an -c:v libx264 -pix_fmt yuv420p -crf 18 "$REMOTE/plate25.mp4" >/dev/null 2>&1

./venv/bin/python -m scripts.inference \
  --unet_config_path configs/unet/stage2.yaml \
  --inference_ckpt_path checkpoints/latentsync_unet.pt \
  --inference_steps "$STEPS" --guidance_scale 1.5 \
  --video_path "$REMOTE/plate25.mp4" --audio_path "$REMOTE/audio.wav" \
  --video_out_path "$REMOTE/lipsynced.mp4" > "$REMOTE/run.log" 2>&1 \
  || { echo "LATENTSYNC FAILED:"; tail -15 "$REMOTE/run.log"; exit 1; }

# face-tracking crop: follow the face every frame so the head stays PINNED in the bubble (CPU-only)
./venv/bin/python "$REMOTE/track_crop.py" "$REMOTE/lipsynced.mp4" "$REMOTE/face_tracked.mp4" "$FACE_SCALE" \
  || { echo "TRACK_CROP FAILED"; exit 1; }
# finalize: 30fps + dense keyframes (HyperFrames seeks every frame) + faststart
ffmpeg -y -i "$REMOTE/face_tracked.mp4" -vf "fps=30" \
  -an -c:v libx264 -pix_fmt yuv420p -crf 18 \
  -g 30 -keyint_min 30 -sc_threshold 0 -movflags +faststart \
  "$REMOTE/avatar-face.mp4" >/dev/null 2>&1
echo "[avatar] done $(ls -lh "$REMOTE/avatar-face.mp4" | awk '{print $5}')"
REMOTE_EOF
scp "${SSHO[@]}" "$REMOTE_SH" "$MELKOR:$REMOTE/remote.sh"
rm -f "$REMOTE_SH"
ssh "${SSHO[@]}" "$MELKOR" "FACE_SCALE='$FACE_SCALE' STEPS='$STEPS' LS_DIR='$LS_DIR' REMOTE='$REMOTE' RPLATE='$RPLATE' bash '$REMOTE/remote.sh'"

echo "[avatar] pulling result back…"
scp "${SSHO[@]}" "$MELKOR:$REMOTE/avatar-face.mp4" "$OUT"
echo "[avatar] ✓ $OUT"
