# Nevermined — brand for video

Extracted from `nevermined.app/catalog` via `scripts/brand-extract.sh` → `tokens.json` (full set) + `logo.svg`
(the real wordmark, `fill="currentColor"` so it recolors). Do not invent values; use these.

## Palette

| Role | Hex | Use in video |
|---|---|---|
| Primary teal | `#0D3F48` | title/CTA gradient top, accents |
| Dark teal | `#082826` | title/CTA background base, chapter pills |
| Mint | `#12968C` | secondary accents, pill borders |
| Lime | `#D7F771` | highlight word, kicker, CTA url, chapter dot |
| Ink | `#0A0A0A` | text on white |
| Muted | `#737373` | site labels (`--muted` in video: `#9FB7B0` on dark) |
| Ground | `#FFFFFF` | the product capture / browser frame |

## Type

- **Inter** (400–800). Load as a webfont for drafts; **vendor `.woff2` for production** (see production-notes).

## Logo

- `logo.svg` — wordmark, `currentColor`. Inline it as a `<symbol>` and set `color` (white on dark cards).
- Keep clear-space; don't recolor to non-brand hues.

## Video-specific (1920×1080)

- Dark teal cards make the **white** product capture pop — frame the footage in a browser window.
- Title: Inter 800, ~96px; highlight the key phrase (e.g. "pay-per-call") in lime.
- Chapter lower-thirds: dark-teal pill, mint border, lime dot, Inter 600 ~27px.
- Approved language seen on the site: "pay-per-call", "curated", "one API key", "no checkout",
  service counts (e.g. "149"). Re-verify counts per render — they change.
