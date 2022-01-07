<img width="100" src="images/icon.png">

# Swiftly Redux

![](https://img.shields.io/github/v/tag/wvabrinskas/SwiftlyRedux?style=flat-square)
![](https://img.shields.io/github/license/wvabrinskas/SwiftlyRedux?style=flat-square)
![](https://img.shields.io/badge/swift-5.2+-orange?style=flat-square)
![](https://img.shields.io/badge/iOS-13+-darkcyan?style=flat-square)
![](https://img.shields.io/badge/macOS-10.15+-darkcyan?style=flat-square)
![](https://img.shields.io/badge/watchOS-6+-darkcyan?style=flat-square)
![](https://img.shields.io/badge/tvOS-13+-darkcyan?style=flat-square)

[![Tests](https://github.com/wvabrinskas/SwiftlyRedux/actions/workflows/Tests.yml/badge.svg?branch=master)](https://github.com/wvabrinskas/SwiftlyRedux/actions/workflows/Tests.yml)
  - A swift package that creates a new architecture for iOS development. It is very similiar to redux where there is one source of truth with a state manager object. 
  - This framework makes a major improvement to the redux architecture in that you can directly access members of the state and call updates to subjects all with type safety without ambiguity as to what you're updating. 
  - It is an incredibly modular architecure where the state calls out to its submodules without actually knowing what those modules do. Each module can be updated indvidually and pass its updates to the state object.
  - This allows for your app to be easily testable.
  - Combine support. 
  - Swift package support


  - More info to come... 