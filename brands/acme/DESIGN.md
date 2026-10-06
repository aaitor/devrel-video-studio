# Acme Corp. — default demo brand

A **fictional placeholder brand** so the template renders out of the box. For a real video, replace it:
`scripts/brand-extract.sh <your-url> <name>` writes `brands/<name>/` (real `tokens.json` + `logo.svg`), then
set `brand: <name>` in `brief.yaml`. **Never invent a palette** for a real product — extract it.

## Palette

The composition reads these as CSS variables (`templates/composition.html` → `:root`). Names are semantic, so
any brand maps onto them:

| Variable | Hex | Role in video |
|---|---|---|
| `--brand` | `#4F46E5` | title/CTA gradient center, primary accents |
| `--brand-deep` | `#0B1020` | gradient edge + body background base, chapter pills |
| `--accent` | `#6366F1` | secondary accents, pill borders, brandmark |
| `--highlight` | `#22D3EE` | key phrase, kicker, CTA url, chapter dot |
| `--muted` | `#94A3B8` | site labels / subtitle on dark |
| `--ground` | `#FFFFFF` | the product capture / browser frame |

## Type

- **Inter** (400–800). Google-Fonts `<link>` for drafts; **vendor `.woff2` for production** (see production-notes).

## Logo

- `logo.svg` — a simple `ACME` wordmark, `fill="currentColor"` so it recolors (white on the dark card). Inline
  it as a `<symbol id="brand-logo">` in the composition and set `color`. Keep clear-space.

## Video-specific (1920×1080)

- The dark `--brand-deep` cards make the **white** product capture pop — frame the footage in a browser window.
- Title: Inter 800, ~96px; highlight the key phrase in `--highlight`.
- Chapter lower-thirds: `--brand-deep` pill, `--accent` border, `--highlight` dot, Inter 600 ~27px.
- Only put **approved claims** on screen (numbers/names from the captured page), never invented.
