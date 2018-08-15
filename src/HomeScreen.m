#import "Headers.h"

// static CGPoint oldContentOffset;
id context;

// CHDeclareClass(SBReachabilityManager)
void KazeSwitcherSetTransitionOffset(CGFloat yOffset) {
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, yOffset);
    KazeContainerView().transform = transform;
}

static void gestureBegan(void) {
    homeSwitching = YES;
    SBAppLayout *applayout = [OfClass(SBAppLayout) homeScreenAppLayout];
    KazeSwitcherController()._returnToAppLayout = applayout;
    // context = [KazeSwitcherController().initialLayoutState transitionContextForActivatingAppLayout:applayout];
    context = [KazeSwitcherController().initialLayoutState transitionContextForActivatingHomeScreen];
    NSLog(@"gestureBegan %@", LOG(KazeSwitcherController().initialLayoutState));
    // KazePresentInteractiveSwitcherBegin();
    SBMainDisplaySceneLayoutViewController *sceneController = IvarOf(KazeSwitcherController(), _sceneLayoutViewController);
    [KazeSwitcherController() sceneLayoutController:sceneController didBeginLayoutStateTransitionWithContext:context];

}

static void gestureChanged(CGPoint position) {
    KazeSwitcherSetTransitionOffset(position.y - kScreenHeight);
    [KazeSpringBoard() _simulateHomeButtonPress];
}

static void gestureEnded(CGPoint position, CGPoint velocity) {
    CGFloat upward = velocity.y <= 0;
    CGFloat height = KazeContainerView().bounds.size.height;
    CGFloat distance = upward ? position.y : height - position.y;
    CGFloat springVelocity = ABS(velocity.y) / distance;
    CGFloat yOffset = upward ? -kScreenHeight : 0;
    
    KazeSpring(0.4, 1.0, springVelocity, ^{
        KazeSwitcherSetTransitionOffset(yOffset);
    }, ^(BOOL finished) {
        // KazeDismissInteractiveSwitcher();
        KazeSwitcherSetTransitionOffset(0);
    });
    // KazePresentInteractiveSwitcherEnd();
    homeSwitching = NO;
    

    // SBMainDisplaySceneLayoutViewController *sceneController = IvarOf(KazeSwitcherController(), _sceneLayoutViewController);
    // [KazeDeckSwitchController() performTransitionWithContext:context animated:YES completion:nil];
    // [KazeSwitcherController() sceneLayoutControllerDidEndLayoutStateTransition:KazeSwitcherController().initialLayoutState wasInterrupted:NO];
}

static void gestureCancelled(void) {
    [KazeSpringBoard() _simulateHomeButtonPress];

    // KazePresentInteractiveSwitcherEnd();
    KazeSpring(0.4, 1.0, 1.0, ^{
        KazeSwitcherSetTransitionOffset(kScreenHeight);
        
    }, ^(BOOL finished) {
        KazeDismissInteractiveSwitcher();
    });
    homeSwitching = NO;
}


KazeGestureConditionBlock KazeHomeScreenCondition = ^BOOL(KazeGestureRegion region) {
    return [KazePreferencesValue(kHotCornersEnabledKey()) boolValue]
        && region == ([KazePreferencesValue(kInvertHotCornersKey()) boolValue] ? KazeGestureRegionLeft : KazeGestureRegionRight)
        && !KazeDeviceLocked()
        && !KazeSwitcherShowing()
        && KazeHasFrontmostApplication();
};

KazeGestureHandlerBlock KazeHomeScreenHandler = ^void(UIGestureRecognizerState state, CGPoint position, CGPoint velocity) {
    switch (state) {
        case UIGestureRecognizerStateBegan:
            gestureBegan();
            gestureChanged(position);
            break;
        case UIGestureRecognizerStateChanged:
            gestureChanged(position);
            break;
        case UIGestureRecognizerStateEnded:
            gestureEnded(position, velocity);
            break;
        default:
            gestureCancelled();
            break;
    }
};

CHConstructor {
    @autoreleasepool {
        // CHLoadLateClass(SBReachabilityManager);
    }
}