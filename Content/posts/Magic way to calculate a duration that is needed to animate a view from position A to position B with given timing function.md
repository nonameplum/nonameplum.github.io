---
date: 2021-02-20 18:08
description: Magic way to calculate a duration that is needed to animate a view from position A to position B with given timing function
tags: 
tagColors: 
---
# How to calculate a duration that is needed to animate a view from position A to position B with a given timing function

A long time ago I had a problem to solve that I needed to know the exact time that will take to animate a view by x which might be in the middle of the desired position giving into account the timing function that the animation uses.

Here it is, an objective-c category:

```objective-c
//  CAMediaTimingFunction+Duration.h
#import <QuartzCore/QuartzCore.h>

@interface CAMediaTimingFunction (Duration)

- (NSTimeInterval)timeNeededToMoveByY:(CGFloat)yMove totalYMove:(CGFloat)totalYMove duration:(NSTimeInterval)duration;

@end

#import "CAMediaTimingFunction+Duration.h"

@implementation CAMediaTimingFunction (Duration)

- (NSTimeInterval)timeNeededToMoveBy:(CGFloat)move totalMove:(CGFloat)totalMove duration:(NSTimeInterval)duration {
    // Using reference animation calculate needed time according to used timing function
    CGFloat normalizedMove = move/totalMove;

    // View only just for calculation
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    CALayer *referenceLayer = view.layer;
    referenceLayer.hidden = YES;
    referenceLayer.speed = 0.0;
    [[UIApplication sharedApplication].keyWindow addSubview:view];

    // Reference animation to calculate time
    CABasicAnimation *basicAnimation =  [CABasicAnimation animationWithKeyPath:@"frame"];
    basicAnimation.duration = 1.0;
    basicAnimation.timingFunction = self;
    basicAnimation.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)];
    basicAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(100, 0, 1, 1)];

    [view.layer addAnimation:basicAnimation forKey:@"evaluatorAnimation"];

    // Force to run run-loop to get the presentation layer
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]];

    NSUInteger n = 0;
    CGFloat a = 0.0;
    CGFloat b = 1.0;
    CGFloat tolerance = 0.005;
    CGFloat move = 0.0;
    CGFloat middle = 0.0;

    // Biselection algorithm
    while (n < 1000) {
        middle = (a + b)/2;
        referenceLayer.timeOffset = middle;
        // Refresh animation to get updated presentation layer
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]];
        move = referenceLayer.presentationLayer.position.x / 100;

        if ((move - tolerance) <= normalizedMove && normalizedMove <= (move + tolerance))
            break;

        n += 1;
        if (normalizedMove < move)
            b = middle;
        else
            a = middle;
    }

    [view removeFromSuperview];
    return middle * duration;
}

@end
```