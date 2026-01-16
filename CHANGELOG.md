# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2025-01-16
### Added
- Error status normalization: all 422 variations (`unprocessable_entity`, `unprocessable-entity`, `unprocessable_content`, `unprocessable-content`) now serialize to `"unprocessable-entity"` for backward compatibility with Phoenix 1.6+ (RFC 9110 rename)

## [1.1.0] - 2025-01-16
### Changed
- **Breaking**: Minimum Elixir version is now 1.15 (previously 1.4)
- Updated dependencies: credo ~> 1.7, ex_doc ~> 0.30, dialyxir ~> 1.4, plug ~> 1.14
- Broadened poison version support: ~> 3.0 or ~> 4.0 or ~> 5.0 or ~> 6.0

### Added
- Optional `jason ~> 1.0` dependency as alternative JSON encoder/decoder

### Fixed
- Deprecated `use Mix.Config` replaced with `import Config`
- Deprecated `use Plug.Test` replaced with imports in tests

### Removed
- CircleCI configuration (migrated to GitHub Actions)
- Dev publish workflow

## [1.0.2] - 2022-02-14
### Fixed
- Arguments with struct values are now passed through Jabbax instead of raising an error [@vtm9](https://github.com/vtm9).

## [1.0.1] - 2021-12-21
### Added
- Support type annotations

## [1.0.0] - 2021-10-21
### Added
- Support for `body_reader`

## [0.2.1] - 2021-09-01
### Fixed
- Handle malformed body

## [0.2.0] - 2021-06-05
### Added
- Support for prefixing arguments in `ErrorSource.from_attribute`

## [0.1.0] - 2021-06-11
### Added
- CI configuration




[Unreleased]: https://github.com/surgeventures/jabbax/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/surgeventures/jabbax/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/surgeventures/jabbax/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/surgeventures/jabbax/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/surgeventures/jabbax/compare/v1.0.0...v1.0.1
[1.0.1]: https://github.com/surgeventures/jabbax/compare/v0.2.1...v1.0.0
[0.2.1]: https://github.com/surgeventures/jabbax/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/surgeventures/jabbax/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/surgeventures/jabbax/compare/v0.0.0...v0.1.0

