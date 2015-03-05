
#import "D3AnimationController.h"

@interface D3AnimationController ()

@property (nonatomic, assign) CGFloat time;
@property (nonatomic, assign) CGFloat progressPercent;
@property (nonatomic, assign, readwrite) BOOL isSwipe;
@property (nonatomic, assign           ) BOOL isCompleted;

@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, strong) UINavigationController *navigationController;

@property (nonatomic, assign) UINavigationControllerOperation currentOperation;

/**
 *  Edge pan gesture.
 */
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePanGesture;


@end


@implementation D3AnimationController

static D3AnimationController *instance = nil;

@synthesize navigationController = _navigationController;

+ (instancetype)defaultController
{
    @synchronized(self.class) {
        if (!instance) {
            instance = [[self.class alloc] init];
        }
        
        return instance;
    }
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
#pragma -

- (UINavigationController *)navigationController
{
    return _navigationController;
}
- (void)setNavigationController:(UINavigationController *)navigationController
{
    if (_navigationController == navigationController) {
        return;
    }
    
    _navigationController.delegate                                 = nil;
    _navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    _navigationController = navigationController;
    
    _navigationController.delegate                                 = self;
    _navigationController.interactivePopGestureRecognizer.enabled  = YES;
    _navigationController.interactivePopGestureRecognizer.delegate = self;
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
 *  Start with swipe mode as pop.
 */
- (void)startAsSwipe
{
    self.isSwipe = YES;
        
    [self.navigationController popViewControllerAnimated:YES];
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
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    CGFloat width = gesture.view.frame.size.width;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self startAsSwipe];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:gesture.view];
        CGFloat percent = ABS(translation.x / width);
        
        [self updateInteractiveTransition:percent];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateCancelled) {
        CGPoint translation = [gesture translationInView:gesture.view];
        CGPoint velocity    = [gesture velocityInView:gesture.view];
        CGFloat percent     = MAX(0, translation.x + velocity.x * 0.25) / width;
        
        if (percent < 0.5 || gesture.state == UIGestureRecognizerStateCancelled) {
            [self cancelInteractiveTransition];
        }
        else {
            [self finishInteractiveTransition];
        }
    }
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
    
    if (!self.isCompleted) {
        [self.transitionContext updateInteractiveTransition:self.progressPercent];
    }
    
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
    
    if (!self.isSwipe) {
        [self startAnimation];
    }
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
    toVC.view.bounds = [self.transitionContext initialFrameForViewController:self.fromVC];//containerView.frame;
    toVC.view.alpha  = 0.0;
    
    if (!self.isSwipe) {
        [self startAnimation];
    }
}


/**
 *  Update pop animation
 */
- (void)updatePopAnimation
{
    UIViewController *fromVC = self.fromVC;
    UIViewController *toVC   = self.toVC;
    
    const CGFloat base  = 0.1;
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
    percent = MIN(1.0, MAX(0.0, percent));
    self.progressPercent = percent;
    
    [self.transitionContext updateInteractiveTransition:percent];
    
    [self updatePopAnimation];
}


/**
 *  Canceling transiton
 */
- (void)cancelInteractiveTransition
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.isSwipe = NO;
    
    self.toVC.view.bounds    = [self.transitionContext initialFrameForViewController:self.toVC];
    self.toVC.view.transform = CGAffineTransformIdentity;
    self.toVC.view.alpha     = 1.0;
    
    self.fromVC.view.bounds    = [self.transitionContext initialFrameForViewController:self.fromVC];
    self.fromVC.view.transform = CGAffineTransformIdentity;
    self.fromVC.view.alpha     = 1.0;
    
    [self.transitionContext cancelInteractiveTransition];
    [self.transitionContext completeTransition:NO];
}


/**
 *  Finishing transition
 */
- (void)finishInteractiveTransition
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.isSwipe = NO;
    
    self.toVC.view.frame     = [self.transitionContext finalFrameForViewController:self.toVC];
    self.toVC.view.transform = CGAffineTransformIdentity;
    self.toVC.view.alpha     = 1.0;
    
    self.fromVC.view.frame     = [self.transitionContext finalFrameForViewController:self.fromVC];
    self.fromVC.view.transform = CGAffineTransformIdentity;
    self.fromVC.view.alpha     = 1.0;
    
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
