
@import UIKit;

@interface D3AnimationController : NSObject
<
UIViewControllerAnimatedTransitioning,
UIViewControllerInteractiveTransitioning,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate
>

typedef NS_ENUM(NSInteger, D3AnimationControllerEventType) {
    D3AnimationControllerEventTypeStart = 0,
    D3AnimationControllerEventTypeUpdate,
    D3AnimationControllerEventTypeEnd,
};

typedef id self;
typedef void(^D3AnimationControllerEventBlock)(__typeof(self) self,
                                               D3AnimationController *animationController,
                                               D3AnimationControllerEventType type,
                                               NSDictionary *data);

@property (nonatomic, assign, readonly) BOOL isSwipe;
@property (nonatomic, strong, readonly) UIScreenEdgePanGestureRecognizer *edgePanGesture;

+ (instancetype)defaultController;

- (UINavigationController *)navigationController;
- (void)setNavigationController:(UINavigationController *)navigationController;

@end
