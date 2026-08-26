# Production notes

Hard-won environment facts and the roadmap. The full design rationale is in the repo-root guide
(`local-devrel-video-studio-guide.md`, v1.2).

## Environment gotchas (verified on Ubuntu 26.04, Node 24, ffmpeg 8)

- **Browser sandbox.** On AppArmor/userns-restricted hosts (`apparmor_restrict_unprivileged_userns=1`),
  capture needs `PLAYWRIGHT_MCP_SANDBOX=false`. HyperFrames' render (chrome-headless-shell) needs **no** flag.
  Both are handled by the scripts.
- **playwright-cli daemon.** Install the binary (local/global) — a bare per-command `npx @playwright/cli`
  drops the browser between `open` / `run-code` / `close`. `capture.sh` installs it under `.pw/` once.
- **`hyperframes init`** is non-interactive for agents and **requires** `--example|--video|--audio` plus
  `--non-interactive`. It pings GitHub for skills unless `HYPERFRAMES_SKIP_SKILLS=1`. Telemetry off:
  `hyperframes telemetry disable` or `HYPERFRAMES_NO_TELEMETRY=1` / `DO_NOT_TRACK=1`.
- **Determinism.** The browser *capture* is reproducible, not frame-identical — drive chapter timing from
  recorded beats, not wall-clock. The HyperFrames *render* is deterministic (same HTML → same frames).
- **Composition contract.** Sibling `class="clip"` elements with `data-start`/`data-duration`/`data-track-index`;
  video is a `<video class="clip">`; a **paused** GSAP timeline on `window.__timelines["main"]`; every animated
  element needs a stable `id` (`:nth-of-type` counts all tags of that type, not the class). Clips may overlap
  in time on the same track.

## Vendoring (required for confidential/production)

The composition template loads **GSAP** and **Inter** from CDNs (fine for public drafts; the security hook
flags the script tag on purpose). For a confidential render:

- GSAP → download `gsap.min.js` into the project and `<script src="gsap.min.js">`.
- Inter → drop `.woff2` files in the project and add `@font-face` rules; remove the Google Fonts `<link>`.
- Re-run the §14.5 check: no remote `<script>`, `<link>`, font, or media reference survives.

## Two capture modes (pick by intent)

- **Interaction walkthrough** (default): Playwright `page.screencast` — shows the product being *used*.
- **Static showcase**: `hyperframes capture <URL>` — screenshots + brand tokens, camera over stills
  (this is what `/product-launch-video` uses, and how `brand-extract.sh` pulls tokens + logo).

## Roadmap — the four next features

Each has a commented seam in `templates/composition.html` and a field in `brief.yaml`.

1. **Music.** Source a bed via `/media-use` (its built-in local fallback is MusicGen; ACE-Step is a
   higher-quality standalone). Add an `<audio class="clip" data-track-index="9" data-volume="0.5">`.
   Keep it under any narration; mix/duck with `/hyperframes-audio` (voiceover carve).
2. **Background narration (2a).** Write a short script, then TTS via `/media-use` (Kokoro) or record it.
   **Lock scene/chapter times to the finished audio, not the reverse.** Add a narration `<audio>` track and
   dip the music under it. `narrated-devrel` mode.
3. **Avatar (2b).** A talking-head presenter, lip-synced to the narration, composited in a corner
   (`#avatar` `<video>` seam). Generate with a talking-head tool (HeyGen — HyperFrames' parent — or
   `/talking-head-recut` for packaging). It depends on (2a): narration first, avatar rendered against it.
4. **Subtitles (3).** Transcribe the narration with WhisperX via `/media-use` (word-level timing), then
   render timed caption `.clip` lines, or hand off to `/embedded-captions`. Keep a terminology dictionary
   (product names, protocols like x402/MPP) and proofread. "Alternative subtitles" = multiple language
   tracks from the same transcript.

Dependency order: **narration → (avatar, subtitles)**; music is independent.
