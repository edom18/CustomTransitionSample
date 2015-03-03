
#import "FadeAnimationController.h"

@implementation FadeAnimationController

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

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 3.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"animateTransition");
    
    // 画面遷移コンテキストから遷移元、遷移先ビューコントローラの取得
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // 画面遷移コンテキストからコンテナビューを取得
    UIView *containerView = [transitionContext containerView];
    
    // コンテナビュー上に遷移先ビューを追加
    [containerView insertSubview:toVC.view
                    belowSubview:fromVC.view];
    
    if (self.isSwipe) {
        return;
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         // アニメーションを実行
                         fromVC.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         // 画面遷移完了を通知
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)updateInteractiveTransition:(CGFloat)percent
{
    NSLog(@"update");
    
    [self.transitionContext updateInteractiveTransition:percent];
    
    // 画面遷移コンテキストから遷移元、遷移先ビューコントローラの取得
    UIViewController *fromVC = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    // UIViewController *toVC   = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect initFrame      = [self.transitionContext initialFrameForViewController:fromVC];
    CGRect frame = fromVC.view.frame;
    
    frame.origin.x = initFrame.size.width * percent;
    fromVC.view.frame = frame;
}

- (void)cancelInteractiveTransition
{
    NSLog(@"cancelInteractiveTransition");
    
    UIViewController *fromVC = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect initFrame  = [self.transitionContext initialFrameForViewController:fromVC];
    fromVC.view.frame = initFrame;
    
    [self.transitionContext cancelInteractiveTransition];
    [self.transitionContext completeTransition:NO];
}

- (void)finishInteractiveTransition
{
    NSLog(@"finishInteractiveTransition");
    [self.transitionContext finishInteractiveTransition];
    [self.transitionContext completeTransition:YES];
}

// updateなどから呼ばれ続ける？
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"startinteractiveTransition");
    self.transitionContext = transitionContext;
    [self animateTransition:transitionContext];
}

@end


