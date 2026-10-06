# example-walkthrough

A worked example: a ~22s **silent** browser tour, framed and chaptered with the `/devrel-video` pipeline.
It records a **self-contained Acme mock app** (`./site/` — served locally, no login, no PII, no external
dependency) and frames it with the default **Acme** brand (`brands/acme/`). `renders/contact-sample.png`
shows the beats. Swap `./site/` for your real product URL and the brand, and you have your own video.

> `capture.mp4` and `renders/*.mp4` are **gitignored** — regenerate them by running the pipeline. The
> committed source is `brief.yaml` + `capture.js` + `site/` + `index.html` (+ the sample frame).

## Make it

```bash
# from the repo root
S=.claude/skills/devrel-video

# 1. serve the mock app, then capture the live flow (3 beats: workspace → filter → open a project)
python3 -m http.server 8000 --directory projects/example-walkthrough/site &
$S/scripts/capture.sh projects/example-walkthrough/capture.js "http://localhost:8000/"
kill %1   # stop the server

# 2. compose: scaffold, then fill index.html from the template + the brand tokens
HYPERFRAMES_SKIP_SKILLS=1 npx hyperframes init projects/example-walkthrough --video capture.mp4 --skip-transcribe --non-interactive
#    → index.html is filled from $S/templates/composition.html + brands/acme/tokens.json
#      (title → framed footage → chapter lower-thirds synced to the beats → CTA)

# 3. render + QA
$S/scripts/render-qa.sh projects/example-walkthrough
```

## Make it yours

- **Your product**: point `capture.url` at it (set `start_command` for a local app), confirm selectors in the
  Explore step (SKILL §2), set `url_label`.
- **Your brand**: `scripts/brand-extract.sh <your-url> <name>` → set `brand: <name>` in `brief.yaml`.
- **Optional layers** (all off here): narration, music, subtitles, a face-only avatar, and multi-environment
  (terminal ⇄ browser) — see SKILL §5.4–5.8. Narration/avatar are "bring your own" infra (see `scripts/_env.sh`).
