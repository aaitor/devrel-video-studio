# Banner and social preview

The header follows the shared repository format: **diagonal-drift (1a)**, seed `7`, with the title `Video Studio Skill` and handle `@aaitor`. The README points at a commit-pinned banner in [aaitor/assets](https://github.com/aaitor/assets); a local copy is kept in `assets/hero.svg`.

`shared-assets.json` records the shared source revision and template revision. Banner generation is separate from the studio production toolchain. Regenerate shared artwork in the assets repository with Node.js 18+.

## Generate the banner

From a clone of `aaitor/assets` with Node.js 18+ installed:

```bash
node banner-kit/make-banner.mjs --style diagonal-drift \
  --repo "Video Studio Skill" \
  --tagline "From product workflow to polished demo." \
  --handle "@aaitor" --seed 7 --out banners/skill-video-studio.svg
```

See the [shared generation guide](https://github.com/aaitor/assets/blob/fd5c94691f8a2c0f751834e20ef6851748bd766d/docs/banner-generation.md) for all styles, fixed seeds, static output, and the JavaScript API. The kit requires no npm packages or network access. Preserve the bundled font notices.

## Regenerate the social card

From that same assets checkout, center the generated banner on a matching 1280 × 640 canvas:

```bash
python3 - <<'PYTHON'
from pathlib import Path
banner = Path('banners/skill-video-studio.svg').read_text()
inner = banner.replace('<svg ', '<svg x="0" y="160" ', 1)
Path('social/skill-video-studio.svg').write_text(
    '<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="640" '
    'viewBox="0 0 1280 640" role="img" aria-label="Video Studio Skill">'
    '<rect width="1280" height="640" fill="#0e0f11"/>' + inner + '</svg>\n')
PYTHON
```

Open the SVG in a modern browser to check fonts and clipping. Export to PNG with a browser or vector editor that supports embedded webfonts. If using Chromium, run from the assets checkout:

```bash
chromium --headless --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=1 --window-size=1280,640 \
  --virtual-time-budget=1500 \
  --screenshot="$PWD/social/skill-video-studio.png" \
  "file://$PWD/social/skill-video-studio.svg"
```

Copy the reviewed banner and social SVG/PNG into this skill's `assets/`, update the source revision and pinned README URL after publishing upstream, and keep the font notices. The ready-to-upload `assets/social-preview.png` is included, but must be uploaded through **GitHub Settings → General → Social preview** to activate it. Merely committing it does not set the repository preview.

## Terminal demo

The [recording guide](../examples/README.md) documents studio installation and actual Claude Code brief creation. The VHS tape overrides the shared theme with a pure black background and stops before capture/render. Existing worked video examples remain available separately.
