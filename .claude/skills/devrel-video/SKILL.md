---
name: devrel-video
description: Produce a silent DevRel-style product walkthrough video from a web URL. Playwright records the live flow, HyperFrames composes title/frame/chapters/CTA, FFmpeg masters. Use when asked to record, make, or update a product demo, feature walkthrough, catalog tour, or promo video from a web product.
---

# DevRel Video Studio — `/devrel-video`

A **thin orchestrator**. It does not reimplement capture or composition — it drives:

- **playwright-cli** (`page.screencast`) for live interaction capture,
- **HyperFrames** for composition + deterministic MP4 render,
- **FFmpeg / ffprobe** for convert, master, and QA.

Read `references/production-notes.md` first for environment gotchas (sandbox flags, `init` flags, CDN vendoring, determinism) and the production steps for **music, narration, avatar, and subtitles** (all supported — steps 5.4–5.7; the template and manifest carry seams for each).

## When to use

- "record / make / produce a walkthrough, demo, catalog tour, or promo of `<web product / URL>`"
- "update / re-render an existing devrel-video project"

## Inputs — gather, never guess

- **URL** (+ start command if the product is local).
- **Flow**: the 2–4 beats to show (e.g. browse → filter → open a detail).
- **Brand**: reuse `brands/<name>/`, or extract from the URL (step 3).
- **Output**: format(s) + duration target. Default: **silent 16:9, ~25–40 s**.
- **Approved claims**: numbers/names allowed on screen — pull from the captured page, never invent (guide §7/§8).

## Workflow

### 1 · Intake → `projects/<slug>/brief.yaml`
Copy `templates/brief.example.yaml`. Confirm the audience, the one message, the CTA, and the beats.

### 2 · Explore (before recording)
Open the URL headless; snapshot + screenshot. Confirm: no login wall, **no PII / keys / wallets on screen**, and stable selectors for each beat. Prefer exact `a[href="…"]` and `getByRole` locators; always add a fallback selector so one missing element can't abort the capture.

### 3 · Brand → `brands/<name>/`
`scripts/brand-extract.sh <url> <name>` → `tokens.json` (real palette + fonts) + `logo.svg`. Use these in the composition. **Never invent a palette.** Reuse `brands/nevermined/` for Nevermined products.

### 4 · Capture → `projects/<slug>/capture.mp4`
Copy `templates/hero-script.js` → `capture.js`; edit the beats (eased `scrollTo`, real locators, deliberate pauses, **all-forward navigation** so `page.screencast` survives route changes). Then:
`scripts/capture.sh projects/<slug>/capture.js "<start-url>"` → records `capture.webm`, converts to `capture.mp4`. Contact-sheet it; re-record on layout shift, PII, or a mis-click.

### 5 · Compose → `projects/<slug>/index.html`
`hyperframes init projects/<slug> --video capture.mp4 --skip-transcribe --non-interactive`, then replace `index.html` with `templates/composition.html`, filled from the brief + tokens:
title card (real claims) → footage in a browser frame → chapter lower-thirds synced to the capture beats (+ the title-card offset) → CTA. Give **every animated element a stable `id`** (GSAP and lint both require it).

### 5.4 · Narration (optional — drives the timeline)
For a narrated cut the **voice sets the timing.** Write ~1 line per beat (clean text: no parens/version numbers, em-dash → comma). Synth each with Orpheus `leah`: `scripts/tts.sh "<line>" vo1.wav` (Melkor `orpheus-tts`; restart its stack if it 502s). Then adapt `templates/narrate.py` (footage length, beat times, line texts) — it measures the lines, computes scene/chapter times, writes `voice.wav`, and **re-times `captions.<lang>.srt` to the voice**. Retime the composition to those numbers (scenes grow — a 26s silent cut becomes ~31s), mix (next step), render. `narrated-devrel` mode.

### 5.5 · Music (optional)
Local, license-clean bed — no auth, no model:
`python3 .claude/skills/devrel-video/scripts/gen-bgm.py bed.wav && ffmpeg -i bed.wav -b:a 192k projects/<slug>/bgm.mp3`,
then add the `<audio id="bgm" class="clip" src="bgm.mp3" … data-track-index="9" data-volume="0.85">` seam to the
composition (lower the volume under narration). For a produced track: `/media-use resolve --type bgm`
(HeyGen catalog — needs `heygen` sign-in) or `--local-only` (MusicGen), dropped into the same seam. **With narration**, don't stack two audio clips — pre-mix: `scripts/mix-audio.sh bgm.wav voice.wav narration-mix.mp3` ducks the bed under the voice and masters to −16 LUFS; use that one file in the seam at `data-volume="1"`.

### 5.6 · Subtitles (optional)
Author caption cues timed to the beats → `projects/<slug>/captions.<lang>.srt` — soft, toggleable, platform-standard; **one file per language** covers "alternative subtitles". Ship the `.srt` next to the video (YouTube/LinkedIn read it). For autoplay-muted social, burn a hard cut: `scripts/subtitles.sh projects/<slug> captions.en.srt`. When narration exists, derive the cues from its transcript (WhisperX via `/media-use`) instead of authoring.

### 5.7 · Avatar (optional — face-only presenter)
A **face-only circular bubble**, lip-synced, shown ONLY at intro / one transition / CTA (product stays the hero — a full-time presenter reads as a webinar). Depends on narration. Trim the exact line the mouth should say from `narration-mix.mp3` so lips match what's heard: `ffmpeg -ss <t0> -to <t1> -i projects/<slug>/narration-mix.mp3 -ar 16000 -ac 1 line.wav`. Then `scripts/avatar.sh <plate> line.wav projects/<slug>/avatar-face.mp4` — runs **LatentSync (256) on Melkor's AMD GPU (ROCm)**, lip-syncs, then **pins the face** (per-frame face-tracking via `track_crop.py` — follows the face every frame at constant size, so the head stays put in the small circle instead of drifting; vidstab alone can't fix a *moving subject*). Add a `<video class="clip face-bubble" src="…" data-start data-duration data-track-index="11">` element with a shared `.face-bubble` CSS class (`border-radius:50%` = the circle) + a GSAP pop-in / fade-out over that window (`data-duration` = the line's length). **For a bubble at more than one moment** (e.g. intro *and* CTA), run avatar.sh once per line and add one element per window; set `.face-bubble` `z-index` above any full-screen scene card it overlaps (the CTA card is z-index 8 → bubble z-index 9). The `<plate>` is the `avatar_plate:` from `brief.yaml` — a **private recording kept OUTSIDE the (public) repo** (convention: `~/Videos/<Org>/DevRel/Talking_Head/<name>/`); generated `avatar-*.mp4` bubbles are gitignored, never committed. Format: front-on, sitting still, even light, mouth visible, ≥ the line's length; **any fps** (avatar.sh normalizes to 25 fps — LatentSync's rate, else the lips drift). Brighten a backlit plate first (`ffmpeg -vf eq=brightness=0.06:contrast=1.10:gamma=1.12`), and raise `STEPS=30` (env, default 20) for a crisper mouth. ~10 min/clip cold. `narrated-devrel` + avatar.

### 6 · Render + QA → `projects/<slug>/renders/`
`scripts/render-qa.sh projects/<slug>` → high master + web-compressed copy + ffprobe + contact sheet. Gates before "done":
- `hyperframes lint` 0 errors · `hyperframes check` passes (Contrast AA).
- ffprobe: target dims/fps/duration, video stream present, non-zero size.
- Contact sheet: no clipped text, correct product state, chapters aligned, **no PII**.
- Security: no keys/wallets/PII; all CDN assets vendored for confidential projects.

## Delegation map — do not reinvent

| Need | Use |
|---|---|
| Live interaction capture | playwright-cli `page.screencast` (`templates/hero-script.js`) |
| Static screenshots + brand tokens | `hyperframes capture <URL>` |
| Composition + render | HyperFrames + `templates/composition.html` |
| Creative direction (promo) | `/product-launch-video`, `/hyperframes-creative` |
| Audio (music/SFX/voice) + captions | `/media-use`, `/hyperframes-audio` |
| Master / convert / QA | FFmpeg / ffprobe (`scripts/render-qa.sh`) |

## Roadmap

Music, narration, avatar, and subtitles are all supported (steps 5.4–5.7). Still open: portrait/social **output profiles** (9×16 recompose, not crop) and a short muted web-loop; and recording a real presenter's **avatar plates** (the demo uses a stand-in face). See `references/production-notes.md`.
