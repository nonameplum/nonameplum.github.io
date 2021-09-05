---
date: 2021-04-04 20:27
description: Helper method to execute an action on viewDidLoad of a UIViewController
tags: swift
tagColors: swift=1d76db
---
# How to execute an action on viewDidLoad of an UIViewController

```swift
private var onViewLoadContext: UInt8 = 0

public protocol UIViewControllerOnViewLoadProtocol { }

extension UIViewController: UIViewControllerOnViewLoadProtocol { }

private class OnViewControllerViewLoadObserver<T>: NSObject {
    private var handlers: [(T) -> Void]
    var token: NSKeyValueObservation?

    init (_ handler: @escaping (T) -> Void) {
        self.handlers = [handler]
    }

    func invoke(_ value: T) {
        self.handlers.forEach { handler in
            handler(value)
        }
    }

    func add(handler: @escaping (T) -> Void) {
        self.handlers.append(handler)
    }
}

public extension UIViewControllerOnViewLoadProtocol where Self: UIViewController {
    /// Add handler when view controller's view is set by the framework
    ///
    /// - Attention: Be aware of memory leak that can be caused if any reference holded by `self` is used
    /// inside the handler callback. For that purpose use the instance passed in the handler parameter.
    ///
    /// - Parameters:
    ///     - handler: Callback that will be called when UIKit will set view controller's view.
    ///     Instance passed in the handler parameter is optional because is weakified.
    ///
    /// - Tag: addOnViewLoad
    func addOnViewLoad(handler: @escaping (Self?) -> Void) {
        let observer: OnViewControllerViewLoadObserver<Self?>
        if let existingObserver = objc_getAssociatedObject(self, &onViewLoadContext) as? OnViewControllerViewLoadObserver<Self?> {
            observer = existingObserver
            observer.add(handler: handler)
        } else {
            observer = OnViewControllerViewLoadObserver(handler)
            objc_setAssociatedObject(
                self,
                &onViewLoadContext,
                observer,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )

            observer.token = self.observe(\.view) { [weak observer, weak self] (_, _) in
                observer?.invoke(self)
            }
        }
    }

    /// Remove a handler added by [addOnViewLoad](x-source-tag://addOnViewLoad)
    func removeOnViewLoad() {
        objc_setAssociatedObject(
            self,
            &onViewLoadContext,
            nil,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}
```