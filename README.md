# phpIPAM Modern

phpIPAM Modern is an unofficial dark-theme layer for
[phpIPAM](https://github.com/phpipam/phpipam). It keeps phpIPAM's existing
markup and behavior while updating the visual system with a compact layout,
clearer hierarchy, consistent controls, and customizable design tokens.

The ready-to-install file in `dist/` combines phpIPAM's stock dark stylesheet
with the Modern overrides and can be used as a drop-in replacement.

## Compatibility

- The prebuilt stylesheet is based on phpIPAM 1.8.3.
- The override layer targets phpIPAM 1.8.x, but releases other than 1.8.3 must
  be rebuilt and tested against their matching stock stylesheet.
- Supported browsers are Chrome and Edge 112+, Safari 16.5+, and Firefox 121+.

## Quick start

Back up the stock file, then copy the prebuilt stylesheet into phpIPAM:

```bash
export PHPIPAM_ROOT=/path/to/phpipam
cp "$PHPIPAM_ROOT/css/bootstrap/bootstrap-custom-dark.css" \
  "$PHPIPAM_ROOT/css/bootstrap/bootstrap-custom-dark.css.bak"
cp dist/bootstrap-custom-dark.css \
  "$PHPIPAM_ROOT/css/bootstrap/bootstrap-custom-dark.css"
```

Select **Dark** in **My account → Theme**, then hard-refresh the browser.

Container bind-mount instructions, rollback steps, and upgrade guidance are in
[INSTALL.md](INSTALL.md).

## Customize

Edit the custom properties at the top of `phpipam-modern.css` to change colors,
radii, shadows, and fonts. The theme has no external font dependency by
default; it uses locally installed Inter and JetBrains Mono when available and
otherwise falls back to system fonts.

After making a change, rebuild and verify the generated file:

```bash
make build
make test
```

The build downloads the stock stylesheet for the configured phpIPAM version
and verifies its SHA-256 before combining it with the theme layer. See
[CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow.

Building requires a POSIX shell, `curl`, and either `sha256sum` or `shasum`.
The test suite also runs `shellcheck` when it is installed; CI always runs it.

## Repository layout

| Path | Purpose |
| --- | --- |
| `phpipam-modern.css` | Source for the Modern override layer |
| `dist/bootstrap-custom-dark.css` | Generated, ready-to-install stylesheet |
| `scripts/build.sh` | Reproducible build script |
| `scripts/check.sh` | Full repository validation |

## License and attribution

This project is licensed under the GNU General Public License v3.0 only. The
generated stylesheet contains GPL-licensed phpIPAM CSS; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for its source and checksum.

phpIPAM Modern is an independent community project and is not affiliated with
or endorsed by the phpIPAM project.
