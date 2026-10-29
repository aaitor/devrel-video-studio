# Repository conventions

Preserve `.claude/skills/devrel-video/`, `brands/`, and `projects/`; the studio is a workspace, not a single root-level skill file. Read `docs/workflow.md` and the actual skill before changing production behavior.

For repository demos, use `examples/demo-spec.json` and read `examples/README.md`: pure black 1280 × 640, short install → real Claude Code invocation → useful result, with waiting time omitted. The current demo creates a real intake brief and stops before capture/render. Do not represent a planned video as a completed render or an authored reenactment as a live session. Keep live model/render jobs out of CI.

Run `python3 scripts/check.py` with the development dependencies. Keep presenter plates, generated private media, credentials, and host-specific configuration out of Git. Preserve explicit no-publish and other user limits.
