#!/usr/bin/env bash
# Synthesize one narration line to a silence-trimmed WAV via Orpheus on Melkor (OpenAI-compatible).
# Standard Nevermined demo voice = leah. Usage: tts.sh "<text>" <out.wav> [voice]
# Env overrides: ORPHEUS_URL, ORPHEUS_KEY. Clean the text first (no parens/version numbers; em-dash -> comma).
set -euo pipefail

TEXT="${1:?text}"; OUT="${2:?out.wav}"; VOICE="${3:-leah}"
URL="${ORPHEUS_URL:-http://melkor:4000/v1/audio/speech}"
KEY="${ORPHEUS_KEY:-sk-litellm-melkor}"
TMP="$(mktemp).wav"

code=$(curl -s -w "%{http_code}" --max-time 120 "$URL" \
  -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"orpheus-tts\",\"voice\":\"$VOICE\",\"input\":\"$TEXT\",\"response_format\":\"wav\"}" \
  --output "$TMP" || true)
if [ "$code" != "200" ]; then
  echo "Orpheus returned $code. If it's down, restart the stack on Melkor:" >&2
  echo "  ssh aitor@melkor 'bash ~/Projects/AI/orpheus-tts/scripts/start_orpheus_stack.sh'" >&2
  echo "  (post-reboot it can segfault at slot-init — see the orpheus-tts-melkor memory)." >&2
  rm -f "$TMP"; exit 1
fi
# trim leading/trailing silence so lines place tightly on the timeline
ffmpeg -v error -y -i "$TMP" -af \
  "silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.04,areverse,silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.04,areverse" \
  "$OUT"
rm -f "$TMP"
echo "wrote $OUT ($(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")s, voice=$VOICE)"
