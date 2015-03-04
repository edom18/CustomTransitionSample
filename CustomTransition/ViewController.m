
#import "ViewController.h"

#import "FadeAnimationController.h"


@interface ViewController ()
<
UIViewControllerTransitioningDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) ViewController *nextViewController;

@property (nonatomic, assign) BOOL isGesture;

@property (nonatomic, strong) FadeAnimationController *animationController;

@end


@implementation ViewController

/**
 *  View did load.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blueColor;
    
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.edges    = UIRectEdgeLeft;
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
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
        self.animationController = [FadeAnimationController createAsSwipe];
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

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.nextViewController = [[ViewController alloc] init];
    self.nextViewController.view.backgroundColor = UIColor.redColor;
    
    // transitionDelegate is to be used in modal view transition.
    // self.nextViewController.transitioningDelegate = self;
    
    [self.navigationController pushViewController:self.nextViewController
                                         animated:YES];
}


/**
 *  Pan Gestureのハンドラ
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
        CGPoint translation = [gesture translationInView:gesture.view];
        CGPoint velocity    = [gesture velocityInView:gesture.view];
        CGFloat percent     = ABS(translation.x + velocity.x * 0.25) / width;
        
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
 *  UIScreenEdgePanGestureRecognizerのハンドラ
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

@end
