
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
    
    self.currentOperation = operation;
    
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
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self
                                                             selector:@selector(updatePushAnimation:)];
    [displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSDefaultRunLoopMode];
    
    toVC.view.alpha = 0.0;
}

/**
 *  Update push animation
 *
 *  @param displayLink
 */
- (void)updatePushAnimation:(CADisplayLink *)displayLink
{
    [self updateProgress:displayLink];
    
    UIViewController *fromVC = self.fromVC;
    UIViewController *toVC   = self.toVC;
    
    const CGFloat fromAlpha = 1.0 - self.progressPercent;
    const CGFloat toAlpha   = self.progressPercent;
    
    fromVC.view.alpha = fromAlpha;
    toVC.view.alpha   = toAlpha;
}

- (void)popAnimation
{
    UIViewController *fromVC = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = self.transitionContext.containerView;
    
    [containerView insertSubview:toVC.view
                    belowSubview:fromVC.view];
    
    toVC.view.alpha = 0.0;
    
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext]
                     animations:^{
                         toVC.view.alpha   = 1.0;
                         fromVC.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self.transitionContext finishInteractiveTransition];
                         [self.transitionContext completeTransition:YES];
                     }];
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.time = 0.0;
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
