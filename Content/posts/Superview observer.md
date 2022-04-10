---
date: 2022-04-10 14:54
description: Superview observer
tags: swift,UIKit
tagColors: swift=1d76db,UIKit=6FBC3A
---
# How to observe the moment when the view is added to the super view.

Sometimes it is useful to know when the view has added a subview to another view. For example, it is required before we can activate the autolayout constraints.

This can be achieved by observing the moment when the view is moved to the window, as in the case of the `UIView` it happens at the time when is added as a subview.

To do that we can create `UIView` subclass that will override method [didMoveToWindow()](https://developer.apple.com/documentation/uikit/uiview/1622527-didmovetowindow).

```swift
public final class SuperviewObserver: UIView {
    private let observer: (_ this: UIView, _ superview: UIView) -> Void

    public init(observer: @escaping (_ this: UIView, _ superview: UIView) -> Void) {
        self.observer = observer
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let superview = superview?.superview else { return }

        observer(self, superview)
        removeFromSuperview()
    }
}
```

We can make this custom subclass more convenient to use, by creating an extension method:

```swift
public protocol UIViewProtocol {}
extension UIView: UIViewProtocol {}

public extension UIViewProtocol where Self: UIView {
    func onDidMoveToSubview(closure: @escaping (_ view: Self, _ superview: UIView) -> Void) {
        addSubview(
            SuperviewObserver { [unowned self] this, superview in
                closure(self, superview)
            }
        )
    }
}
```

`UIViewProtocol` protocol is added, to be able to get the exact type of the `UIView`.

```swift
let superview = UIView()
let view = CustomSubclass()
view.onDidMoveToSubview { this, superview in 
    NSLayoutConstraint.activate([
        this.leadingAnchor.constraint(equalTo: superview.leadingAnchor) // this is type of CustomSubclass
        ...
    ])
}

superview.addSubview(view)
```