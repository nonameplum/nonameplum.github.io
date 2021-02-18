---
date: 2021-02-09 22:00
description: Thread safety dispatch_once Swifty alternative
tags: swift
tagColors: swift=1d76db
---
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

let once = Once()

var indexes: [Int] = []
DispatchQueue.concurrentPerform(iterations: 100, execute: { index in
    once.run {
        indexes.append(index)
    }
})

print(indexes) // It will have only one element
```