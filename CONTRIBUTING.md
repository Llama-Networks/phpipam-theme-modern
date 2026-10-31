# Contributing

Contributions are welcome. Keep changes focused on the theme layer and avoid
adding deployment-specific hostnames, paths, service names, or credentials.

## Development workflow

1. Edit `phpipam-modern.css`.
2. Run `make build` to regenerate `dist/bootstrap-custom-dark.css`.
3. Run `make test` to execute the full validation suite.
4. Test the result in a non-production phpIPAM instance using the Dark theme.

Check responsive layouts and the main navigation, tables, forms, dialogs, and
login page in a supported browser. If a change depends on a particular phpIPAM
release, document that dependency in the pull request.

Do not edit the generated file in `dist/` directly. Changes to the supported
phpIPAM version must also update the pinned upstream checksum, documentation,
and third-party notice.

By contributing, you agree that your contribution is licensed under the
repository's GPL-3.0-only license.
