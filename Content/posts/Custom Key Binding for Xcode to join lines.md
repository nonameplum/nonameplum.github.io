---
date: 2021-02-03 10:34
description: Custom Key Binding for Xcode to join lines
tags: Xcode
tagColors: Xcode=006b75
---
# How to add join lines shortcut to Xcode

Add the section below to the file `IDETextKeyBindingSet.plist` that might be located at:
`/Applications/Xcode.app/Contents/Frameworks/IDEKit.framework/Versions/A/Resources/IDETextKeyBindingSet.plist`
depending where the Xcode app is placed and named.

```xml
<key>Custom</key>
<dict>
    <key>Join Lines</key>
    <string>moveDown:, moveToEndOfText:, moveToBeginningOfText:, deleteToBeginningOfLine:, deleteBackward:</string>
    <key>Join Lines Backward</key>
    <string>moveToEndOfText:, moveToBeginningOfText:, deleteToBeginningOfLine:, deleteBackward:</string>
</dict>
```

`Join Lines` joins the lines forward, the other one backward.

After the file is saved, Xcode needs to be restarted to load the new setup.
In Xcode settings, the keyboard shorts can be configured:
![Screenshot 2021-02-03 at 11 30 46](https://user-images.githubusercontent.com/1753816/106734419-48fec500-6613-11eb-994e-423fc983873e.png)
