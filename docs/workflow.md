# Production workflow

The real skill entrypoint is [.claude/skills/devrel-video/SKILL.md](../.claude/skills/devrel-video/SKILL.md). It orchestrates existing capture, composition, and mastering tools.

1. **Intake:** fill a brief with the audience, message, approved claims, flow, brand, duration, and output.
2. **Explore:** inspect the product and selectors; ensure public or sanitized demo data is suitable for recording.
3. **Brand:** reuse `brands/<name>/` or extract the product's actual brand tokens.
4. **Capture:** drive Playwright's screencast with a real hero script and forward navigation.
5. **Compose:** frame the capture, title, chapters, and CTA in a HyperFrames HTML timeline.
6. **Optional layers:** add music, narration-driven timing, subtitles, avatar bubbles, or terminal/browser scenes.
7. **Render and QA:** lint/check the composition, render master and web copy, inspect ffprobe output and a contact sheet.
8. **Thumbnail:** create the 1280 × 720 thumbnail and a small README loop when needed.

See [usage](usage.md) for prompts, [example-walkthrough](../projects/example-walkthrough/README.md) for actual commands, and [production notes](../.claude/skills/devrel-video/references/production-notes.md) for capture/render constraints.

The short repository GIF demonstrates real brief creation through Claude Code, stopping before capture/render. The longer CLI/browser film uses authored terminal reenactment for deterministic composition; its [README](../projects/example-cli-tour/README.md) explains that distinction.
