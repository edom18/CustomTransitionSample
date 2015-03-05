
#import "D3AnimationController.h"

@interface D3AnimationController ()

@property (nonatomic, assign) CGFloat time;
@property (nonatomic, assign) CGFloat progressPercent;
@property (nonatomic, assign, readwrite) BOOL isSwipe;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, assign) UINavigationControllerOperation currentOperation;

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

/////////////////////////////////////////////////////////////////////////////

/**
 *  Start with swipe mode.
 */
- (void)startAsSwipe
{
    self.isSwipe = YES;
}

- (void)updateInteractiveTransition:(CGFloat)percent
{
    
}


/**
 *  Canceling transiton
 */
- (void)cancelInteractiveTransition
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self.transitionContext cancelInteractiveTransition];
    [self.transitionContext completeTransition:NO];
}


/**
 *  Finishing transition
 */
- (void)finishInteractiveTransition
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self.transitionContext finishInteractiveTransition];
    [self.transitionContext completeTransition:YES];
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (operation == UINavigationControllerOperationPush ||
        operation == UINavigationControllerOperationPop) {
        self.currentOperation = operation;
        return self;
    }
    
    return nil;
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
    
    if (self.currentOperation == UINavigationControllerOperationPush) {
        [self pushAnimation];
    }
    else if (self.currentOperation == UINavigationControllerOperationPop) {
        [self popAnimation];
    }
}

/**
 *  From view controller
 */
- (UIViewController *)fromVC
{
    return [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
}


/**
 *  To view controller
 */
- (UIViewController *)toVC
{
    return [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
}


/**
 *  Start animation
 */
- (void)startAnimation
{
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self
                                                             selector:@selector(updateProgress:)];
    [displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSDefaultRunLoopMode];
}


/**
 *  Update progress.
 *
 *  @param displayLink
 */
- (void)updateProgress:(CADisplayLink *)displayLink
{
    const CGFloat targetDuration  = [self transitionDuration:self.transitionContext];
    const CGFloat duration        = displayLink.duration;
    const NSInteger frameInterval = displayLink.frameInterval;
    const CGFloat deltaTime       = duration / frameInterval;
    
    self.time            += deltaTime;
    self.progressPercent = self.time / targetDuration;
    
    [self.transitionContext updateInteractiveTransition:self.progressPercent];
    
    if (self.progressPercent >= 1.0) {
        [displayLink invalidate];
        self.progressPercent = 1.0;
        [self finishInteractiveTransition];
    }
    
    if (self.currentOperation == UINavigationControllerOperationPush) {
        [self updatePushAnimation];
    }
    else if (self.currentOperation == UINavigationControllerOperationPop) {
        [self updatePopAnimation];
    }
}


/**
 *  Start push animation
 */
- (void)pushAnimation
{
    UIViewController *fromVC = self.fromVC;
    UIViewController *toVC   = self.toVC;
    
    UIView *containerView = self.transitionContext.containerView;
    
    [containerView insertSubview:toVC.view
                    belowSubview:fromVC.view];
    
    toVC.view.alpha = 0.0;
    
    [self startAnimation];
}


/**
 *  Update push animation
 */
- (void)updatePushAnimation
{
    UIViewController *fromVC = self.fromVC;
    UIViewController *toVC   = self.toVC;
    
    const CGFloat fromAlpha = 1.0 - self.progressPercent;
    const CGFloat toAlpha   = self.progressPercent;
    
    fromVC.view.alpha = fromAlpha;
    toVC.view.alpha   = toAlpha;
}


/**
 *  Start pop animation.
 */
- (void)popAnimation
{
    UIViewController *fromVC = self.fromVC;
    UIViewController *toVC   = self.toVC;
    
    UIView *containerView = self.transitionContext.containerView;
    
    [containerView insertSubview:toVC.view
                    aboveSubview:fromVC.view];
    
    toVC.view.alpha = 0.0;
    
    [self startAnimation];
}


/**
 *  Update pop animation
 */
- (void)updatePopAnimation
{
    UIViewController *fromVC = self.fromVC;
    UIViewController *toVC   = self.toVC;
    
    const CGFloat fromAlpha = 1.0 - self.progressPercent;
    const CGFloat toAlpha   = self.progressPercent;
    
    fromVC.view.alpha = fromAlpha;
    toVC.view.alpha   = toAlpha;
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.time            = 0.0;
    self.progressPercent = 0.0;
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
