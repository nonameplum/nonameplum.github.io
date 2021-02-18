---
date: 2021-01-14 11:46
description: Observe deinitialization
tags: swift
tagColors: swift=1d76db
---
# An extension to allow observation when an object is deallocated.

```swift
// MARK: Deinit observation
extension NSObject {
    func onDeinit(execute work: @escaping () -> Void) {
        let deinitCallback = Self.deinitCallback(forObject: self)
        deinitCallback.callbacks.append(work)
    }

    // MARK: Helpers
    private static let key = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)

    static private func deinitCallback(forObject object: NSObject) -> DeinitCallback {
        if let deinitCallback = objc_getAssociatedObject(object, key) as? DeinitCallback {
            return deinitCallback
        } else {
            let deinitCallback = DeinitCallback()
            objc_setAssociatedObject(object, key, deinitCallback, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return deinitCallback
        }
    }

    // MARK: Types
    @objc fileprivate class DeinitCallback: NSObject {
        var callbacks: [() -> Void] = []

        deinit {
            callbacks.forEach({ $0() })
        }
    }
}
```