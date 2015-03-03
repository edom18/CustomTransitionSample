
#import "ViewController2.h"

#import "FadeAnimationController.h"

@interface PushAnimator : NSObject
<
UIViewControllerAnimatedTransitioning
>

@end

@implementation PushAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 5.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.frame = CGRectOffset(fromViewController.view.frame, fromViewController.view.frame.size.width, 0);;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toViewController.view.frame = fromViewController.view.frame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end


/////////////////////////////////////////////////////////////////////////////

@interface ViewController2 () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactionController;

@end

@implementation ViewController2

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.greenColor;
    
    self.interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
    
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.edges = UIRectEdgeLeft;
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.delegate = self;
}




- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)gesture
{
    CGFloat width = gesture.view.frame.size.width;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // [self performSegueWithIdentifier:@"pushToSecond" sender:self];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:gesture.view];
        [self.interactionController updateInteractiveTransition:ABS(translation.x / width)];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled)
    {
        CGPoint translation = [gesture translationInView:gesture.view];
        CGPoint velocity    = [gesture velocityInView:gesture.view];
        CGFloat percent     = ABS(translation.x + velocity.x * 0.25 / width);
        
        if (percent < 0.5 || gesture.state == UIGestureRecognizerStateCancelled) {
            [self.interactionController cancelInteractiveTransition];
        }
        else {
            [self.interactionController finishInteractiveTransition];
        }
    }
}


- (id<UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    NSLog(@"animationControllerForPresentedController");
    return [[FadeAnimationController alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    NSLog(@"navigationController animationControllerForOperation");
    if (operation == UINavigationControllerOperationPush)
        return [[PushAnimator alloc] init];
    
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController*)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    NSLog(@"navigationController interaction");
    return self.interactionController;
}

/**
 *  ナビゲーションコントローラの遷移が始まるとき
 */
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    
}


/**
 *  ナビゲーションコントローラの遷移が終わったとき
 */
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    
}


/////////////////////////////////////////////////////////////////////////////
#pragma UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
