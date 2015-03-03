
#import "ViewController.h"

#import "ViewController2.h"
#import "FadeAnimationController.h"

/////////////////////////////////////////////////////////////////////////////

@interface ViewController ()
<
UIViewControllerTransitioningDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) ViewController *nextViewController;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactionController;

@property (nonatomic, assign) BOOL disabled;

@property (nonatomic, strong) FadeAnimationController *animationController;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blueColor;
    self.interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
    
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.edges = UIRectEdgeLeft;
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.nextViewController = [[UIViewController alloc] init];
//        self.nextViewController.view.backgroundColor = UIColor.redColor;
//        self.nextViewController.transitioningDelegate = self;
//        self.navigationController.delegate = self;
//        [self.navigationController pushViewController:self.nextViewController animated:YES];
//        // [self.navigationController presentViewController:self.nextViewController animated:YES completion:nil];
//        
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////            [self.navigationController popViewControllerAnimated:YES];
////            // [self.navigationController dismissViewControllerAnimated:YES completion:nil];
////        });
//    });
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UINavigationControllerDelegate

/**
 *  ナビゲーションコントローラの遷移が始まるとき
 */
//- (void)navigationController:(UINavigationController *)navigationController
//      willShowViewController:(UIViewController *)viewController
//                    animated:(BOOL)animated
//{
//    
//}


/**
 *  ナビゲーションコントローラの遷移が終わったとき
 */
//- (void)navigationController:(UINavigationController *)navigationController
//       didShowViewController:(UIViewController *)viewController
//                    animated:(BOOL)animated
//{
//    
//}

/////////////////////////////////////////////////////////////////////////////

// どこから呼ばれる？
//- (id<UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented
//                                                                   presentingController:(UIViewController *)presenting
//                                                                       sourceController:(UIViewController *)source
//{
//    return [[FadeAnimationController alloc] init];
//}


// アニメーション開始時に呼ばれる
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    NSLog(@"hoge");
    
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
    NSLog(@"interactionControllerForAnimationController");
    return self.animationController;
//    return self.interactionController;
     // return [[FadeAnimationController alloc] init];
}


- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
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
#pragma UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
