# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2019-10-03
### Changed
- Fixed a bug whereby the `SKStoreProductViewController` would be dismissed immediately after being presented.

## [1.1.0] - 2019-08-08
### Added
- Support for Swift Package Manager.
### Changed
- Improved support for app extensions (by avoiding referencing `UIDevice.current.systemVersion` directly in `Updates.swift`).

## [1.0.0] - 2019-07-18
### Changed
- Updated to Swift 5.0

## [0.3.0] - 2019-03-04
### Added
- Able to determine whether app has recently been installed (using `isFirstLaunchFollowingInstall` ) or updated (using `isFirstLaunchFollowingUpdate`).

## [0.2.1] - 2019-01-14
### Added
- Significant improvements to documentation.

## [0.2.0] - 2019-01-09
### Added
- Added caching for the situation where remote configuration cannot be fetched.

## [0.1.0] - 2019-01-08
### Added
- Added ability to configure update checking manually.

## [0.0.2] - 2018-12-31
### Added
- Added UpdatesUI component for presenting SKStoreProductViewController.

## [0.0.1] - 2018-12-27
### Added
- Initial release.
