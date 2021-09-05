---
date: 2021-02-04 07:54
description: Tagging in swift documentation to link to another place in the code base
tags: swift,Xcode
tagColors: swift=1d76db,Xcode=006b75
---
# Tag - Swift documentation markup

[Swift documentation markup](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/) is not clear how to link to other type definition/method/... from the documentation.
It can be done using `Tag` element.

```swift
/// An error
/// - Tag: SomeError
enum SomeError: Error {
}

/// Description
/// - Throws: An error of type [SomeError](x-source-tag://SomeError) might be thrown
func doSomething() throws {
    throw NSError(domain: "", code: 1, userInfo: nil)
}
```

If you do the quick help (`⌥ + click`) on the method `doSomething` the documentation will be presented with the clickable link `SomeError` that will navigate to the place where the tag is defined.

![Screenshot 2021-02-04 at 08 39 47](https://user-images.githubusercontent.com/1753816/106861707-66d93200-66c6-11eb-93f5-e3bf106fa9a5.png)
