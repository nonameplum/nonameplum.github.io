---
date: 2022-11-04 07:16
description: Non Safe Area and Navigation Bar SwiftUI Hosting View Controller
tags: SwiftUI
tagColors: SwiftUI=F6DA24
---
# How to hide navigation bar and fix the safe are issue while using UIHostingViewController since SwiftUI iOS 13.0

I created a `UIHostingViewController` that works for me since iOS 13.0, and solves the `NavigationBar` visibility issues and safe area in SwiftUI.

```swift
public final class NonSafeAreaHostingController<Content: View>: UIHostingController<Content> {
    public var navigationBarHidden = true
    public var statusBarHidden = true
    public var isEmbedded = false

    override public func viewDidLoad() {
        super.viewDidLoad()
        fixSafeAreaInsets()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(navigationBarHidden, animated: false)
    }

    override public var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    override public var navigationController: UINavigationController? {
        isEmbedded ? nil : super.navigationController
    }

    private func fixSafeAreaInsets() {
        guard let _class = view?.classForCoder else {
            return
        }

        let safeAreaInsets: @convention(block) (AnyObject)
            -> UIEdgeInsets = { (_: AnyObject!) -> UIEdgeInsets in
                return .zero
            }

        guard let method = class_getInstanceMethod(
            _class.self,
            #selector(getter: UIView.safeAreaInsets)
        )
        else {
            return
        }

        class_replaceMethod(
            _class,
            #selector(getter: UIView.safeAreaInsets),
            imp_implementationWithBlock(safeAreaInsets),
            method_getTypeEncoding(method)
        )

        let safeAreaLayoutGuide: @convention(block) (AnyObject)
            -> UILayoutGuide? = { (_: AnyObject!) -> UILayoutGuide? in
                return nil
            }

        guard let method2 = class_getInstanceMethod(
            _class.self,
            #selector(getter: UIView.safeAreaLayoutGuide)
        )
        else {
            return
        }

        class_replaceMethod(
            _class,
            #selector(getter: UIView.safeAreaLayoutGuide),
            imp_implementationWithBlock(safeAreaLayoutGuide),
            method_getTypeEncoding(method2)
        )
    }
}
```