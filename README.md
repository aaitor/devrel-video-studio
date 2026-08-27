# DevRel Video Studio

Local, Claude Code–driven system that records web-product walkthroughs and composes them into
professional silent demo videos. Capture with **Playwright CLI**, compose + render with **HyperFrames**,
master with **FFmpeg** — orchestrated by the `/devrel-video` skill.

Full design + rationale: [`local-devrel-video-studio-guide.md`](local-devrel-video-studio-guide.md) (v1.2).

## Layout

```
.claude/skills/devrel-video/   # the skill: SKILL.md, templates/, scripts/, references/
brands/<name>/                 # real brand tokens + logo (tokens.json, logo.svg, DESIGN.md)
projects/<slug>/               # one video: brief.yaml, capture.js, index.html, renders/
```

## Quick start

Ask Claude Code: **"use /devrel-video to make a walkthrough of `<URL>`, showing `<flow>`."** It will:

1. **Intake** — fill `projects/<slug>/brief.yaml` from `templates/brief.example.yaml`.
2. **Explore** — open the URL, confirm no login/PII, find stable selectors.
3. **Brand** — `scripts/brand-extract.sh <url> <name>` → `brands/<name>/`.
4. **Capture** — edit `templates/hero-script.js` → `capture.js`; `scripts/capture.sh <capture.js> <url>`.
5. **Compose** — `hyperframes init … --video capture.mp4`; fill `templates/composition.html`.
6. **Render + QA** — `scripts/render-qa.sh projects/<slug>` → master + web copy + ffprobe + contact sheet.

Requirements: Node 22+, FFmpeg, Chromium (see the guide §5). Everything runs locally; telemetry off.

## Example prompts

Paste any of these to Claude Code:

**Without a talking head** (silent or voiceover only):
- **Silent tour** — `use /devrel-video to make a silent walkthrough of https://nevermined.app/catalog, showing browse → filter by category → open a service`
- **Narrated** — `use /devrel-video for https://nevermined.app/catalog: narrated walkthrough (male voice) + background music + English & Spanish subtitles`
- **Pick / swap the voice** — `…narrate it with voice dan`, or later `regenerate nevermined-catalog with voice leah` — the voice is a prompt parameter; each one is a new variant (male leo/dan/zac, female leah/tara/jess/mia/zoe — match the presenter)
- **Reuse a brand** — `use /devrel-video for https://nevermined.app/pricing using the nevermined brand; show the plan comparison then the checkout`
- **New brand** — `use /devrel-video for https://acme.com/app — extract the acme brand first, then walk sign-up → dashboard`
- **Local product** — `use /devrel-video on my local app at http://localhost:3000 (start: npm run dev): sign-up → create a project → invite a teammate`

**With a talking head** (presenter bubble at intro/CTA — see [Talking-head avatar](#talking-head-avatar-bring-your-own) below):
- **Narrated + your avatar** — `use /devrel-video for https://nevermined.app/catalog: narrated (voice leo) with my talking-head avatar at the intro and CTA. My plate is at ~/Videos/Nevermined/DevRel/Talking_Head/Aitor/shorter_but_better.mp4`
- **Avatar at intro only** — `…add my talking-head only at the intro, then let the product run full-screen` (plate as above)
- **Pick the voice** — `…use a male voice — show me leo / dan / zac samples first` (the voice should match the presenter's)

**Tweaks** (either mode):
- **Pin an element** — `…open the AgentOracle service specifically` (exact `a[href="…"]` in `capture.js`, no fallback)
- **Re-render** — `re-render nevermined-catalog with a slower detail scroll and a "Read the docs" CTA`
- **Different length** — `make it ~45s with four chapters`, or `cut a 15s teaser`

The skill gathers anything it still needs (audience, the one message, approved claims, and — for an avatar — your plate path) before recording.

## Worked example

`projects/nevermined-catalog/` — a ~27s narrated tour of the Nevermined AI Services catalog
(browse → filter → inspect a service) with music, en/es subtitles, and a presenter avatar at the intro/CTA.
See its README for the exact commands used.

## Optional layers (all supported)

Music, narration (Orpheus TTS — male `leo`/`dan`/`zac` or female `leah`/`tara`/`jess`/`mia`/`zoe`; match it to
your presenter), a **face-only presenter avatar** (LatentSync on Melkor's AMD GPU, lip-synced, shown briefly at
intro/CTA), and multi-language subtitles — steps 5.4–5.7 of the skill. Still on the roadmap: portrait/social
output profiles. Details in
[`.claude/skills/devrel-video/references/production-notes.md`](.claude/skills/devrel-video/references/production-notes.md).

## Talking-head avatar (bring your own)

The presenter bubble is **your own face** — you supply the recording; this studio never bundles a face.

**Privacy.** Your talking-head footage lives **outside this repo**, e.g. `~/Videos/<Org>/DevRel/Talking_Head/<name>/`,
and is referenced from `brief.yaml` (`avatar_plate:`). Nothing derived from it is committed either — the generated
bubbles (`projects/<slug>/avatar-*.mp4`) and rendered videos are gitignored. **This repo is public; keep faces out of it.**

**Required format** (one clip is enough to start):
- **Sit still**, look at the lens, and **talk naturally** for ~30–60s. The words don't matter — only your face and
  mouth motion are used; the narration is re-synced on top.
- Face front-on, filling a good part of the frame; **even lighting** (no hard shadow across the mouth); nothing over the mouth.
- 1080p+ (720p is fine), **any fps** (the pipeline normalizes to 25 fps, LatentSync's rate). No green screen — the bubble is a circular crop.

Drop the file in your Talking_Head folder, point `avatar_plate:` at it, and the skill lip-syncs it to the narration
at the intro/CTA — regenerated from your local copy each render.
