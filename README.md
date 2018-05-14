# Graffiti Framework iOS Samples &nbsp; [![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Create%20native%20iOS%20apps%20in%20Xcode%20without%20a%20code!&url=https://github.com/m8labs/GraffitiSamples&hashtags=GraffitiFramework,Xcode,iOS,codeless,apps,templates)

[![Platform](https://img.shields.io/badge/platform-iOS-aaaaaa.svg?style=flat)](#requirements)
[![Twitter](https://img.shields.io/badge/twitter-@m8labs-1da1f2.svg?style=flat)](http://twitter.com/m8labs)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


_Graffiti Framework_ provides a set of 100% reusable objects that you can tweak with parameters in JSON file or `User Defined Runtime Attributes`. And all application logic is based on `NSPredicate` and `NSExpression`, both of which can be constructed from strings. That's why _Graffiti_ apps might not contain any executable code. But it is still regular native app, and all these objects are accessible from runtime, so you can work with them in your swift/objective-c code too. Anyway, your code base will be extremely small.

For example, consider this view controller:

<p align="center">
<img width="272" src="https://raw.githubusercontent.com/m8labs/GraffitiSamples/gh-pages/images/TwitterDemo.png">
</p>

It, of cource, has all usual sophisticated features you need: login/logout, pull to refresh, infinite scroll, new tweet, delete your own tweet (but not other's tweets!), filter tweets and open tweet details. In a best case scenario for well structured code you will end up with ~200-500 lines of code for this view controller.

With _Graffiti_ it looks like this:

<p align="center">
<img width="272" src="https://raw.githubusercontent.com/m8labs/GraffitiSamples/gh-pages/images/CodeSample1.png">
</p>

Or even like this:

<p align="center">
<img width="272" height="100" src="https://raw.githubusercontent.com/m8labs/GraffitiSamples/gh-pages/images/CodeSample2.png">
</p>

If you set custom class for this view controller to `StandardViewController` or `ContentViewController` directly.

Keep in mind that this is not a set of predefined `UIView` objects, but a set of `NSObject` descendants. You are free to have any UI you want.

Furthermore, absence of code gives you an enormous advantages in every aspect of your product development. You app doesn't crash (because absence of code). You can load your view controllers on the fly from any remote location (or even entire app if it was built without custom code). You are free from maintaining tons of unit tests. You can do any amount of A/B testing and not even bother with AppStore approval process. This is truly magical way of making apps. And it is still 100% compatible with Xcode. 

### Features:
- Form submission with Image/Video upload
- Any JSON-based backend integration
- Infinite scrolling, pull to refresh
- CoreData background processing
- Google Maps (places api, search autocompletion api)
- Background calculation of repeatable content geometry
- Codeless access to all phone data, such as photos, contacts, music etc.
- Dynamic UI loading. Your native view controllers can be kinda web-pages
- SocketIO integration for real time apps*<br/>
<sup><sub>* - _Upcoming release_</sub></sup>

_TwitterDemo_ contains detailed comments in swift and JSON files. Playing with settings and `SchemeDiagnosticsProtocol` will help you to understand how things work. There are also some custom code to demonstrate how you can do it.

Also, checkout our _TwitterDemoX_ sample. In addition to features of _TwitterDemo_, it has:

- Post tweets with images
- Delete own tweets
- Background cell height calculation (experimental)
- Filter tweets
- Different type of cells
- Night mode theme

<p align="center">
<img width="384" src="https://github.com/m8labs/GraffitiSamples/raw/gh-pages/images/TwitterDemoX.gif">
</p>
<p align="center">GIF (16Mb)</p>

Download _TwitterDemoX_ sample <b>[here](http://gum.co/GRAFS1)</b>

### Working with Google Maps

###### GoogleMapsDemo

This sample demonstrate how you can use maps in codeless apps. How to search objects of a particular type, open its properties and sending requests with coordinates of an object.

<p align="center">
<img width="272" src="https://github.com/m8labs/GraffitiSamples/raw/gh-pages/images/GoogleMapsDemo.png">
</p>


###### GoogleMapsDemoX

If you need more complex maps handling, check out our _GoogleMapsDemoX_ sample. It can search address with suggestions and pick an exact address in case of search gives more than one option:

<p align="center">
<img width="272" src="https://github.com/m8labs/GraffitiSamples/raw/gh-pages/images/GoogleMapsDemoX.png">
</p>

Download _GoogleMapsDemoX_ sample <b>[here](http://gum.co/GRAFS2)</b>

Both _GoogleMapsDemo_ and _GoogleMapsDemoX_ based on _GraffitiGoogleKit_ which is open source and included in these samples sources directly.


## Requirements

- iOS 10.0+
- Xcode 9.3
- Swift 4.1


## Installation

_TwitterDemo_ and _TwitterDemoX_ already prepared for installation via Carthage and CocoaPods.<br/>
_GoogleMapsDemo_ and _GoogleMapsDemoX_ can't be installed via Carthage, because of _GoogleMaps_ library which doesn't support Carthage.

#### Carthage

If you havn't Carthage installed yet, you can do it with [Homebrew](http://brew.sh/):

```bash
$ brew update
$ brew install carthage
```

Then `cd` to the projects' directory (_TwitterDemo_ or _TwitterDemoX_) and run command:

```bash
$ carthage update --configuration Debug --platform ios
```

Now open Xcode project, build and run.

#### CocoaPods

##### ️️❗️CocoaPods Notice❗️

If your prefer CocoaPods, then after you open workspace, don't forget to remove _Frameworks_ group (it's for Carthage) which is inside `TwitterDemo` Xcode project's group (next to `Main.storyboard`). Don't mess up with the CocoaPods' _Frameworks_ group, which is in the project's root:
<p align="center">
<img width="272" src="https://github.com/m8labs/GraffitiSamples/raw/gh-pages/images/XcodePodsNotice.png">
</p>

If you havn't [CocoaPods](http://cocoapods.org) installed yet, you can do it with the following command:

```bash
$ gem install cocoapods
```

Then `cd` to the projects' directory (_TwitterDemo_ or _GoogleMapsDemo_) and run command:

```bash
$ pod install
```

Open Xcode workspace, and in the case of _TwitterDemo_ and _TwitterDemoX_ you should remove _Frameworks_ group (see notice above). Otherwise linker will show errors. Then build and run.


If you experience problems with connection to Twitter API, create your own app at apps.twitter.com and replace `Consumer Key`/`Consumer Secret` in Service.json file. You will need to uncheck `Enable Callback Locking` on the Twitter API settings page.

Don't forget to set default location in Xcode while running _GoogleMapsDemo_ or _GoogleMapsDemoX_:
<p align="center">
<img width="700" src="https://github.com/m8labs/GraffitiSamples/raw/gh-pages/images/XcodeSetLocation.png">
</p>
<br/>

## How to begin

Start new project with your model. _Graffiti_ uses _Groot_ library to build `CoreData` object graph. Refer to its [documentation](https://github.com/gonzalezreal/Groot) on how to adopt your model to it. In brief, you will need to set `User Info` for each attribute you want to parse from JSON. Also, there are some _Graffiti_ `User Info` variables, that responsible for user objects ownership. Inspect the model in _TwitterDemo_ for details.

## Contacts

- For help, use [Stack Overflow](http://stackoverflow.com/questions/tagged/GraffitiFramework) (Tag `GraffitiFramework`).
- If you found a bug open an issue.
- For other questions feel free to communicate on Twitter [@m8labs](https://twitter.com/m8labs). Use direct messages or `GraffitiFramework` hashtag.<br/>
- Earn up to 70% of all apps of your clients that use _Graffiti_ with our [affiliates program](http://graffiti.m8labs.com/a)
- Tell your friends about us&nbsp;&nbsp;[![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Create%20native%20iOS%20apps%20in%20Xcode%20without%20a%20code!&url=https://github.com/m8labs/GraffitiSamples&hashtags=GraffitiFramework,Xcode,iOS,codeless,apps,templates)


## License & Copyright
_"Graffiti Framework iOS Samples"_ is distributed under the BSD license, Copyright 2018 M8 Labs ([m8labs.com](http://m8labs.com))<br/>
_"Graffiti Framework"_ is distributed in binary form. You can purchase your license <b>[here](http://gumroad.com/m8labs)</b>. It's free while development.

### Disclaimer
_"Twitter"_, _"Google Maps"_, _"Swift"_, _"Gumroad"_ and all associated graphic images (if present) are trademarks™ or registered® trademarks of their respective holders and used on this page only for reference and/or educational purposes and does not imply any affiliation with or endorsement by them.