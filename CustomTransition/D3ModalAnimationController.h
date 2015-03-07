
@import UIKit;

@interface D3ModalAnimationController : NSObject
<
UIViewControllerTransitioningDelegate,
UIViewControllerAnimatedTransitioning,
UIViewControllerInteractiveTransitioning
>

/**
 *  Default controller
 *
 *  @return singleton instance
 */
+ (instancetype)defaultController;

@end
