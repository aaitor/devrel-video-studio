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

- **Basic tour** — `use /devrel-video to make a walkthrough of https://nevermined.app/catalog, showing browse → filter by category → open a service`
- **Reuse a brand** — `use /devrel-video for https://nevermined.app/pricing using the nevermined brand; show the plan comparison then the checkout`
- **New brand** — `use /devrel-video for https://acme.com/app — extract the acme brand first, then walk sign-up → dashboard`
- **Local product** — `use /devrel-video on my local app at http://localhost:3000 (start: npm run dev): sign-up → create a project → invite a teammate`
- **Pin a specific element** — `…open the AgentOracle service specifically` (sets an exact `a[href="…"]` in `capture.js`, no fallback)
- **Re-render / tweak** — `re-render the nevermined-catalog project with a slower detail scroll and a "Read the docs" CTA`
- **Different length** — `make it ~45s with four chapters`, or `cut a 15s teaser`

The skill gathers anything it still needs (audience, the one message, approved claims) before recording.

## Worked example

`projects/nevermined-catalog/` — a 25.7s silent tour of the Nevermined AI Services catalog
(browse → filter → inspect a service). See its README for the exact commands used.

## Not built yet

Background narration · talking-head avatar (music and subtitles are supported) — roadmap in
[`.claude/skills/devrel-video/references/production-notes.md`](.claude/skills/devrel-video/references/production-notes.md).
