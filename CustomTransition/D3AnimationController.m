
#import "D3AnimationController.h"

@interface D3AnimationController ()

@property (nonatomic, assign, readwrite) BOOL isSwipe;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@end


@implementation D3AnimationController

+ (instancetype)create
{
    return [[self.class alloc] init];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isSwipe = NO;
    }
    return self;
}

- (void)startAsSwipe
{
    self.isSwipe = YES;
}

- (void)updateInteractiveTransition:(CGFloat)percent
{
    
}

- (void)cancelInteractiveTransition
{
    
}

- (void)finishInteractiveTransition
{
    
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self;
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    
    [containerView insertSubview:toVC.view
                    belowSubview:fromVC.view];
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.transitionContext = transitionContext;
    [self animateTransition:transitionContext];
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

@end
