# Terminal beat 2 — pay the agent over MCP. Run: scripts/capture-terminal.sh pay.tape
# Sanitized: clean demo dir, no CLAUDE_CODE_CHILD_SESSION marker, `claude --strict-mcp-config` aliased (hides the
# MCP-auth line; recorded command stays a clean `claude`), Escape dismisses popups. See templates/terminal-script.tape.
Output term2.mp4
Set FontSize 20
Set Width 1600
Set Height 900
Set Padding 24
Hide
Type "cd ~/nevermined-demo && unset CLAUDE_CODE_CHILD_SESSION && alias claude='claude --strict-mcp-config' && clear"
Enter
Sleep 400ms
Type "claude"
Enter
Sleep 4s
Enter
Sleep 2s
Show
Sleep 700ms
Type "Now pay that agent 0.05 USDC over MCP and show me the receipt"
Sleep 1s
Enter
Sleep 13s
Escape
Sleep 1s
