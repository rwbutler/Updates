![Updates](https://raw.githubusercontent.com/rwbutler/Updates/master/docs/images/updates-banner.png)

[![CI Status](https://img.shields.io/travis/rwbutler/Updates.svg?style=flat)](https://travis-ci.org/rwbutler/Updates)
[![Version](https://img.shields.io/cocoapods/v/Updates.svg?style=flat)](https://cocoapods.org/pods/Updates)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Maintainability](https://api.codeclimate.com/v1/badges/cbabaea781ab999cb673/maintainability)](https://codeclimate.com/github/rwbutler/Updates/maintainability)
[![License](https://img.shields.io/cocoapods/l/Updates.svg?style=flat)](https://cocoapods.org/pods/Updates)
[![Platform](https://img.shields.io/cocoapods/p/Updates.svg?style=flat)](https://cocoapods.org/pods/Updates)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://swift.org/)
[![Twitter](https://img.shields.io/badge/twitter-@ross_w_butler-blue.svg?style=flat)](https://twitter.com/ross_w_butler)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

Updates is a framework for automatically detecting app updates and gently prompting users to update.

To learn more about how to use Updates, take a look at the [keynote presentation](https://github.com/rwbutler/Updates/blob/master/docs/presentations/updates.pdf), check out the [blog post](https://medium.com/@rwbutler/updating-users-to-the-latest-app-release-on-ios-ed96e4c76705) or make use of the table of contents below:

- [Features](#features)
- [Quickstart](#quickstart)
- [Installation](#installation)
	- [Cocoapods](#cocoapods)
	- [Carthage](#carthage)
	- [Swift Package Manager](#swift-package-manager)
- [How It Works](#how-it-works)
- [Usage](#usage)
	- [Configuration](#configuration)
		- [Check for Updates Automatically](#check-for-updates-automatically)
		- [Manually Notify Users of Updates](#manually-notify-users-of-updates)
	- [Checking For Updates](#check-for-updates)
	- [UI Component](#ui-component)
- [FAQs](#faqs)
- [Author](#author)
- [License](#license)
- [Additional Software](#additional-software)
	- [Frameworks](#frameworks)
	- [Tools](#tools)

## Features

- [x] Automatically detect whether a new version of your app is available.
- [x] Configure framework settings remotely using a self-hosted JSON file.
- [x] UI component for presenting `SKStoreProductViewController `or directing users to the App Store directly.

## Quickstart

In order to check whether new app versions are available invoke `checkForUpdates` as follows:

```swift
Updates.checkForUpdates { result in
    UpdatesUI.promptToUpdate(result, presentingViewController: self)
}
```

Then invoke UpdatesUI to present an `SKStoreProductViewController` allowing users to update to the latest version without having to leave your app.

## Installation

### Cocoapods

[CocoaPods](http://cocoapods.org) is a dependency manager which integrates dependencies into your Xcode workspace. To install it using [RubyGems](https://rubygems.org/) run:

```bash
gem install cocoapods
```

To install Updates using Cocoapods, simply add the following line to your Podfile:

```ruby
pod "Updates"
```

Then run the command:

```bash
pod install
```

For more information [see here](https://cocoapods.org/#getstarted).

### Carthage

Carthage is a dependency manager which produces a binary for manual integration into your project. It can be installed via [Homebrew](https://brew.sh/) using the commands:

```bash
brew update
brew install carthage
```

In order to integrate Updates into your project via Carthage, add the following line to your project's Cartfile:

```ogdl
github "rwbutler/Updates"
```

From the macOS Terminal run `carthage update --platform iOS` to build the framework then drag `Updates.framework` into your Xcode project.

For more information [see here](https://github.com/Carthage/Carthage#quick-start).

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a dependency manager for Swift modules and is included as part of the build system as of Swift 3.0. It is used to automate the download, compilation and linking of dependencies.

To include Updates as a dependency within a Swift package, add the package to the `dependencies` entry in your `Package.swift` file as follows:

```swift
dependencies: [
    .package(url: "https://github.com/rwbutler/Updates.git", from: "1.0.0")
]
```

## How It Works
Updates is a framework which automatically checks to see whether a new version of your app is available. When an update is released, Updates is able to present the new version number and accompanying release notes to the user giving them the choice to update. Users electing to proceed are seamlessly presented the App Store in-app so that updating becomes effortless.

How does Updates achieve this? Firstly, it makes use of the [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/index.html) to retrieve the version number of the latest version of your app available from the store. Along with this, the release notes and numeric App Store identifier are fetched for your app which means that when a new version is released, Updates is able to tell your users the version number of the update as well as what's new.

Using the numeric App Store identifier, if the user elects to update then Updates can present the App Store allowing the user to seamlessly update without having to leave the app. 

If you would prefer to set this information manually (rather than having Updates retrieve it for you), you may do so by specifying the necessary information as part of a JSON configuration file. Furthermore, having a JSON configuration file allows you to specify whether or not Updates checks automatically or manually - you may then later toggle this setting remotely. It also possible to configure all settings programmatically.

## Usage

There are two ways of using Updates - having it check for updates automatically, or providing the update information manually via a JSON configuration file.

### Configuration
#### Check for Updates Automatically

To have Updates automatically check for new versions of your app you may configure the framework using a JSON configuration file. You need to let Updates know where to look for the file by specifying a configuration URL as follows:

```swift
Updates.configurationURL = URL(string: "https://exampledomain.com/updates.json")
```

Alternatively the URL may reference a local file / file in your app bundle using a file URL e.g.

```swift
Updates.configurationURL = Bundle.main.url(forResource: "Updates", withExtension: "json")
```

A simple configuration file might look as follows:

```json
{
    "updates": {
        "check-for": "automatically",
        "notify": "once"
    }
}
```

Note that Updates looks for a top-level key called `updates` which means that it is possible to add to an existing JSON file rather than creating an entirely new one.

The above configuration tells Updates to resolve all of the information needed to determine whether a new version of your app is available automatically with minimal configuration. It also indicates that users should only be notified once about a particular app update to avoid badgering them. Alternative values of this property are `twice`, `thrice`, `never` and `always`.

Having a remote JSON configuration allows for the greatest amount of flexibility once your app has been deployed as this makes it possible to switch from automatic to manual mode remotely and then provide the details of your app's latest update yourself should you wish to.

You may forego a remote JSON configuration and simply configure Updates programmatically if you want as follows:

```swift
Updates.updatingMode = .automatically
Updates.notifying = .once
```

This is equivalent to the configuration in the above JSON snippet.

#### Manually Notify Users of Updates

To manually notify users of updates to your app configure your JSON file as follows:

```json
{
    "updates": {
        "check-for": "manually",
        "notify": "always",
        "app-store-id": "123456",
        "comparing": "major-versions",
        "min-os-required": "12.0.0",
        "version": "2.0.0"
    }
}
```

- `check-for` specifies whether Updates should check for updates automatically or manually.
- The `notifying` parameter allows the developer to specify the number of times the user will be prompted to update.
- The `app-store-id` parameter specifies the numeric identifier for your app in the App Store. This parameter is only required should you wish to use the `UpdatesUI` component to present an `SKStoreProductViewController` allowing the user to update. If developing a custom UI, this parameter may be omitted. 
- `comparing` determines the version number increment required for users to be notified about a notify version e.g. `major-versions` indicates that users will only be notified when the app's major version number is incremented. Other possible values here are `minor-versions` and `patch-versions`.
- The `min-os-required` property ensures that if the new version of your app does not support older versions of iOS that were previously supported then users who cannot take advantage of the update are not notified about the new version.
- The `version` property indicates the new app version available from the App Store.

If you chose not to host a remote configuration file, the same configuration may be obtained programmatically:

```swift
Updates.updatingMode = .manually
Updates.notifying = .always
Updates.appStoreId: "123456"
Updates.comparingVersions: .major
Updates.minimumOSVersion: "12.0.0"
Updates.versionString: "2.0.0"
```


### Checking For Updates

Regardless of whether you have configured Updates to check for updates automatically or manually, call `checkForUpdates` in your app to be notified of new app updates as follows:

```swift
Updates.checkForUpdates { result in
    // Implement custom UI or use UpdatesUI component
}
```

The `UpdatesUI` component described in the next section can be used in conjunction with this method call to present the App Store in-app (using either a `SKStoreProductViewController` or `SFSafariViewController` in the event that the former cannot be loaded) allowing users to update seamlessly. Alternatively you may elect to implement your own custom UI in the callback.

The callback returns an `UpdatesResult` enum value indicating whether or not an update is available:

```swift
public enum UpdatesResult {
    case available(Update)
    case none
}
```

In the case that an update is available, an `Update` value is available providing the version number of the update as well as the release notes when using automatic configuration:

```swift
public struct Update {
    public let newVersionString: String
    public let releaseNotes: String?
    public let shouldNotify: Bool
}
```

Note that the value of `notify` property in your JSON configuration is used to determine whether or not `shouldNotify` is `true` or `false`. Where writing custom UI it is up to the developer to respect the value of `shouldNotify`. If using the `UpdatesUI` component this property will automatically be respected.

### UI Component

The UpdatesUI component is separate from the core Updates framework to allow developers to create a custom UI if needed. For developers who do not require a custom UI, `UpdatesUI` makes it as simple as possible for users to update. Users will be presented a `UIAlertController` asking whether to Update or Cancel. Should the user elect to update then a `SKStoreProductViewController` will be displayed allowing the update to be initiated in-app.

In order to display the UI simply pass the `UpdatesResult` value returned from the update check to the UI as follows:

```swift
Updates.checkForUpdates { result in
    UpdatesUI.promptToUpdate(result, presentingViewController: self)
}
```

The result will look as follows:

![UpdatesUI](https://raw.githubusercontent.com/rwbutler/Updates/master/docs/images/screenshot.png)

## Sample App

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## FAQs

### When I invoke `Updates.checkForUpdates` my closure is not being invoked when expected, what's wrong?

Updates uses your app's bundle identifier to invoke the iTunes Search API using a URL such as the following:

[https://itunes.apple.com/lookupbundleId=com.rwbutler.daycalculator&country=gb](https://itunes.apple.com/lookupbundleId=com.rwbutler.daycalculator&country=gb)

This allows Updates to retrieve the release notes, latest version number and App Store identifier for your app. If this process fails for you, the likelihood is that the `country` parameter has been set incorrectly. 

This parameter needs to be set to the country code for the App Store territory from which the user downloaded your app. Currently Updates retrieves this code by querying the device's current locale using `Locale.current.regionCode` however this can be overridden programmatically via the `Updates.countryCode` parameter. Once set correctly you shouldn't experience any further issues.


## Author

[Ross Butler](https://github.com/rwbutler)

## License

Updates is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.

## Additional Software

### Controls

* [AnimatedGradientView](https://github.com/rwbutler/AnimatedGradientView) - Powerful gradient animations made simple for iOS.

|[AnimatedGradientView](https://github.com/rwbutler/AnimatedGradientView) |
|:-------------------------:|
|[![AnimatedGradientView](https://raw.githubusercontent.com/rwbutler/AnimatedGradientView/master/docs/images/animated-gradient-view-logo.png)](https://github.com/rwbutler/AnimatedGradientView) 

### Frameworks

* [Cheats](https://github.com/rwbutler/Cheats) - Retro cheat codes for modern iOS apps.
* [Connectivity](https://github.com/rwbutler/Connectivity) - Improves on Reachability for determining Internet connectivity in your iOS application.
* [FeatureFlags](https://github.com/rwbutler/FeatureFlags) - Allows developers to configure feature flags, run multiple A/B or MVT tests using a bundled / remotely-hosted JSON configuration file.
* [FlexibleRowHeightGridLayout](https://github.com/rwbutler/FlexibleRowHeightGridLayout) - A UICollectionView grid layout designed to support Dynamic Type by allowing the height of each row to size to fit content.
* [Hash](https://github.com/rwbutler/Hash) - Lightweight means of generating message digests and HMACs using popular hash functions including MD5, SHA-1, SHA-256.
* [Skylark](https://github.com/rwbutler/Skylark) - Fully Swift BDD testing framework for writing Cucumber scenarios using Gherkin syntax.
* [TailorSwift](https://github.com/rwbutler/TailorSwift) - A collection of useful Swift Core Library / Foundation framework extensions.
* [TypographyKit](https://github.com/rwbutler/TypographyKit) - Consistent & accessible visual styling on iOS with Dynamic Type support.
* [Updates](https://github.com/rwbutler/Updates) - Automatically detects app updates and gently prompts users to update.

|[Cheats](https://github.com/rwbutler/Cheats) |[Connectivity](https://github.com/rwbutler/Connectivity) | [FeatureFlags](https://github.com/rwbutler/FeatureFlags) | [Skylark](https://github.com/rwbutler/Skylark) | [TypographyKit](https://github.com/rwbutler/TypographyKit) | [Updates](https://github.com/rwbutler/Updates) |
|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|
|[![Cheats](https://raw.githubusercontent.com/rwbutler/Cheats/master/docs/images/cheats-logo.png)](https://github.com/rwbutler/Cheats) |[![Connectivity](https://github.com/rwbutler/Connectivity/raw/master/ConnectivityLogo.png)](https://github.com/rwbutler/Connectivity) | [![FeatureFlags](https://raw.githubusercontent.com/rwbutler/FeatureFlags/master/docs/images/feature-flags-logo.png)](https://github.com/rwbutler/FeatureFlags) | [![Skylark](https://github.com/rwbutler/Skylark/raw/master/SkylarkLogo.png)](https://github.com/rwbutler/Skylark) | [![TypographyKit](https://raw.githubusercontent.com/rwbutler/TypographyKit/master/docs/images/typography-kit-logo.png)](https://github.com/rwbutler/TypographyKit) | [![Updates](https://raw.githubusercontent.com/rwbutler/Updates/master/docs/images/updates-logo.png)](https://github.com/rwbutler/Updates)

### Tools

* [Clear DerivedData](https://github.com/rwbutler/ClearDerivedData) - Utility to quickly clear your DerivedData directory simply by typing `cdd` from the Terminal.
* [Config Validator](https://github.com/rwbutler/ConfigValidator) - Config Validator validates & uploads your configuration files and cache clears your CDN as part of your CI process.
* [IPA Uploader](https://github.com/rwbutler/IPAUploader) - Uploads your apps to TestFlight & App Store.
* [Palette](https://github.com/rwbutler/TypographyKitPalette) - Makes your [TypographyKit](https://github.com/rwbutler/TypographyKit) color palette available in Xcode Interface Builder.

|[Config Validator](https://github.com/rwbutler/ConfigValidator) | [IPA Uploader](https://github.com/rwbutler/IPAUploader) | [Palette](https://github.com/rwbutler/TypographyKitPalette)|
|:-------------------------:|:-------------------------:|:-------------------------:|
|[![Config Validator](https://raw.githubusercontent.com/rwbutler/ConfigValidator/master/docs/images/config-validator-logo.png)](https://github.com/rwbutler/ConfigValidator) | [![IPA Uploader](https://raw.githubusercontent.com/rwbutler/IPAUploader/master/docs/images/ipa-uploader-logo.png)](https://github.com/rwbutler/IPAUploader) | [![Palette](https://raw.githubusercontent.com/rwbutler/TypographyKitPalette/master/docs/images/typography-kit-palette-logo.png)](https://github.com/rwbutler/TypographyKitPalette)
