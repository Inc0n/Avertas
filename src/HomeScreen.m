#import "Headers.h"

static CGPoint oldContentOffset;

// CHDeclareClass(SBReachabilityManager)

static void gestureBegan(void) {
    SBAppSwitcherScrollView *scrollView = KazeDeckSwitchController().scrollView;
    oldContentOffset = scrollView.contentOffset;

    // SBMainWorkspaceTransitionRequest *request = [[OfClass(SBMainWorkspace) mainWorkspace] createRequestWithOptions:0];
    // request.eventLabel = @"ActivateSpringBoard";
}

static void gestureChanged(CGPoint position) {
    // CGFloat height = KazeSpringBoard().keyWindow.bounds.size.height;
    // CGFloat step = MIN((height - position.y) / (height / 2), 1);
    // float factor = MIN(MAX(1 - step, 0.01), 1.0);
    // CGPointMake(oldContentOffset.x, oldContentOffset.y);
    [KazeSpringBoard() _simulateHomeButtonPress];
}

static void gestureEnded(CGPoint velocity) {
    NSLog(@"hello here");
    
    BOOL forward = velocity.y <= 0;
    if (forward) {
    } else {
        // SBAppLayout *applayout = [OfClass(SBAppLayout) homeScreenAppLayout];
        // KazeSwitcherController()._returnToAppLayout = applayout;
    }

}

static void gestureCancelled(void) {
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
            gestureEnded(velocity);
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