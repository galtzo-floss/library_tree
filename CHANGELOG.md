# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog v1](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning v2](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.0.0-alpha.3] - 2025-08-11
- TAG: [v1.0.0-alpha.3][1.0.0-alpha.3t]
- COVERAGE: 100.00% -- 283/283 lines in 8 files
- BRANCH COVERAGE: 100.00% -- 93/93 branches in 8 files
- 98.25% documented
### Added
- Global override for environment variable prefix via `ENV['FLOSS_FUNDING_ENV_PREFIX']`. Set to an empty string to disable any prefix entirely.
- Global override to disable and silence LibraryTree entirely.
  - Set `ENV['FLOSS_FUNDING_SILENT']` to a value of `"CATHEDRAL_OR_BAZAAR"` (case insensitive match) to disable and silence LibraryTree entirely.
  - Any other value will allow LibraryTree to run normally.
### Changed
- (BREAKING) Moved `DEFAULT_PREFIX` and `SILENT` constants into `LibraryTree::Constants` and updated all usages to reference `::LibraryTree::Constants::DEFAULT_PREFIX` and `::LibraryTree::Constants::SILENT`.
- Replaced hard-coded "FLOSS_FUNDING_" magic strings with `::LibraryTree::Constants::DEFAULT_PREFIX` where applicable.
- Updated documentation, RBS signatures, and specs to reflect the new Constants module and global prefix behavior.
### Deprecated
### Removed
- (BREAKING) Removed per-library ability to override the ENV prefix via `:env_prefix` option to `LibraryTree::Poke.new`. A single process-wide override is now supported via `ENV['FLOSS_FUNDING_ENV_PREFIX']`.
- (BREAKING) Removed `UnderBar::DEFAULT_PREFIX` constant.
### Fixed
- Clarified examples and error messages referencing how to set the ENV variable name.
### Security

## [1.0.0-alpha.2] - 2025-08-10
- TAG: [v1.0.0-alpha.2][1.0.0-alpha.2t]
- COVERAGE: 100.00% -- 263/263 lines in 6 files
- BRANCH COVERAGE: 100.00% -- 85/85 branches in 6 files
- 100.00% documented
### Added
- More documentation
### Fixed
- Required `base.txt` added to gem package
- Documentation typos

## [1.0.0-alpha.1] - 2025-08-10
- TAG: [v1.0.0-alpha.1][1.0.0-alpha.1t]
- COVERAGE: 100.00% -- 262/262 lines in 6 files
- BRANCH COVERAGE: 100.00% -- 85/85 branches in 6 files
- 100.00% documented
### Added
- Initial release

[Unreleased]: https://gitlab.com/galtzo-floss/library_tree/-/compare/v1.0.0-alpha.3...main
[1.0.0-alpha.3]: https://gitlab.com/galtzo-floss/library_tree/-/compare/v1.0.0-alpha.2...v1.0.0-alpha.3
[1.0.0-alpha.3t]: https://gitlab.com/galtzo-floss/library_tree/-/tags/v1.0.0-alpha.3
[1.0.0-alpha.2]: https://gitlab.com/galtzo-floss/library_tree/-/compare/v1.0.0-alpha.1...v1.0.0-alpha.2
[1.0.0-alpha.2t]: https://gitlab.com/galtzo-floss/library_tree/-/tags/v1.0.0-alpha.2
[1.0.0-alpha.1]: https://gitlab.com/galtzo-floss/library_tree/-/compare/389ece6fb9bd04013d11edca6fb6830139a84f4c...v1.0.0-alpha.1
[1.0.0-alpha.1t]: https://gitlab.com/galtzo-floss/library_tree/-/tags/v1.0.0-alpha.1
