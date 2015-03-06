
#import "ViewController.h"

#import "FadeAnimationController.h"
#import "D3AnimationController.h"
#import "TransparentViewController.h"


@interface ViewController ()
<
UIViewControllerTransitioningDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) ViewController *nextViewController;

@property (nonatomic, strong) FadeAnimationController *animationController;

@property (nonatomic, assign) BOOL isGesture;

@property (nonatomic, strong) D3AnimationController *d3AnimationController;

@end


@implementation ViewController

/**
 *  View did load.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(0, 0, 250, 50);
    [button1 addTarget:self
                    action:@selector(addNormal:)
          forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"Touch to add a ViewController"
                 forState:UIControlStateNormal];
    [self.view addSubview:button1];
    button1.center = self.view.center;
    
    // Button2
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame = CGRectMake(0, 0, 300, 50);
    [button2 addTarget:self
                    action:@selector(addTransparent:)
          forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"Touch to add a TransaparentViewController"
                 forState:UIControlStateNormal];
    [self.view addSubview:button2];
    CGPoint center = self.view.center;
    center.y += 60;
    button2.center = center;
}


/**
 *  View did appear.
 */
- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    D3AnimationController *controller = D3AnimationController.defaultController;
    controller.navigationController = self.navigationController;
    // [self.view addGestureRecognizer:controller.edgePanGesture];
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

- (void)addNormal:(id)sender
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

- (void)addTransparent:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    const CGFloat r = arc4random_uniform(100) / 100.0;
    const CGFloat g = arc4random_uniform(100) / 100.0;
    const CGFloat b = arc4random_uniform(100) / 100.0;
    
    TransparentViewController *vc = [TransparentViewController create];
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
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
