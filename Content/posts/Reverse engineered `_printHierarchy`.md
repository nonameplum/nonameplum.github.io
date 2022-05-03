---
date: 2022-05-03 08:34
description: Reverse engineered `_printHierarchy`
tags: swift,obj-c,UIKit
tagColors: swift=1d76db,obj-c=28AEEE,UIKit=6FBC3A
---
# How to reverse engineer `_printHierarchy`

I wanted to traverse the view controllers hierarchy the same way as the private method that is available on UIKit -`UIViewController._printHierarchy`.

You can run it from lldb:
```
exp -l objc -o -- [UIApplication.sharedApplication.keyWindow.rootViewController _printHierarchy]
```
or using a class method
```
exp -l objc -o -- [UIViewController _printHierarchy]
```

and it should return something like:
```
<UITabBarController 0x12c01d200>, state: appeared, view: <UILayoutContainerView 0x129e07b40>
   | <UINavigationController 0x12a808200>, state: appeared, view: <UILayoutContainerView 0x129b10880>
   |    | <App.ViewController 0x129b04620>, state: disappeared, view: (view not loaded)
   |    | <App.ViewController 0x129b049c0>, state: disappeared, view: <UIView 0x129b27620> not in the window
   |    | <App.ViewController 0x129f06550>, state: disappeared, view: <UIView 0x129f0b7c0> not in the window
   |    | <App.ViewController 0x129b24540>, state: appeared, view: <UIView 0x129b2b750>
   | <UINavigationController 0x12b80a000>, state: disappeared, view: <UILayoutContainerView 0x12d0052c0> not in the window
   |    | <App.ViewController 0x129c07220>, state: disappeared, view: (view not loaded)
   |    | <App.ViewController 0x129c075c0>, state: disappeared, view: <UIView 0x129e0c730> not in the window
   |    | <App.ViewController 0x12d204900>, state: disappeared, view: <UIView 0x129e11550> not in the window
   |    | <App.ViewController 0x12d204ca0>, state: disappeared, view: <UIView 0x129b16200> not in the window
   + <App.ViewController 0x12d2065e0>, state: appeared, view: <UIView 0x129b26a90>, presented with: <_UIPageSheetPresentationController 0x12d205aa0>
   |    + <App.ViewController 0x129b4b130>, state: appeared, view: <UIView 0x129b4b4d0>, presented with: <_UIPageSheetPresentationController 0x129b4b7f0>
   |    |    + <App.ViewController 0x129e2ada0>, state: appeared, view: <UIView 0x129e25950>, presented with: <_UIPageSheetPresentationController 0x129e27ec0>
```

I have found a few existing solutions that for example use the `UIResponder` chain to traverse the hierarchy like [this one](https://dmytro-anokhin.medium.com/exploring-view-hierarchy-332ea63262e9).
But the problem with `UIResponder.next` is that it won't traverse all of the controllers if there is a branch of more than one `UIViewController` stack like you might have with e.g. `UITabViewController` and modally presented view controllers. `UIResponder.next` traverses bottom-up the view hierarchy but only from the specific leaf.

I thought, that why not reverse engineer the original `_printHierarchy` method, to check all of the quirks of its internal implementation and understand how Apple engineers traverse the view controllers hierarchy top-down.
It turned out to be quite straightforward after using [Hopper Disassembler app](https://www.hopperapp.com/).
The `_printHierachy` core method is actually implemented in `_appendDescription`. On UIKit 15.0 with disassembled `UIKitCore` using _x86_64_ which is a bit more readable than _ARM64_.

```assembly
function _appendDescription {
    stack[-200] = rcx;
    r14 = rdx;
    r12 = [rdi retain];
    rbx = [rsi retain];
    if ([rbx length] != 0x0) {
            [rbx appendString:@"\n"];
    }
    stack[-208] = rbx;
    rax = [r12 _parentViewController];
    rax = [rax retain];
    stack[-188] = r14 & 0xff;
    stack[-216] = r12;
    if (rax != 0x0) {
            [rax release];
            r15 = stack[-208];
            if (stack[-200] != 0x0) {
                    r12 = sign_extend_64(stack[-200]);
                    rbx = 0x1;
                    do {
                            [r15 appendString:@"   | "];
                            rbx = rbx + 0x1;
                    } while (rbx <= r12);
            }
            r13 = stack[-216];
            rax = -[UIViewController _descriptionForPrintingHierarchyIncludingInsets:](r13, stack[-188]);
            rax = [rax retain];
            rbx = rax;
            [r15 appendString:rax];
    }
    else {
            if ([r12 _isRootViewController] != 0x0) {
                    r15 = stack[-208];
                    if (stack[-200] != 0x0) {
                            r12 = sign_extend_64(stack[-200]);
                            rbx = 0x1;
                            do {
                                    [r15 appendString:@"   | "];
                                    rbx = rbx + 0x1;
                            } while (rbx <= r12);
                    }
                    r13 = stack[-216];
                    rax = -[UIViewController _descriptionForPrintingHierarchyIncludingInsets:](r13, stack[-188]);
                    rax = [rax retain];
                    rbx = rax;
                    [r15 appendString:rax];
            }
            else {
                    r12 = stack[-208];
                    if (stack[-200] >= 0x2) {
                            rbx = sign_extend_64(stack[-200]) - 0x1;
                            do {
                                    [r12 appendString:@"   | "];
                                    rbx = rbx - 0x1;
                            } while (rbx != 0x0);
                    }
                    [r12 appendString:@"   + "];
                    r15 = [-[UIViewController _descriptionForPrintingHierarchyIncludingInsets:](stack[-216], stack[-188]) retain];
                    rax = [stack[-216] presentingViewController];
                    rax = [rax retain];
                    stack[-248] = rax;
                    rax = [rax _presentationController];
                    rax = [rax retain];
                    stack[-240] = rax;
                    rax = [rax _descriptionForPrintingViewControllerHierarchy];
                    rax = [rax retain];
                    stack[-224] = rax;
                    rax = [NSMutableString stringWithFormat:@"%@, presented with: %@", r15, rax];
                    rax = [rax retain];
                    r13 = stack[-216];
                    [r12 appendString:rax];
                    rbx = r15;
                    [rax release];
                    [stack[-224] release];
                    [stack[-240] release];
                    [stack[-248] release];
            }
    }
    [rbx release];
    *(int128_t *)(&stack[-312] + 0x30) = intrinsic_movaps(*(int128_t *)(&stack[-312] + 0x30), 0x0);
    *(int128_t *)(&stack[-312] + 0x20) = intrinsic_movaps(*(int128_t *)(&stack[-312] + 0x20), 0x0);
    *(int128_t *)(&stack[-312] + 0x10) = intrinsic_movaps(*(int128_t *)(&stack[-312] + 0x10), 0x0);
    *(int128_t *)&stack[-312] = intrinsic_movaps(*(int128_t *)&stack[-312], 0x0);
    rax = [r13 childViewControllers];
    rax = [rax retain];
    rbx = rax;
    rcx = &stack[-184];
    rdx = &stack[-312];
    rax = [rax countByEnumeratingWithState:rdx objects:rcx count:0x10];
    if (rax != 0x0) {
            r13 = rax;
            r12 = **(&stack[-312] + 0x10);
            r15 = stack[-200] + 0x1;
            do {
                    r14 = 0x0;
                    do {
                            if (*stack[-296] != r12) {
                                    objc_enumerationMutation(rbx);
                            }
                            _appendDescription(*(stack[-304] + r14 * 0x8), stack[-208], stack[-188], r15, 0x10);
                            r14 = r14 + 0x1;
                    } while (r13 != r14);
                    rdx = &stack[-312];
                    rcx = &stack[-184];
                    rax = [rbx countByEnumeratingWithState:rdx objects:rcx count:0x10];
                    r13 = rax;
            } while (rax != 0x0);
    }
    [rbx release];
    r14 = stack[-216];
    rsi = @selector(childModalViewController);
    rax = (*_objc_msgSend)(r14, rsi);
    rax = [rax retain];
    [rax release];
    rbx = stack[-208];
    if (rax != 0x0) {
            rax = [r14 childModalViewController];
            rax = [rax retain];
            rcx = stack[-200] + 0x1;
            rsi = rbx;
            rdx = stack[-188];
            _appendDescription(rax, rsi, rdx, rcx);
            [rax release];
    }
    stack[-56] = **___stack_chk_guard;
    [rbx release];
    [r14 release];
    rax = *___stack_chk_guard;
    rax = *rax;
    if (rax != stack[-56]) {
            rax = __stack_chk_fail();
    }
    return rax;
}
```
There are few `if` statements that split the code, but they are mostly used to properly append to the print indentation, like `"   | "` and `"   + "`. Overall if you forget about the lines generated by the assembly code (e.g. registry assignments) and _ARC_ (e.g. `[rax retain]`, `[r14 release]`) the code is quite short and simple. Inside `if` statements blocks you can find the `while/repeat` loops that add the indentation required depending on the view hierarchy tree.

I transferred the code into _Swift_ and this is what I got:
```swift
extension UIViewController {
    public func printHierarchy() {
        var prints: [String] = []
        self.appendDescription(output: &prints, deep: 0)

        let printString = prints.reduce("") { partialResult, elem in
            return partialResult.appending(elem)
        }

        print(printString)
    }

    private func appendDescription(output: inout [String], deep: Int) {
        if !output.isEmpty {
            output.append("\n")
        }

        if self.parent != nil {
            var i = 0
            while i < deep {
                output.append("   | ")
                i += 1
            }
            output.append(self.description)
        } else {
            if self.isRootViewController {
                var i = 1
                while i < deep {
                    output.append("   | ")
                    output.append(self.description)
                    i += 1
                }
                output.append(self.description)
            } else {
                if deep >= 2 {
                    var i = deep - 1
                    repeat {
                        output.append("   | ")
                        i -= 1
                    } while i != 0
                }
                output.append("   + ")
                output.append(self.description)
                output.append(", presented with: \(self.presentationController?.description ?? "N/A")")
            }
        }

        if !self.children.isEmpty {
            var i = 0
            while i < self.children.count {
                self.children[i].appendDescription(output: &output, deep: deep + 1)
                i += 1
            }
        }

        if let childModalVC = self.childModalViewController {
            childModalVC.appendDescription(output: &output, deep: deep + 1)
        }
    }
}

extension UIViewController {
    var isRootViewController: Bool {
        UIApplication.shared.windows.compactMap(\.rootViewController).contains(self)
    }

    var childModalViewController: UIViewController? {
        if self.presentedViewController?.presentingViewController == self {
            return self.presentedViewController
        } else {
            return nil
        }
    }
}
```

I had to reimplement the `isRootViewController` and `childModalViewController` that is used in the original implementation and it is not avaiable in the public methods of UIKit API. `appendDescription` goes recursively trought child and child modal view controllers. 
What I learned from this, is that Apple engenieers smartly do not check for the specific `UIViewController` subclasses to verify if there are sub view controllers like you can do with `UINavigationController.viewControllers`. They just check if there are child/modal view controllers, and recursively visit all of them.
The ouput of my reimplemented _Swift_ `printHierarchy` looks the same beside slight differences of the `UIViewControllers` descriptions, as again there is custom implementation used internally like `_descriptionForPrintingHierarchyIncludingInsets`.

### Reimplemented
```
<UITabBarController: 0x12c01d200>
   | <UINavigationController: 0x12a808200>
   |    | <App.ViewController: 0x129b04620>
   |    | <App.ViewController: 0x129b049c0>
   |    | <App.ViewController: 0x129f06550>
   |    | <App.ViewController: 0x129b24540>
   | <UINavigationController: 0x12b80a000>
   |    | <App.ViewController: 0x129c07220>
   |    | <App.ViewController: 0x129c075c0>
   |    | <App.ViewController: 0x12d204900>
   |    | <App.ViewController: 0x12d204ca0>
   + <App.ViewController: 0x12d2065e0>, presented with: <_UIPageSheetPresentationController: 0x12d205aa0>
   |    + <App.ViewController: 0x129b4b130>, presented with: <_UIPageSheetPresentationController: 0x129b4b7f0>
   |    |    + <App.ViewController: 0x129e2ada0>, presented with: <_UIPageSheetPresentationController: 0x129e27ec0>
```

### Original
 ```
<UITabBarController 0x12c01d200>, state: appeared, view: <UILayoutContainerView 0x129e07b40>
   | <UINavigationController 0x12a808200>, state: appeared, view: <UILayoutContainerView 0x129b10880>
   |    | <App.ViewController 0x129b04620>, state: disappeared, view: (view not loaded)
   |    | <App.ViewController 0x129b049c0>, state: disappeared, view: <UIView 0x129b27620> not in the window
   |    | <App.ViewController 0x129f06550>, state: disappeared, view: <UIView 0x129f0b7c0> not in the window
   |    | <App.ViewController 0x129b24540>, state: appeared, view: <UIView 0x129b2b750>
   | <UINavigationController 0x12b80a000>, state: disappeared, view: <UILayoutContainerView 0x12d0052c0> not in the window
   |    | <App.ViewController 0x129c07220>, state: disappeared, view: (view not loaded)
   |    | <App.ViewController 0x129c075c0>, state: disappeared, view: <UIView 0x129e0c730> not in the window
   |    | <App.ViewController 0x12d204900>, state: disappeared, view: <UIView 0x129e11550> not in the window
   |    | <App.ViewController 0x12d204ca0>, state: disappeared, view: <UIView 0x129b16200> not in the window
   + <App.ViewController 0x12d2065e0>, state: appeared, view: <UIView 0x129b26a90>, presented with: <_UIPageSheetPresentationController 0x12d205aa0>
   |    + <App.ViewController 0x129b4b130>, state: appeared, view: <UIView 0x129b4b4d0>, presented with: <_UIPageSheetPresentationController 0x129b4b7f0>
   |    |    + <App.ViewController 0x129e2ada0>, state: appeared, view: <UIView 0x129e25950>, presented with: <_UIPageSheetPresentationController 0x129e27ec0>
```