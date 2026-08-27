# Terminal beat 1 — ask Claude Code to find a payable agent. Run: scripts/capture-terminal.sh intro.tape
# Sanitized: clean demo dir, no CLAUDE_CODE_CHILD_SESSION marker, Escape dismisses popups. See templates/terminal-script.tape.
Output term1.mp4
Set FontSize 20
Set Width 1600
Set Height 900
Set Padding 24
Hide
Type "cd ~/nevermined-demo && unset CLAUDE_CODE_CHILD_SESSION && clear"
Enter
Sleep 400ms
Type "claude"
Enter
Sleep 4s
Enter
Sleep 2s
Show
Sleep 700ms
Type "Find me an AI weather agent I can call and pay for"
Sleep 1s
Enter
Sleep 13s
Escape
Sleep 1s
