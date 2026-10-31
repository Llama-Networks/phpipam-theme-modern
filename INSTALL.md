# Installation

The prebuilt stylesheet replaces phpIPAM's stock dark-theme stylesheet. The
bundled file is built for phpIPAM 1.8.3; rebuild and test it before using it
with another phpIPAM release.

## Requirements

- phpIPAM 1.8.3 for the prebuilt file in `dist/`
- Chrome or Edge 112+, Safari 16.5+, or Firefox 121+
- Access to the phpIPAM application files or the container configuration

The browser requirements come from native CSS nesting and `:has()` support.

## Standard installation

Set `PHPIPAM_ROOT` to the directory that contains phpIPAM's `index.php`, then
back up the stock stylesheet and install the prebuilt one:

```bash
export PHPIPAM_ROOT=/path/to/phpipam
cp "$PHPIPAM_ROOT/css/bootstrap/bootstrap-custom-dark.css" \
  "$PHPIPAM_ROOT/css/bootstrap/bootstrap-custom-dark.css.bak"
cp dist/bootstrap-custom-dark.css \
  "$PHPIPAM_ROOT/css/bootstrap/bootstrap-custom-dark.css"
```

Keep the filename and location unchanged. The upstream stylesheet contains
relative image URLs that are resolved from `css/bootstrap/`.

## Container installation

Mount the prebuilt file over the stylesheet in the web container. For the
community `phpipam/phpipam-www` image, add this volume to the existing web
service in your Compose file:

```yaml
services:
  phpipam-web:
    volumes:
      - ./dist/bootstrap-custom-dark.css:/phpipam/css/bootstrap/bootstrap-custom-dark.css:ro
```

The service name can be different. If you use another image, confirm its
phpIPAM document root and adjust the container path.

Recreate or restart the web container after changing the mount.

## Activate the theme

In phpIPAM, open **My account**, choose **Dark** under **Theme**, and save.
Hard-refresh the browser if an older stylesheet is cached.

## Roll back

- Standard installation: restore `bootstrap-custom-dark.css.bak`.
- Container installation: remove the bind mount and recreate the container.

## Build for another phpIPAM release

The generated file includes phpIPAM's stock dark stylesheet, so it must be
rebuilt whenever the phpIPAM version changes:

```bash
PHPIPAM_VERSION=1.8.3 make build
make test
```

The default version and its checksum are pinned in `scripts/build.sh`. For a
different version, supply the corresponding upstream SHA-256 as documented by
that script, then test the result in a non-production phpIPAM instance.

## Fonts and offline use

The theme makes no external font request by default. It uses locally installed
Inter and JetBrains Mono when available, then falls back to system fonts.

To load webfonts, add an `@import` at the top of `phpipam-modern.css` and
rebuild. Be aware that doing so creates a browser request to the font provider
and may require a Content Security Policy change.
