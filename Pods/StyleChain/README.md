# StyleChain

[![CI Status](https://img.shields.io/travis/G-Xi0N/StyleChain.svg?style=flat)](https://travis-ci.org/G-Xi0N/StyleChain)
[![Version](https://img.shields.io/cocoapods/v/StyleChain.svg?style=flat)](https://cocoapods.org/pods/StyleChain)
[![License](https://img.shields.io/cocoapods/l/StyleChain.svg?style=flat)](https://cocoapods.org/pods/StyleChain)
[![Platform](https://img.shields.io/cocoapods/p/StyleChain.svg?style=flat)](https://cocoapods.org/pods/StyleChain)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

StyleChain is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'StyleChain'
```

## Usage

``` swift
UIButton()
    .style
    .frame(CGRect(x: 0, y: 0, width: 120, height: 30))
    .center(view.center)
    .backgroundColor(UIColor.red)
    .title("Hello World", for: .normal)
    .titleColor(UIColor.white, for: .normal)
    .isEnabled(false)
    .cornerRadius(15)
    .masksToBounds(true)
    .systemFont(of: 15)
    .installed
```

## Author

G-Xi0N, gao497868860@163.com

## License

StyleChain is available under the MIT license. See the LICENSE file for more info.
