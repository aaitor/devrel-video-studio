# nevermined-catalog

The first worked example: a **25.7s silent walkthrough** of the Nevermined AI Services catalog —
title → browse → filter by category → inspect a service → CTA. Built entirely with the `/devrel-video`
pipeline. `renders/contact-sample.png` shows the beats.

## How it was made

```bash
# 1. brand (real tokens + logo)
.claude/skills/devrel-video/scripts/brand-extract.sh https://nevermined.app/catalog nevermined

# 2. capture (edit capture.js beats first)
.claude/skills/devrel-video/scripts/capture.sh projects/nevermined-catalog/capture.js https://nevermined.app/catalog

# 3. compose
HYPERFRAMES_SKIP_SKILLS=1 npx hyperframes init projects/nevermined-catalog --video capture.mp4 --skip-transcribe --non-interactive
#    → then replace index.html from templates/composition.html, filled from brief.yaml + brands/nevermined/tokens.json

# 4. render + QA
.claude/skills/devrel-video/scripts/render-qa.sh projects/nevermined-catalog
```

## Notes

- The capture's Beat 3 targets AgentOracle but **falls back** to the first crypto service if it isn't in the
  filtered grid — in this recording that was **Heurist Mesh**. Set an exact `a[href="…"]` in `capture.js` to
  pin a specific service.
- Silent (no music yet). GSAP + Inter load from CDN — vendor them for a confidential cut.
- `capture.mp4` / `renders/*.mp4` are gitignored; re-run the pipeline to regenerate.
