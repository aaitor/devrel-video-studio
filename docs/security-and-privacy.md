# Security, privacy, and media rights

Capture public fixtures or a dedicated sanitized demo environment. Check for personal data, credentials, wallets, host paths, private URLs, and authentication popups before recording or sharing. Review screenshots/contact sheets and the final exported media.

Presenter footage is bring-your-own and stays outside this public repository. Use only footage and voices you have permission to use. Keep derived avatars and private project output out of Git; the existing ignore rules intentionally allowlist only curated public examples.

Narration/avatars are optional integrations. Their helpers can contact your configured TTS endpoint or SSH host; do not run them merely to validate documentation. Configuration files are sourced as shell scripts. Inspect and trust their contents, and do not print tokens or connection secrets in issues or recordings.

Composition templates can load third-party scripts/fonts from CDNs. The [production notes](../.claude/skills/devrel-video/references/production-notes.md) explain vendoring for confidential work. HyperFrames telemetry settings are described in the original guide and render helper; do not assume every optional external tool has identical behavior.

Original studio code and documentation use MIT. Bundled banner fonts retain their OFL notices; external tools, models, voices, fonts, and media retain their own terms. See [licensing](licensing.md) and report vulnerabilities through [SECURITY.md](../SECURITY.md).
