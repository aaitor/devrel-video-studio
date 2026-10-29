# Acme walkthrough brief

Prepare only the intake brief and beat plan. Do not open a browser, capture, render, synthesize speech, contact a service, or publish anything.

- Project id: demo
- Mode: silent-demo
- Audience: developers evaluating Acme Workspace
- One message / approved claim: "Everything your team ships, in one place."
- Duration: 25 seconds; output docs-16x9 (1920 × 1080)
- Brand: reuse brands/acme
- Local fixture: projects/example-walkthrough/site/ served at http://localhost:8000/
- Start command for a later capture: python3 -m http.server 8000 --directory projects/example-walkthrough/site
- Flow: show workspace → filter by category → open a project
- CTA: "Make your own"; github.com/aaitor/devrel-video-studio
- No narration, music, avatar, subtitles, or terminal/browser scene switching.

Read the actual brief template, brand tokens, and fixture source. Create projects/demo/brief.yaml with the same schema, adapted to the inputs above. Show a concise three-beat plan and stop before running production commands.
