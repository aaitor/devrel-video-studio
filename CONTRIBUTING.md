# Contributing

Use [Issues](https://github.com/aaitor/skill-video-studio/issues) for bugs and proposals. Discuss large changes first. Preserve the native `.claude/skills/devrel-video`, `brands/`, and `projects/` layout and the existing working examples.

Install development checks with `python3 -m pip install -r requirements-dev.txt`, then run `python3 scripts/check.py`. Checks validate source syntax, documentation links, SVG/JSON/YAML sources, and a local music-generator smoke test. They do not run a full browser capture or HyperFrames render.

For pipeline changes, test the affected workflow and inspect its actual output with the existing QA tools. Keep private footage, credentials, endpoint details, and personal project outputs out of commits. Only curated public examples should be added to the project allowlist.

Open a focused pull request describing resulting behavior and verification. Contributions use MIT; follow [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). Report vulnerabilities through [SECURITY.md](SECURITY.md).
