"""Record real studio installation and Claude Code brief creation; no capture/render."""

import argparse
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def prepare(workspace):
    (workspace / "recording-settings.json").write_text(
        json.dumps(
            {
                "disableAllHooks": True,
                "enabledPlugins": {},
            }
        )
        + "\n"
    )
    (workspace / "empty-mcp.json").write_text('{"mcpServers":{}}\n')
    shutil.copy2(ROOT / "examples/claude-demo.md", workspace / "recording-instructions.md")
    shutil.copy2(ROOT / "examples/brief.md", workspace / "brief.md")
    (workspace / "demo-shell.sh").write_text(
        "claude() { command claude --setting-sources project "
        "--settings ../recording-settings.json --strict-mcp-config "
        "--mcp-config ../empty-mcp.json --tools Read,Write,Skill "
        "--allowedTools Read Write Skill "
        '--append-system-prompt "$(cat ../recording-instructions.md)" '
        '"$@" 2>../claude-demo.log; }\n'
    )
    shutil.copy2(ROOT / "examples/theme.tape", workspace / "theme.tape")
    shutil.copy2(ROOT / "examples/demo.tape", workspace / "demo.tape")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, default=ROOT / "assets/terminal-demo.gif")
    parser.add_argument("--brief-out", type=Path, default=ROOT / "examples/recorded-brief.yaml")
    args = parser.parse_args()
    for command in ["git", "claude", "vhs", "ttyd", "ffmpeg"]:
        if not shutil.which(command):
            parser.error(f"{command} must be installed and available on PATH.")
    with tempfile.TemporaryDirectory(prefix="devrel-claude-recording-") as temporary:
        workspace = Path(temporary)
        prepare(workspace)
        print("Recording actual studio installation and brief creation; no capture or render.", flush=True)
        subprocess.run(["vhs", "demo.tape"], cwd=workspace, check=True)
        brief = workspace / "studio/projects/demo/brief.yaml"
        if not brief.is_file() or not brief.read_text().strip():
            raise RuntimeError("Claude did not create the required walkthrough brief.")
        for source, destination in [(workspace / "demo.gif", args.out), (brief, args.brief_out)]:
            destination = destination.resolve()
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
            print(f"Saved {destination}")


if __name__ == "__main__":
    main()
