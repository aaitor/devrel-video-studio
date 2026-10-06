# example-walkthrough

A worked example: a ~24s **silent** browser tour, framed and chaptered with the `/devrel-video` pipeline.
It records the open **RealWorld demo app** (`demo.realworld.io` — no login, no PII) as a stand-in for
"your product", using the default **Acme** placeholder brand for the title / frame / CTA. Swap the capture
URL and the brand and you have your own video.

> `capture.mp4`, `renders/`, and any audio are **gitignored** — regenerate them by running the pipeline.
> The committed source is `brief.yaml` + `capture.js` (+ this README).

## Make it

```bash
# from the repo root
S=.claude/skills/devrel-video

# 1. (optional) refresh the brand — the default Acme brand already ships in brands/acme/
#    $S/scripts/brand-extract.sh https://your-product.example app   # → brands/app/

# 2. capture the live flow (confirm capture.js selectors first — SKILL §2 "Explore")
$S/scripts/capture.sh projects/example-walkthrough/capture.js "https://demo.realworld.io/"

# 3. compose: scaffold, then fill index.html from the template + the brand tokens
HYPERFRAMES_SKIP_SKILLS=1 npx hyperframes init projects/example-walkthrough --video capture.mp4 --skip-transcribe --non-interactive
#    → replace index.html with $S/templates/composition.html, filled from brief.yaml + brands/acme/tokens.json
#      (title → framed footage → chapter lower-thirds synced to the beats → CTA)

# 4. render + QA
$S/scripts/render-qa.sh projects/example-walkthrough
```

## Make it yours

- **Your product**: point `capture.url` at it, confirm selectors in the Explore step, set `url_label`.
- **Your brand**: `scripts/brand-extract.sh <your-url> <name>` → set `brand: <name>` in `brief.yaml`.
- **Optional layers** (all off here): narration, music, subtitles, a face-only avatar, and multi-environment
  (terminal ⇄ browser) — see SKILL §5.4–5.8. Narration/avatar are "bring your own" infra (see `scripts/_env.sh`).
