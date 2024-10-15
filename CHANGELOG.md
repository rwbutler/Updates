# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-10-15
### Added
- Added PrivacyInfo.xcprivacy

### Changed
- Applied Xcode 16 recommended build settings.
- Base deployment target updated from iOS 9.3 to iOS 12.0 in-line with Xcode 16 support.
- Default branch now `main` rather than `master`.

## [1.6.1] - 2022-09-26
### Changed
- Added a public `init` for `UpdatesResult` to make unit testing easier in consumer projects.

## [1.6.0] - 2021-10-10
### Added
- Added another `promptToUpdate` function which does not require an `UpdatesResult` object which means that the function can be used without having to pass an `UpdatesResult` object around the calling app.
- `UpdatesResult` now has the App Store URL for the calling app if it is possible to form it from the required parameters.

## [1.5.0] - 2021-10-05
### Added
- Added properties `minOptionalAppVersion` and `minRequiredAppVersion` with the latter taking precedence if both are set to a version string. If the former is set then the update type value will be `.soft` i.e. a soft update whereas if the latter is set then the update type will be `.hard` indicating that a different UI should be displayed to the user. 

Note: At the current time UpdatesUI largely behaves the same for both type of update but for `.hard` updates the cancel button is omitted meaning that the user must press the Update button to quit the dialog - it is recommended to implement your own UI here instead.

## [1.4.0] - 2021-06-16
### Added
- Added property `isUpdated` which can be used to determine whether the current app launch is the first one since an install or update has occurred.
- Added property `updateType` which can be used to determine whether an update is *hard* or *soft*. If using UpdatesUI then for hard updates the cancel button will not be shown when the update dialog is presented.
### Changed
- Removed properties `isFirstLaunchFollowingInstall` and `isFirstLaunchFollowingUpdate` as they didn't function without calling `checkForUpdates` first.

## [1.3.1] - 2021-06-15
### Added
- Added `useStoreKit` flag.

## [1.3.0] - 2021-02-23
### Added
- Added notification mode `.withoutAvailableUpdate` which notifies on every invocation of `checkForUpdates` even where no update is available. Can be used for testing purposes.

## [1.2.4] - 2021-02-22
### Changed
- Fixed an issue which would result in the user always being notified about an update regardless of the value of the `NotificationMode` preference.

## [1.2.3] - 2021-02-22
### Changed
- Fixed an issue whereby the result could be returned as `.none` where information was missing from the user's `Updates.json` file.

## [1.2.2] - 2019-12-18
### Changed
- Fixed an issue whereby Updates could falsely indicate that a new app version was available.

## [1.2.1] - 2019-11-22
### Changed
- Ensured that the `countryCode` property can be detected correctly on the macOS Catalyst platform as well as on iOS.

## [1.2.0] - 2019-11-17
### Added
- `UIAlertController` button titles can be set using localization keys `updates.update-button-title` and `updates.cancel-button-title`.

## [1.1.2] - 2019-11-01
### Changed
- Uses `SKStoreFront` on iOS 13 to improve accuracy of country code used for iTunes Search API calls.

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
