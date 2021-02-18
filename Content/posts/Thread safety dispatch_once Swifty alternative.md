---
date: 2021-02-09 22:00
description: Thread safety dispatch_once Swifty alternative
tags: swift
tagColors: swift=1d76db
---
# Dispatch once in Swift using a handy trick

Switch allows to declare a type inside a function body.
This ability could be handy in some situations. I found it useful to run the body of the function only once.
For example we use to run only once the body of the function [`updateConstraints()`](https://developer.apple.com/documentation/uikit/uiview/1622512-updateconstraints).
In addition to that, if we use `static` variable in the inner `struct` Swift gives us thread safety for free.
I have created a simple wrapper, that allows to run an action and be sure that it will be run only once, even in the concurrect scenario.

```swift
struct Once {
    func run(action: () -> Void) {
        struct RunCheck {
            static var didRun = false
        }

        guard !RunCheck.didRun else { return }

        RunCheck.didRun = true
        action()
    }
}

```

Example of use:

```swift
let once = Once()

var indexes: [Int] = []
DispatchQueue.concurrentPerform(iterations: 100, execute: { index in
    once.run {
        indexes.append(index)
    }
})

print(indexes) // It will have only one element
```