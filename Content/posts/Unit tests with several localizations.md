---
date: 2022-04-27 17:38
description: Unit tests with several localizations
tags: swift,Xcode,tests
tagColors: swift=1d76db,Xcode=006b75,tests=D57125
---
# How to make unit tests with several localizations

Since Xcode 11 there is a possibility to configure different locales for unit tests by using [Test Plans](https://developer.apple.com/videos/play/wwdc2019/413/). It is fine, but a little bit cumbersome as requires the Xcode-specific configuration.
 
Another way of making it work is the old-school method swizzling.
It is quite simple to do and does its job with quite nice flexibility. It doesn't require any Xcode setup, works well with SPM too.
The idea could be also extended to customize not only the [`Locale`](https://developer.apple.com/documentation/foundation/locale), but also e.g. [`preferredlanguages`](https://developer.apple.com/documentation/foundation/locale/2293155-preferredlanguages).
The key point is that we can do it by exchanging the methods on `NSLocale` instead of `Locale` which still is used as a wrapper over [the objective-c predecessor](https://github.com/apple/swift-corelibs-foundation/blob/bfead15ba7a547a8e2ea79dfd8be97de1153245d/Sources/Foundation/Locale.swift).

We can use `method_setImplementation` and [`@convention(block)`](https://apple-swift.readthedocs.io/en/latest/SIL.html) ([swift documentation](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html)) in this case, which makes it a little bit more ergonomic than defining the `@objc` method that would solve the purpose of the exchanged method.


```swift
extension XCTestCase {
   func setLocale(identifier: String, preferredLanguages: [String]) {
        let currentlLocale: @convention(block) (AnyObject)
            -> AnyObject = { (_: AnyObject!) -> NSLocale in
                return NSLocale(localeIdentifier: identifier)
            }

        method_setImplementation(
            class_getClassMethod(NSLocale.self, #selector(getter: NSLocale.current))!,
            imp_implementationWithBlock(currentlLocale)
        )

        let preferredLanguages: @convention(block) (AnyObject)
            -> [String] = { (_: AnyObject!) -> [String] in
                return preferredLanguages
            }

        method_setImplementation(
            class_getClassMethod(NSLocale.self, #selector(getter: NSLocale.preferredLanguages))!,
            imp_implementationWithBlock(preferredLanguages)
        )
    }
}
```

Having that we can easily change the `Locale` for each test. The only downside is that you still use singleton `Locale.current`, so running tests in parallel will not work reliably.

```swift
class Test: XCTestCase {
    func test_locale() {
        setLocale(identifier: "fr", preferredLanguages: ["fr", "de", "pl"])

        XCTAssertEqual(Locale.current, .init(identifier: "fr"))
        XCTAssertEqual(Locale.preferredLanguages, ["fr", "de", "pl"])
    }
}
```