# nevermined-cli-tour

A **multi-environment** walkthrough: Claude Code (terminal) → the browser → back to Claude Code.
The presenter asks Claude Code to find a payable agent, the browser confirms it exists in the catalog,
then Claude Code pays it over MCP. Proof that a demo can move between the CLI and the web and back.

> Source only — the generated `*.mp4` clips are git-ignored (this repo is public). Regenerate locally.
> Terminal beats record a **real, sanitized** Claude Code session; nothing about the host leaks on screen.

## Regenerate

```bash
S=.claude/skills/devrel-video/scripts

# 1) terminal beat 1 — ask Claude Code (writes term1.mp4)
$S/capture-terminal.sh projects/nevermined-cli-tour/intro.tape

# 2) browser beat — the catalog (writes capture.mp4)
$S/capture.sh projects/nevermined-cli-tour/catalog-hero.js https://nevermined.app/catalog 1600x900

# 3) terminal beat 2 — pay over MCP (writes term2.mp4)
$S/capture-terminal.sh projects/nevermined-cli-tour/pay.tape

# 4a) quick preview — fade each beat through the brand teal (#082826)
cd projects/nevermined-cli-tour
$S/stitch-envs.sh tour.mp4 082826 term1.mp4 capture.mp4 term2.mp4

# 4b) full cut — the composed timeline is committed as index.html (title → terminal → browser →
#     terminal → CTA, chapter lower-thirds, fade-through-teal hand-offs, lint 0 errors). Render it:
$S/render-qa.sh projects/nevermined-cli-tour      # → renders/out.mp4 (+ web copy + contact sheet)
```

`index.html` expects `term1.mp4`, `capture.mp4`, `term2.mp4` next to it (steps 1–3 above). To swap in a
deterministic terminal beat instead of a capture, drop in `templates/cc-terminal.html` (see SKILL §5.8).

## Notes

- **Sanitation** (the terminal's "no-PII" gate): the tapes record in `~/nevermined-demo`, `unset CLAUDE_CODE_CHILD_SESSION`, and `Escape` onboarding popups. The `N MCP servers need authentication` line comes from the global config — thematically fine for an MCP demo, or start Claude with a clean config dir to hide it.
- **Determinism:** a live model turn varies run to run. For a repeatable cut, script a fixed response with the HTML-terminal re-enactment seam, or record a good take and trim.
- **Voice/avatar:** add `narration: leo` (or dan/zac — match the presenter) to `brief.yaml` and follow SKILL §5.4.
