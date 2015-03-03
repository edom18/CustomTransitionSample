
@import UIKit;

@interface FadeAnimationController : NSObject
<
UIViewControllerAnimatedTransitioning,
UIViewControllerInteractiveTransitioning
>

/**
 *  スワイプかどうか
 */
@property (nonatomic, assign) BOOL isSwipe;


/**
 *  Transition contextを保持
 */
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;


/**
 *  生成メソッド
 */
+ (instancetype)create;


/**
 *  生成メソッド
 */
+ (instancetype)createAsSwipe;


/**
 *  Update transition context
 *
 *  @param percent 遷移の進捗度を表す値（0.0〜1.0）
 */
- (void)updateInteractiveTransition:(CGFloat)percent;


/**
 *  遷移をキャンセルする
 */
- (void)cancelInteractiveTransition;


/**
 *  遷移を完了する
 */
- (void)finishInteractiveTransition;

@end
