
@import UIKit;

@interface FadeAnimationController : NSObject
<
UIViewControllerAnimatedTransitioning,
UIViewControllerInteractiveTransitioning
>

@property (nonatomic, assign) BOOL isSwipe;

@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

+ (instancetype)create;

+ (instancetype)createAsSwipe;

- (void)updateInteractiveTransition:(CGFloat)percent;

- (void)cancelInteractiveTransition;

- (void)finishInteractiveTransition;

@end
