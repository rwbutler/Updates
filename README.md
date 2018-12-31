![Updates](https://raw.githubusercontent.com/rwbutler/Updates/master/docs/images/updates-banner.png)

[![CI Status](https://img.shields.io/travis/rwbutler/Updates.svg?style=flat)](https://travis-ci.org/rwbutler/Updates)
[![Version](https://img.shields.io/cocoapods/v/Updates.svg?style=flat)](https://cocoapods.org/pods/Updates)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Maintainability](https://api.codeclimate.com/v1/badges/cbabaea781ab999cb673/maintainability)](https://codeclimate.com/github/rwbutler/Updates/maintainability)
[![License](https://img.shields.io/cocoapods/l/Updates.svg?style=flat)](https://cocoapods.org/pods/Updates)
[![Platform](https://img.shields.io/cocoapods/p/Updates.svg?style=flat)](https://cocoapods.org/pods/Updates)
[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://swift.org/)

# ⚠️ Currently Work In Progress 

- [Features](#features)
- [Installation](#installation)
	- [Cocoapods](#cocoapods)
	- [Carthage](#carthage)
- [Usage](#usage)

## Features

- [x] Automatically detect whether a new version of your app is available.
- [x] UI component for presenting SKStoreProductViewController or directing users to the App Store directly.

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

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Ross Butler

## License

Updates is available under the MIT license. See the LICENSE file for more info.

## Additional Software

### Frameworks

* [Connectivity](https://github.com/rwbutler/Connectivity) - Improves on Reachability for determining Internet connectivity in your iOS application.
* [FeatureFlags](https://github.com/rwbutler/FeatureFlags) - Allows developers to configure feature flags, run multiple A/B or MVT tests using a bundled / remotely-hosted JSON configuration file.
* [Skylark](https://github.com/rwbutler/Skylark) - Fully Swift BDD testing framework for writing Cucumber scenarios using Gherkin syntax.
* [TailorSwift](https://github.com/rwbutler/TailorSwift) - A collection of useful Swift Core Library / Foundation framework extensions.
* [TypographyKit](https://github.com/rwbutler/TypographyKit) - Consistent & accessible visual styling on iOS with Dynamic Type support.

### Tools

* [Config Validator](https://github.com/rwbutler/ConfigValidator) - Config Validator validates & uploads your configuration files and cache clears your CDN as part of your CI process.
* [IPA Uploader](https://github.com/rwbutler/IPAUploader) - Uploads your apps to TestFlight & App Store.
* [Palette](https://github.com/rwbutler/TypographyKitPalette) - Makes your [TypographyKit](https://github.com/rwbutler/TypographyKit) color palette available in Xcode Interface Builder.


|[Config Validator](https://github.com/rwbutler/ConfigValidator) | [Connectivity](https://github.com/rwbutler/Connectivity) | [FeatureFlags](https://github.com/rwbutler/FeatureFlags) | [IPA Uploader](https://github.com/rwbutler/IPAUploader) | [Skylark](https://github.com/rwbutler/Skylark) | [TypographyKit](https://github.com/rwbutler/TypographyKit) | [Palette](https://github.com/rwbutler/TypographyKitPalette)|
|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|
|[![Config Validator](https://raw.githubusercontent.com/rwbutler/ConfigValidator/master/docs/images/config-validator-logo.png)](https://github.com/rwbutler/ConfigValidator) | [![Connectivity](https://github.com/rwbutler/Connectivity/raw/master/ConnectivityLogo.png)](https://github.com/rwbutler/Connectivity) | [![FeatureFlags](https://raw.githubusercontent.com/rwbutler/FeatureFlags/master/docs/images/feature-flags-logo.png)](https://github.com/rwbutler/FeatureFlags) | [![IPA Uploader](https://raw.githubusercontent.com/rwbutler/IPAUploader/master/docs/images/ipa-uploader-logo.png)](https://github.com/rwbutler/IPAUploader) | [![Skylark](https://github.com/rwbutler/Skylark/raw/master/SkylarkLogo.png)](https://github.com/rwbutler/Skylark) | [![TypographyKit](https://github.com/rwbutler/TypographyKit/raw/master/TypographyKitLogo.png)](https://github.com/rwbutler/TypographyKit) | [![Palette](https://raw.githubusercontent.com/rwbutler/TypographyKitPalette/master/docs/images/typography-kit-palette-logo.png)](https://github.com/rwbutler/TypographyKitPalette)