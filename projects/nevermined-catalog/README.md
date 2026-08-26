# nevermined-catalog

The first worked example: a walkthrough of the Nevermined AI Services catalog —
title → browse → filter by category → inspect a service → CTA. Built entirely with the `/devrel-video`
pipeline. `renders/contact-sample.png` shows the beats. It ships **narrated** (Orpheus `leah` VO + ducked
music bed, ~31s) with English + Spanish subtitles; the silent+music cut is the same composition minus the
voice track.

## How it was made

```bash
# 1. brand (real tokens + logo)
.claude/skills/devrel-video/scripts/brand-extract.sh https://nevermined.app/catalog nevermined

# 2. capture (edit capture.js beats first)
.claude/skills/devrel-video/scripts/capture.sh projects/nevermined-catalog/capture.js https://nevermined.app/catalog

# 3. compose
HYPERFRAMES_SKIP_SKILLS=1 npx hyperframes init projects/nevermined-catalog --video capture.mp4 --skip-transcribe --non-interactive
#    → then replace index.html from templates/composition.html, filled from brief.yaml + brands/nevermined/tokens.json

# 4. music + narration (audio is gitignored — regenerate)
python3 .claude/skills/devrel-video/scripts/gen-bgm.py bgm.wav 30.99                 # music bed
.claude/skills/devrel-video/scripts/tts.sh "<line>" vo1.wav                          # one per beat (leah)
python3 templates/narrate.py                                                          # voice.wav + re-timed captions.*.srt
.claude/skills/devrel-video/scripts/mix-audio.sh bgm.wav voice.wav narration-mix.mp3 # duck + master

# 5. render + QA
.claude/skills/devrel-video/scripts/render-qa.sh projects/nevermined-catalog
```

## Notes

- The capture's Beat 3 targets AgentOracle but **falls back** to the first crypto service if it isn't in the
  filtered grid — in this recording that was **Heurist Mesh**. Set an exact `a[href="…"]` in `capture.js` to
  pin a specific service.
- The composition is re-timed to the narration (25.7s silent → 31s narrated). GSAP + Inter load from CDN —
  vendor them for a confidential cut.
- `capture.mp4`, `*.mp3/*.wav`, and `renders/*` are gitignored; re-run the pipeline to regenerate. The
  committed `index.html` references `capture.mp4` + `narration-mix.mp3`, so regenerate those before rendering.
