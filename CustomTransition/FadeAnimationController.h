
@import UIKit;

@interface FadeAnimationController : NSObject
<
UIViewControllerAnimatedTransitioning,
UIViewControllerInteractiveTransitioning
>

/**
 *  is swipe?
 */
@property (nonatomic, assign, readonly) BOOL isSwipe;


/**
 *  A create method.
 */
+ (instancetype)create;


/**
 *  Start as swipe mode.
 */
- (void)startAsSwipe;


/**
 *  Update transition context
 *
 *  @param percent progress of transition (0.0 - 1.0)
 */
- (void)updateInteractiveTransition:(CGFloat)percent;


/**
 *  Canceling current transition.
 */
- (void)cancelInteractiveTransition;


/**
 *  Finishing current transition.
 */
- (void)finishInteractiveTransition;

@end
