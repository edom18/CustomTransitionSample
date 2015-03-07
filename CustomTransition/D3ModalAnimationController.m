
#import "D3ModalAnimationController.h"

@implementation D3ModalAnimationController

static D3ModalAnimationController *instance;

+ (instancetype)defaultController
{
    @synchronized(self.class) {
        if (!instance) {
            instance = [[self.class alloc] init];
        }
        
        return instance;
    }
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self;
}


/**
 *  It will be called when view controller is going to dismiss.
 *
 *  @param dismissed dismissed view controller
 *
 *  @return animator object. if it will return `nil`, system use a default transition.
 */
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return nil;
}


/**
 *  It will be called when view controller is dismissing.
 *
 *  @param animator animator object
 *
 *  @return transition controller
 */
- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self;
}

@end
