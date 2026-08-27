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

1. **Music.** ✅ Supported. Fastest path (no auth/model): `scripts/gen-bgm.py` → a local synth bed
   (`gen-bgm.py bed.wav`, then ffmpeg → `bgm.mp3`), wired through the `<audio id="bgm" … data-track-index="9">`
   seam. Produced track: `/media-use resolve --type bgm` (HeyGen catalog — needs `heygen` sign-in) or
   `--local-only` (MusicGen). Under narration, lower the bed and duck with `/hyperframes-audio` (voiceover
   carve). Tune key/tempo/layers in `gen-bgm.py`. Note: convert footage with **dense keyframes**
   (`-g 30 -keyint_min 30 -sc_threshold 0`) or the renderer freezes footage frames between seeks.
2. **Background narration (2a).** ✅ Supported. TTS each beat line with `scripts/tts.sh` (Orpheus on Melkor,
   voice `leah`; restart `start_orpheus_stack.sh` if it 502s — post-reboot it can segfault at slot-init, see
   the `orpheus-tts-melkor` memory). `templates/narrate.py` measures the lines, **derives the scene/chapter
   times from the audio** (never the reverse), writes `voice.wav`, and re-times `captions.<lang>.srt` to the
   voice. Retime the composition to those numbers (a 26s silent cut → ~31s), then `scripts/mix-audio.sh`
   ducks the music bed under the voice and masters to −16 LUFS. Clean text first (no parens/version numbers;
   em-dash → comma). Piper (`en_US-lessac-medium`, bundles its own onnxruntime) is a working no-auth fallback.
   `narrated-devrel` mode.
3. **Avatar (2b).** ✅ Supported — **face-only circular bubble**, lip-synced, shown ONLY at intro / one
   transition / CTA (product stays the hero — a full-time presenter turns it into a webinar). `scripts/avatar.sh
   <plate> <line.wav> avatar-face.mp4` runs **LatentSync (256) on Melkor's AMD RX 9060 XT (ROCm)** — proven
   local, no HeyGen/NVIDIA needed. Feed `<line.wav>` = the exact narration segment the mouth should say (trim it
   from `narration-mix.mp3` so lips match what's heard); the script lip-syncs, then **face-tracks** the head into
   a pinned square (`track_crop.py` follows the face every frame at constant size so it doesn't drift in the circle
   — vidstab alone can't calm a *moving subject*; the circle is CSS `border-radius:50%`, `data-track-index=11`). Depends on (2a):
   narration first, avatar rendered against a segment of it. **Gotchas baked into avatar.sh** (learned in the
   feasibility spike): the RX 9060 XT is HIP **device 1** (device 0 = Ryzen iGPU) → `HIP_VISIBLE_DEVICES=1` is
   mandatory or every kernel dies `invalid device function`; 256 inference peaks ~14 GB → it frees idle Ollama
   models first (Orpheus stays up); ~10 min/clip cold. Plate must be ≥ the audio length (no auto-loop). Env at
   `melkor:~/Projects/AI/latentsync-spike/` (torch 2.9.1+rocm6.4, LatentSync 1.5 ckpt). **Consent:** use only a
   face/voice you have rights to — real videos need your own plates; the catalog demo uses LatentSync's bundled
   sample face as a stand-in. Sharper mouth (512 / LatentSync 1.6) needs Orpheus stopped for VRAM — not worth it
   at bubble size. `narrated-devrel` + avatar.
4. **Subtitles (3).** ✅ Supported. Author caption cues timed to the beats → `captions.<lang>.srt` (soft,
   toggleable, one file per language). Ship the `.srt` alongside the clean video; burn a social/autoplay
   cut with `scripts/subtitles.sh`. Once narration exists, generate cues from its transcript (WhisperX via
   `/media-use`, word-level timing) instead of authoring, or hand off to `/embedded-captions`. Keep a
   terminology dictionary (product names, protocols like x402/MPP) and proofread. "Alternative subtitles"
   = multiple language `.srt` from the same cues.

Dependency order: **narration → avatar**; subtitles and music are independent (author subtitles to the
beats now; re-time them to the narration transcript when it exists).
