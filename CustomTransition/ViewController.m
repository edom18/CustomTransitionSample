
#import "ViewController.h"

#import "FadeAnimationController.h"


@interface ViewController ()
<
UIViewControllerTransitioningDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) ViewController *nextViewController;

@property (nonatomic, assign) BOOL disabled;

@property (nonatomic, strong) FadeAnimationController *animationController;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blueColor;
    
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.edges = UIRectEdgeLeft;
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UINavigationControllerDelegate

// アニメーション開始時に呼ばれる
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (operation == UINavigationControllerOperationPop) {
        if (self.disabled) {
            self.animationController = [FadeAnimationController createAsSwipe];
            return self.animationController;
        }
    }
    
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
    
    if (self.disabled) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    self.nextViewController = [[ViewController alloc] init];
    self.nextViewController.disabled = YES;
    self.nextViewController.view.backgroundColor = UIColor.redColor;
    
    // transitionDelegateはモーダルビューの遷移で使用する
    // self.nextViewController.transitioningDelegate = self;
    
    self.navigationController.delegate = self.nextViewController;
    self.navigationController.interactivePopGestureRecognizer.enabled  = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController pushViewController:self.nextViewController animated:YES];
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
