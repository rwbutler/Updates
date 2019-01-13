![Updates](https://raw.githubusercontent.com/rwbutler/Updates/master/docs/images/updates-banner.png)

[![CI Status](https://img.shields.io/travis/rwbutler/Updates.svg?style=flat)](https://travis-ci.org/rwbutler/Updates)
[![Version](https://img.shields.io/cocoapods/v/Updates.svg?style=flat)](https://cocoapods.org/pods/Updates)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Maintainability](https://api.codeclimate.com/v1/badges/cbabaea781ab999cb673/maintainability)](https://codeclimate.com/github/rwbutler/Updates/maintainability)
[![License](https://img.shields.io/cocoapods/l/Updates.svg?style=flat)](https://cocoapods.org/pods/Updates)
[![Platform](https://img.shields.io/cocoapods/p/Updates.svg?style=flat)](https://cocoapods.org/pods/Updates)
[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://swift.org/)

Updates is a framework for automatically detecting app updates and gently prompting users to update.

# ⚠️ Currently Work In Progress 
Updates will be available for production use on reaching version 1.0.0.

To learn more about how to use Updates, take a look at the [keynote presentation](https://github.com/rwbutler/Updates/blob/master/docs/presentations/updates.pdf), or make use of the table of contents below:

- [Features](#features)
- [Quickstart](#quickstart)
- [Installation](#installation)
	- [Cocoapods](#cocoapods)
	- [Carthage](#carthage)
- [How It Works](#how-it-works)
- [Usage](#usage)
- [Author](#author)
- [License](#license)
- [Additional Software](#additional-software)
	- [Frameworks](#frameworks)
	- [Tools](#tools)

## Features

- [x] Automatically detect whether a new version of your app is available.
- [x] UI component for presenting SKStoreProductViewController or directing users to the App Store directly.

## Quickstart

In order to check whether new app versions are available invoke `checkForUpdates` as follows:

```swift
Updates.checkForUpdates { result in
    UpdatesUI.promptToUpdate(result, presentingViewController: self)
}
```

The `notifying` parameter allows the developer to specify the number of times the user will be prompted to update.

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

## How It Works
Updates is a framework which automatically checks to see whether a new version of your app is available. When an update is released, Updates is able to present the new version number and accompanying release notes to the user giving them the choice to update. Users electing to proceed are seamlessly presented the App Store in-app so that updating becomes effortless.

How does Updates achieve this? Firstly, it makes use of the [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/index.html) to retrieve the version number of the latest version of your app available from the store. Along with this, the release notes and numeric App Store identifier are fetched for your app which means that when a new version is released, Updates is able to tell your users the version number of the update as well as what's new.

Using the numeric App Store identifier, if the user elects to update then Updates can present the App Store allowing the user to seamlessly update without ever the app. 

If you would prefer to set this information manually (rather than having Updates retrieve it for you), you may do so by specifying a JSON configuration file. Furthermore, having a JSON configuration file allows you to specify whether or not Updates checks automatically or manually - you may then later toggle this setting remotely. Alternatively, everything can be configured programmatically in the case that this is preferred.

## Usage

There are two ways of using Updates - having it check for updates automatically, or providing the update information manually via a JSON configuration file.

### Configuration

#### Check for updates automatically

To have Updates automatically check for new versions of your app you may configure the framework using a JSON configuration file. You need to let Updates know where to look for the file by specifying a configuration URL as follows:

```
Updates.configurationURL = URL(string: "https://exampledomain.com/updates.json")
```

Alternatively the URL may reference a local file / file in your app bundle using a file URL e.g.

```
Updates.configurationURL = Bundle.main.url(forResource: "Updates", withExtension: "json")
```

A simple configuration file might look as follows:

```
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

```
Updates.updatingMode = .automatically
Updates.notifying = .once
```

This is equivalent to the configuration in the above JSON snippet.

#### Notify of updates manually

In order to check whether new app versions are available invoke `checkForUpdates` as follows:

```swift
Updates.checkForUpdates { result in
    UpdatesUI.promptToUpdate(result, presentingViewController: self)
}
```

The `notifying` parameter allows the developer to specify the number of times the user will be prompted to update.

## Sample App

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Ross Butler

## License

Updates is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.

## Additional Software

### Frameworks

* [Connectivity](https://github.com/rwbutler/Connectivity) - Improves on Reachability for determining Internet connectivity in your iOS application.
* [FeatureFlags](https://github.com/rwbutler/FeatureFlags) - Allows developers to configure feature flags, run multiple A/B or MVT tests using a bundled / remotely-hosted JSON configuration file.
* [Skylark](https://github.com/rwbutler/Skylark) - Fully Swift BDD testing framework for writing Cucumber scenarios using Gherkin syntax.
* [TailorSwift](https://github.com/rwbutler/TailorSwift) - A collection of useful Swift Core Library / Foundation framework extensions.
* [TypographyKit](https://github.com/rwbutler/TypographyKit) - Consistent & accessible visual styling on iOS with Dynamic Type support.
* [Updates](https://github.com/rwbutler/Updates) - Automatically detects app updates and gently prompts users to update.

|[Connectivity](https://github.com/rwbutler/Connectivity) | [FeatureFlags](https://github.com/rwbutler/FeatureFlags) | [Skylark](https://github.com/rwbutler/Skylark) | [TypographyKit](https://github.com/rwbutler/TypographyKit) | [Updates](https://github.com/rwbutler/Updates) |
|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|
|[![Connectivity](https://github.com/rwbutler/Connectivity/raw/master/ConnectivityLogo.png)](https://github.com/rwbutler/Connectivity) | [![FeatureFlags](https://raw.githubusercontent.com/rwbutler/FeatureFlags/master/docs/images/feature-flags-logo.png)](https://github.com/rwbutler/FeatureFlags) | [![Skylark](https://github.com/rwbutler/Skylark/raw/master/SkylarkLogo.png)](https://github.com/rwbutler/Skylark) | [![TypographyKit](https://github.com/rwbutler/TypographyKit/raw/master/TypographyKitLogo.png)](https://github.com/rwbutler/TypographyKit) | [![Updates](https://raw.githubusercontent.com/rwbutler/Updates/master/docs/images/updates-logo.png)](https://github.com/rwbutler/Updates)

### Tools

* [Config Validator](https://github.com/rwbutler/ConfigValidator) - Config Validator validates & uploads your configuration files and cache clears your CDN as part of your CI process.
* [IPA Uploader](https://github.com/rwbutler/IPAUploader) - Uploads your apps to TestFlight & App Store.
* [Palette](https://github.com/rwbutler/TypographyKitPalette) - Makes your [TypographyKit](https://github.com/rwbutler/TypographyKit) color palette available in Xcode Interface Builder.

|[Config Validator](https://github.com/rwbutler/ConfigValidator) | [IPA Uploader](https://github.com/rwbutler/IPAUploader) | [Palette](https://github.com/rwbutler/TypographyKitPalette)|
|:-------------------------:|:-------------------------:|:-------------------------:|
|[![Config Validator](https://raw.githubusercontent.com/rwbutler/ConfigValidator/master/docs/images/config-validator-logo.png)](https://github.com/rwbutler/ConfigValidator) | [![IPA Uploader](https://raw.githubusercontent.com/rwbutler/IPAUploader/master/docs/images/ipa-uploader-logo.png)](https://github.com/rwbutler/IPAUploader) | [![Palette](https://raw.githubusercontent.com/rwbutler/TypographyKitPalette/master/docs/images/typography-kit-palette-logo.png)](https://github.com/rwbutler/TypographyKitPalette)