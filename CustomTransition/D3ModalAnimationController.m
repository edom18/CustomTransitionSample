
#import "D3ModalAnimationController.h"

@interface D3ModalAnimationController ()

@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@end


@implementation D3ModalAnimationController

static D3ModalAnimationController *instance;

+ (instancetype)defaultController
{
    @synchronized(self.class) {
        if (!instance) {
            instance = [[self.class alloc] init];
        }
        
        return instance;
    }
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - Dynamic properties

- (UIViewController *)fromVC
{
    if (!self.transitionContext) {
        return nil;
    }
    
    return [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
}

- (UIViewController *)toVC
{
    if (!self.transitionContext) {
        return nil;
    }
    
    return [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return 0.5;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.transitionContext = transitionContext;
    
    UIViewController *fromVC = self.fromVC;
    UIViewController *toVC   = self.toVC;
    
    UIView *containerView = self.transitionContext.containerView;
    
    [containerView insertSubview:toVC.view
                    aboveSubview:fromVC.view];
    
    CGRect frame = toVC.view.frame;
    frame.origin.y = frame.size.height;
    toVC.view.frame = frame;
    
    toVC.view.alpha   = 0.0;
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext]
                     animations:^{
                         CGRect frame = [self.transitionContext finalFrameForViewController:toVC];
                         frame.origin.y = 0;
//                         frame.size.height -= 44;
                         toVC.view.alpha = 1.0;
                         toVC.view.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         [self.transitionContext completeTransition:YES];
                     }];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return nil;
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - For presentation

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self;
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - For dismissing

/**
 *  It will be called when view controller is going to dismiss.
 *
 *  @param dismissed dismissed view controller
 *
 *  @return animator object. if it will return `nil`, system use a default transition.
 */
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self;
}


/**
 *  It will be called when view controller is dismissing.
 *
 *  @param animator animator object
 *
 *  @return transition controller
 */
- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self;
}

@end
