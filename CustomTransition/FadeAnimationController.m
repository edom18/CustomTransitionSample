
#import "FadeAnimationController.h"

@interface FadeAnimationController()

@property (nonatomic, assign) CGFloat deltaTime;

@end

@implementation FadeAnimationController

/**
 *  生成メソッド
 */
+ (instancetype)create
{
    return [[self.class alloc] init];
}
+ (instancetype)createAsSwipe
{
    return [[self.class alloc] initAsSwipe];
}
- (instancetype)initAsSwipe
{
    self = [super init];
    if (self) {
        self.isSwipe = YES;
    }
    return self;
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - Instance methods

/**
 *  Update interactive transition
 *
 *  Update to transition with `transitionContext`
 *
 *  @param percent
 */
- (void)updateInteractiveTransition:(CGFloat)percent
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self.transitionContext updateInteractiveTransition:percent];
    
    // Get view controllers(from/to) in context.
    UIViewController *fromVC = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Do any transition with view controllers.
    CGRect initFrame      = [self.transitionContext initialFrameForViewController:fromVC];
    CGRect frame = fromVC.view.frame;
    
    frame.origin.x = initFrame.size.width * percent;
    fromVC.view.frame = frame;
}


/**
 *  Canceling transition.
 *
 *  Will be called it when transiton is canceled.
 *
 *  This method perform two method on transitionContext are `cancelInteractiveTransition` and `completeTransition:`.
 *  Both methods are required to invoke when trainsition is finished.
 *
 *  IMPORTANT: `completeTransition:` method must be called after `cancelInteractiveTransition`.
 */
- (void)cancelInteractiveTransition
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UIViewController *fromVC = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect initFrame  = [self.transitionContext initialFrameForViewController:fromVC];
    fromVC.view.frame = initFrame;
    
    [self.transitionContext cancelInteractiveTransition];
    [self.transitionContext completeTransition:NO];
}


/**
 *  Finishing transition.
 *
 *  This method perform two methods on a transitionContext are `finishInteractiveTransition` and `completeTransition:`.
 *  Both methods are required to invoke when a trainsition is finished.
 */
- (void)finishInteractiveTransition
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.transitionContext finishInteractiveTransition];
    [self.transitionContext completeTransition:YES];
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewControllerInteractiveTransitioning

/**
 *  This is UIViewControllerInteractiveTransitioning protocol.
 *
 *  It'll be called when a view controller is push / pop or anything like that are performed.
 *
 *  @param transitionContext
 */
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.transitionContext = transitionContext;
    [self animateTransition:transitionContext];
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewControllerAnimatedTransitioning

/**
 *  Animation duration.
 *
 *  @return duration time
 */
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return 3.0;
}


/**
 *  Implementation of a transition animation.
 *  This method is called once in starting transition.
 *
 *  @param transitionContext
 */
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    /////////////////////////////////////////////////////////////////////////////
    // Set up views for a transition.
    
    // Get from/to view controllers in a context.
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Get a container view in a context.
    UIView *containerView = [transitionContext containerView];
    
    // Constracting views for a transition animation.
    [containerView insertSubview:toVC.view
                    belowSubview:fromVC.view];
    
    if (self.isSwipe) {
        return;
    }
    
    self.deltaTime = 0.0;
    const CGFloat duration = [self transitionDuration:transitionContext];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.16
                                                      target:self
                                                    selector:@selector(update)
                                                    userInfo:nil
                                                     repeats:YES];
    [timer fire];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         // Peform animations.
                         fromVC.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         // Notice end of transition.
                         [transitionContext finishInteractiveTransition];
                         [transitionContext completeTransition:YES];
                         [timer invalidate];
                     }];
}

/**
 *  Update percent for a transition.
 */
- (void)update
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.deltaTime += 0.16;
    const CGFloat duration = [self transitionDuration:self.transitionContext];
    [self updateInteractiveTransition:self.deltaTime / duration];
}

@end


