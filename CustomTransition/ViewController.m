
#import "ViewController.h"

#import "FadeAnimationController.h"
#import "D3AnimationController.h"


@interface ViewController ()
<
UIViewControllerTransitioningDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) ViewController *nextViewController;

@property (nonatomic, strong) FadeAnimationController *animationController;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, assign) BOOL isGesture;

@property (nonatomic, strong) D3AnimationController *d3AnimationController;

@end


@implementation ViewController

/**
 *  View did load.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(0, 0, 250, 50);
    [self.button addTarget:self
                    action:@selector(touched:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.button setTitle:@"Touch to add a ViewController"
                 forState:UIControlStateNormal];
    [self.view addSubview:self.button];
    self.button.center = self.view.center;
    
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.edges    = UIRectEdgeLeft;
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    
    self.d3AnimationController = [D3AnimationController create];
}


/**
 *  View did appear.
 */
- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.navigationController.delegate                                 = self;
    self.navigationController.interactivePopGestureRecognizer.enabled  = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - UINavigationControllerDelegate

/**
 *  It'll be called when this shown in lifecycle.
 *  This is invoked after `viewDidAppear:` method has called.
 */
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


/**
 *  It'll be called when starting an animation of transition.
 */
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (operation == UINavigationControllerOperationPop) {
        self.animationController = [FadeAnimationController create];
        if (self.isGesture) {
            [self.animationController startAsSwipe];
        }
        return self.animationController;
    }
    
    // To use by default.
    return nil;
}
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self.animationController;
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - Event handler

- (void)touched:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    const CGFloat r = arc4random_uniform(100) / 100.0;
    const CGFloat g = arc4random_uniform(100) / 100.0;
    const CGFloat b = arc4random_uniform(100) / 100.0;
    
    self.nextViewController = [[ViewController alloc] init];
    self.nextViewController.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    
    // transitionDelegate is to be used in modal view transition.
    // self.nextViewController.transitioningDelegate = self;
    
    [self.navigationController pushViewController:self.nextViewController
                                         animated:YES];
}


/**
 *  Pan Gesture's handler
 */
- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)gesture
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    CGFloat width = gesture.view.frame.size.width;
    
    static UINavigationController *navigationController;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.isGesture = YES;
        
        navigationController = self.navigationController;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:gesture.view];
        CGFloat percent = ABS(translation.x / width);
        navigationController.navigationBar.alpha = 1.0 - percent;
        
        [self.animationController updateInteractiveTransition:percent];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateCancelled) {
        self.isGesture = NO;
        
        CGPoint translation = [gesture translationInView:gesture.view];
        CGPoint velocity    = [gesture velocityInView:gesture.view];
        CGFloat percent     = MAX(0, translation.x + velocity.x * 0.25) / width;
        
        if (percent < 0.5 || gesture.state == UIGestureRecognizerStateCancelled) {
            [self.animationController cancelInteractiveTransition];
        }
        else {
            [self.animationController finishInteractiveTransition];
        }
    }
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIGestureRecognizerDelegate

/**
 *  UIScreenEdgePanGestureRecognizer's handler
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

@end
