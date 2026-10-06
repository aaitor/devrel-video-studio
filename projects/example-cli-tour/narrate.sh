#!/usr/bin/env bash
# Build the narrated audio for the multi-env cut (fixed beats): TTS each line, place them (narrate.py),
# generate the studio music bed, duck + master to -16 LUFS. Usage: narrate.sh [voice]
# Needs a TTS endpoint (see scripts/_env.sh). Then point index.html #bgm at narration-mix.mp3 and render.
set -euo pipefail
PROJ="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S="$(cd "$PROJ/../../.claude/skills/devrel-video/scripts" && pwd)"
VOICE="${1:-leah}"; TOTAL=27.2

echo "[narrate] TTS the lines in '$VOICE'"
mapfile -t LINES < <(python3 "$PROJ/narrate.py" --lines)
i=1; for line in "${LINES[@]}"; do "$S/tts.sh" "$line" "$PROJ/vo$i.wav" "$VOICE" >/dev/null; i=$((i + 1)); done

echo "[narrate] place voice + write captions"
( cd "$PROJ" && python3 narrate.py >/dev/null )

echo "[narrate] music bed + ducked mix"
python3 "$S/gen-bgm.py" "$PROJ/bgm.wav" "$TOTAL" >/dev/null   # default style (corporate); set BGM_STYLE to change
"$S/mix-audio.sh" "$PROJ/bgm.wav" "$PROJ/voice.wav" "$PROJ/narration-mix.mp3" >/dev/null
echo "[narrate] ✓ $PROJ/narration-mix.mp3"
