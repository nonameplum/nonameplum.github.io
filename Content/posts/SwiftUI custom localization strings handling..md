---
date: 2022-04-12 13:29
description: SwiftUI custom localization strings handling.
tags: swift,SwiftUI
tagColors: swift=1d76db,SwiftUI=F6DA24
---
# How to handle localized strings from a separate bundle or framework in SwiftUI

SwiftUI provides [`LocalizedStringKey`](https://developer.apple.com/documentation/swiftui/localizedstringkey) that can be used to initialize several `View` types, such as `Text`, `Toggle`, and others.
It works differently from UIKit in that regard, as if the localized strings leave in some other bundle than the main one from where by default SwiftUI tries to get the values, you have to pass that information to the `Text` [constructor](https://developer.apple.com/documentation/swiftui/text/init(_:tablename:bundle:comment:)) (not to `LocalizedStringKey`), in contrast to [`NSLocalizedString`](https://developer.apple.com/documentation/foundation/1418095-nslocalizedstring).

It is connected to the fact that SwiftUI internally handles the possibility to easily override the locale used by the view.

```swift
view.environment(\.locale, .init(identifier: "pl"))
```

It is very handy, especially in the case of the SwiftUI Previews.

```swift
ForEach(localizations, id: \.identifier) { locale in
    Text("Hello")
        .environment(\.locale, locale)
        .previewDisplayName(Locale.current.localizedString(forIdentifier: locale.identifier))
}
```

The problem is when you would like to use `NSLocalizedString`, or you have a custom implementation for the localized strings handling. Then most probably you will lose the ability to set the locale by `.environment(\.locale, locale)` on the views because it won't be respected. As the environment value is available in the `View` context and `Locale.current` stays the same across the app. There is no way to get the locale set for the given view and its child views outside of the `body`.

To overcome that issue I came up with a solution that allows to override of the locale environment and provide a custom implementation of the localized strings.

```swift
struct LocalizedText: View {
    @Environment(\.locale) var locale
    let key: String
    let localizedString: (_ languageCode: String?, _ key: String) -> (String)

    var body: Text {
        let languageCode = locale.languageCode ?? Locale.current.languageCode
        let localizedString = localizedString(languageCode, key)

        return Text(localizedString)
    }
}
``` 

`LocalizedText` view is used to get the `locale` from the `environment` as it is only available from the `View` context.
Using `localizedString` closure, which gets all the information needed to resolve the localized string which is the `key` and `languageCode` (if needed the whole `Locale` object could be passed instead). 

Example of use could look like this:

```swift
extension L18n {
    static func localizedString(_ key: String, languageCode: String) -> String {
        NSLocalizedString(
            key,
            tableName: "",
            bundle: resolveBundle(for : languageCode),
            value: "**\(key)**",
            comment: ""
        )
    }

    static func localizedText(_ key: String) -> some View {
        LocalizedText(key: key, localizedString: { languageCode, key in
            localizedString(key, languageCode: languageCode)
        })
    }
}
```

```swift
struct SomeView: View {
    var body: some View {
        L18n.localizedText("Hello")
    }
}

struct SomeView_Preview: PreviewProvider {
    static var previews: some View {
        SomeView()
            .environment(\.locale, Locale(identifier: "pl"))
    }
}
```

This way we keep the best of both worlds. Especially do not lose the ability of SwiftUI [`EnvironmentValues`](https://developer.apple.com/documentation/swiftui/environmentvalues) and still provide a custom implementation for the localized strings handling. We can keep `*.lproj` and `*.strings` files in a separate framework, and provide a custom implementation of the localized strings by e.g. having a complicated fallback translations business logic in case the key is missing for the asked language.