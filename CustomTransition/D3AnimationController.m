
#import "D3AnimationController.h"

@interface D3AnimationController ()

@property (nonatomic, assign) CGFloat time;
@property (nonatomic, assign) CGFloat progressPercent;
@property (nonatomic, assign, readwrite) BOOL isSwipe;
@property (nonatomic, assign           ) BOOL isCompleted;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, assign) UINavigationControllerOperation currentOperation;

/**
 *  Edge pan gesture.
 */
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePanGesture;


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
        self.isSwipe     = NO;
        self.isCompleted = NO;
        
        self.edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handlePan:)];
        self.edgePanGesture.edges    = UIRectEdgeLeft;
        self.edgePanGesture.delegate = self;
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - Dynamic properties.

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


/////////////////////////////////////////////////////////////////////////////
#pragma mark - Instance methods.

/**
 *  Start with swipe mode.
 */
- (void)startAsSwipe
{
    self.isSwipe = YES;
}


/**
 *  Prefare for animation.
 */
- (void)prepareForAnimation
{
    self.time            = 0.0;
    self.progressPercent = 0.0;
    self.isCompleted     = NO;
}


/**
 *  Handling screen pan gesuture
 *
 *  @param gesture
 */
- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)gesture
{
    
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - Handling animations.

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
    if (self.isCompleted) {
        return;
    }
    
    const CGFloat targetDuration  = [self transitionDuration:self.transitionContext];
    const CGFloat duration        = displayLink.duration;
    const NSInteger frameInterval = displayLink.frameInterval;
    const CGFloat deltaTime       = duration / frameInterval;
    
    self.time            += deltaTime;
    self.progressPercent = self.time / targetDuration;
    
    if (self.progressPercent >= 1.0) {
        self.progressPercent = 1.0;
        self.isCompleted = YES;
    }
    
    [self.transitionContext updateInteractiveTransition:self.progressPercent];
    
    if (self.currentOperation == UINavigationControllerOperationPush) {
        [self updatePushAnimation];
    }
    else if (self.currentOperation == UINavigationControllerOperationPop) {
        [self updatePopAnimation];
    }
    
    if (self.isCompleted) {
        [displayLink invalidate];
        [self finishInteractiveTransition];
    }
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark -

/**
 *  Start push animation
 */
- (void)pushAnimation
{
    UIViewController *fromVC = self.fromVC;
    UIViewController *toVC   = self.toVC;
    
    UIView *containerView = self.transitionContext.containerView;
    
    // For `To VC` initial setting.
    const CGFloat width           = [self.transitionContext finalFrameForViewController:toVC].size.width;
    CGAffineTransform toTransform = CGAffineTransformMakeTranslation(width * (1.0 - self.progressPercent), 0);
    toVC.view.transform           = toTransform;
    
    [containerView insertSubview:toVC.view
                    aboveSubview:fromVC.view];
    
    [self startAnimation];
}


/**
 *  Update push animation
 */
- (void)updatePushAnimation
{
    UIViewController *fromVC = self.fromVC;
    UIViewController *toVC   = self.toVC;
    
    const CGFloat base  = 0.1;
    const CGFloat base2 = 1.0;
    const CGFloat delta = base * self.progressPercent;
    
    // for `To VC`
    const CGFloat width           = [self.transitionContext finalFrameForViewController:toVC].size.width;
    CGAffineTransform toTransform = CGAffineTransformMakeTranslation(width * (1.0 - self.progressPercent), 0);
    toVC.view.transform           = toTransform;
    
    // for `From VC`
    const CGFloat fromAlpha         = 1.0 - self.progressPercent;
    fromVC.view.alpha               = fromAlpha;
    CGAffineTransform fromTransform = CGAffineTransformMakeScale(base2 - delta, base2 - delta);
    fromVC.view.transform           = fromTransform;
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark -

/**
 *  Start pop animation.
 */
- (void)popAnimation
{
    UIViewController *fromVC = self.fromVC;
    UIViewController *toVC   = self.toVC;
    
    UIView *containerView = self.transitionContext.containerView;
    
    [containerView insertSubview:toVC.view
                    belowSubview:fromVC.view];
    
    // for `To VC`
    toVC.view.bounds = [self.transitionContext initialFrameForViewController:self.fromVC]; //containerView.frame;
    CGAffineTransform toTransform = CGAffineTransformMakeScale(0.9, 0.9);
    toVC.view.transform           = toTransform;
    toVC.view.alpha   = 0.0;
    
    [self startAnimation];
}


/**
 *  Update pop animation
 */
- (void)updatePopAnimation
{
    UIViewController *fromVC = self.fromVC;
    UIViewController *toVC   = self.toVC;
    
    const CGFloat base  = 0.9;
    const CGFloat base2 = 1.0 - base;
    const CGFloat delta = base * self.progressPercent;
    
    // for `From VC`
    const CGFloat width             = [self.transitionContext initialFrameForViewController:fromVC].size.width;
    CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(width * self.progressPercent, 0);
    fromVC.view.transform           = fromTransform;
    
    // for `To VC`
    const CGFloat toAlpha         = self.progressPercent;
    toVC.view.alpha               = toAlpha;
    CGAffineTransform toTransform = CGAffineTransformMakeScale(base2 + delta, base2 + delta);
    toVC.view.transform           = toTransform;
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark -

/**
 *  Update transition
 *
 *  @param percent progress
 */
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
    
    self.toVC.view.frame     = self.transitionContext.containerView.frame; //[self.transitionContext finalFrameForViewController:self.toVC];
    self.toVC.view.transform = CGAffineTransformIdentity;
    
    self.fromVC.view.frame     = self.transitionContext.containerView.frame; //[self.transitionContext finalFrameForViewController:self.fromVC];
    self.fromVC.view.transform = CGAffineTransformIdentity;
    
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
    return 0.3;
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


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self prepareForAnimation];
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
