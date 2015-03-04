
@import UIKit;

@interface D3AnimationController : NSObject
<
UIViewControllerAnimatedTransitioning,
UIViewControllerInteractiveTransitioning,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, assign, readonly) BOOL isSwipe;

+ (instancetype)create;

- (void)startAsSwipe;

- (void)updateInteractiveTransition:(CGFloat)percent;

- (void)cancelInteractiveTransition;

- (void)finishInteractiveTransition;

@end
