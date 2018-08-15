#import "Headers.h"
#import <SpringBoard/SBReduceMotionDeckSwitcherPersonality.h>
#import "KazeQuickSwitcherIconView.h"
#import "KazeQuickSwitcherIconListView.h"
#import "KazeQuickSwitcherHighlightView.h"
#import "KazeQuickSwitcherHighlightViewLayoutAttributes.h"

static BOOL isSwitcherEmpty;

static NSArray *kAppLayouts;
static CGFloat starty;
static CGAffineTransform origTransform;
static KazeQuickSwitcherIconListView *iconListView;


static void setNormalizedOffset(CGFloat normalizedOffset) {
    SBAppSwitcherScrollView *scrollView = KazeDeckSwitchController().scrollView;
    CGFloat fullWidth = scrollView.contentSize.width;
    CGFloat scrollWidth = scrollView.bounds.size.width;
    CGFloat normalizationFactor = fullWidth - scrollWidth;
    CGFloat offset = fullWidth - scrollWidth - normalizedOffset * normalizationFactor;
    setContentOffset(CGPointMake(offset, 0));
}

static void loadAppLayout(SBMainSwitcherViewController *switcherViewController) {
    kAppLayouts = [switcherViewController valueForKey:@"_appLayouts"];
    if (kAppLayouts.count == 0) {
        isSwitcherEmpty = YES;
        return;
    }
    if (quickSwitching) {
        [KazeDeckSwitchController().view addSubview:iconListView];
        
        KazeAnimate(0.2f, ^{
            [iconListView show];
        }, nil);
    }
    NSMutableArray *applications = [NSMutableArray array];
    NSInteger startingIndex = 0;
    [kAppLayouts enumerateObjectsUsingBlock:^(SBAppLayout *item, NSUInteger index, BOOL *stop) {
        SBDisplayItem *displayItem = [item allItems][startingIndex];
        [applications addObject:displayItem.displayIdentifier];
    }];

    [iconListView loadApplications:applications startingIndex:startingIndex isReversed:[KazePreferencesValue(kInvertHotCornersKey()) boolValue]];
}

static void gestureBegan(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iconListView = [[KazeQuickSwitcherIconListView alloc] initWithFrame:kScreenFrame];        
    });

    if (KazeHasFrontmostApplication()) { // this needs to execute early
        [KazeSpringBoard() _simulateHomeButtonPress];
    }
    quickSwitching = YES;
    isSwitcherEmpty = NO;
    origTransform = KazeContainerView().transform;
    KazePresentInteractiveSwitcherBegin();
    loadAppLayout(KazeSwitcherController());
    setNormalizedOffset(0); // fix cards showing too early
}


static void gestureChanged(CGPoint position) {
    if (isSwitcherEmpty) {
        return ; // fix empty card in switcher crash
    }

    CGFloat viewHeight = KazeContainerView().bounds.size.height;
    CGFloat maxTouchHeight = viewHeight / 3;
    CGFloat touchHeight = viewHeight - position.y;
    CGFloat highlightHeight = KazeRubberbandValue(touchHeight, maxTouchHeight);
    CGPoint highlightPoint = CGPointMake(position.x, iconListView.bounds.size.height - highlightHeight);
    CGFloat step = touchHeight / maxTouchHeight;
    [iconListView setHighlightPoint:highlightPoint];
    [iconListView setHintShowing:step > 1.0];

    if (![KazeSwitcherController() isVisible]) {
        starty = position.y;
        return ;
    }
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -highlightHeight);
    step = 1.1 - highlightHeight / viewHeight;
    transform = CGAffineTransformScale(transform, step, step);
    KazeContainerView().transform = transform;

    setNormalizedOffset(iconListView.normalizedHighlightOffset);
}

static void cleanUp(void) {
    quickSwitching = NO;
    [iconListView stopScrolling];
    [iconListView hide];
    [iconListView removeFromSuperview];
    KazeContainerView().transform = origTransform;
    [KazeSwitcherController() _rebuildAppListCache];
    [KazeDeckSwitchController() _updateScrollViewSizeAndSpacing];
}

static void gestureEnded(CGPoint velocity) {
    cleanUp();
    BOOL upward = [KazePreferencesValue(kAccessAppSwitcherKey()) boolValue] && velocity.y < -100;
    if (!upward && !isSwitcherEmpty) {
        NSUInteger highlightIndex = iconListView.highlightIndex;
        [KazeDeckSwitchController() _updateScrollViewContentOffsetToFocusIndex:highlightIndex animated:NO completion:nil];
        SBAppLayout *applayout = kAppLayouts[highlightIndex];
        KazeSwitcherController()._returnToAppLayout = applayout;
        KazeDismissInteractiveSwitcher();
    }
}

static void gestureCancelled(void) {
    cleanUp();
}

KazeGestureConditionBlock KazeQuickSwitcherCondition = ^BOOL(KazeGestureRegion region) {
    return [KazePreferencesValue(kQuickSwitcherEnabledKey()) boolValue]
        && region == ([KazePreferencesValue(kInvertHotCornersKey()) boolValue] ? KazeGestureRegionRight : KazeGestureRegionLeft)
        && !KazeDeviceLocked()
        && !KazeSwitcherShowing()
        && KazeSwitcherAllowed();
};

KazeGestureHandlerBlock KazeQuickSwitcherHandler = ^void(UIGestureRecognizerState state, CGPoint position, CGPoint velocity) {
    // NSLog(@"KazeQuickSwitcherHandler UIGestureRecognizerStateBegan");
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

static CGFloat const cardMargin = 16;
static CGFloat const minDepth = -0.4;
// static CGFloat const minScale = 0.5;


%hook SBDeckSwitcherPersonality

-(double)opacityForIndex:(unsigned long long)arg1 {
    if (quickSwitching)
        return [KazePreferencesValue(kCardOpacityKey()) floatValue];
    return %orig;
}
-(double)titleAndIconOpacityForIndex:(unsigned long long)arg1 {
    if (quickSwitching)
        return 0;
    return %orig;
}
-(double)titleOpacityForIndex:(unsigned long long)arg1 {
    if (quickSwitching)
        return 0;
    return %orig;
}
-(double)_depthForIndex:(unsigned long long)index displayItemsCount:(unsigned long long)count scrollProgress:(double)scrollProgress ignoreInsertionsAndRemovals:(BOOL)arg4 {
    double origdepth = %orig;
    if (!quickSwitching)
        return origdepth;

    CGFloat effectiveIndex = index;
    CGFloat effectiveHighlightIndex = scrollProgress * (count - 1);
    CGFloat distance = ABS(effectiveIndex - effectiveHighlightIndex);
    CGFloat depth = distance > 1 ? minDepth : (-0.5 * (cos(distance * M_PI) - 1)) * minDepth;
    return depth;
}
-(CGRect)_frameForIndex:(unsigned long long)index displayItemsCount:(unsigned long long)count stackedProgress:(double)stackedProgress scrollProgress:(double)scrollProgress ignoringScrollOffset:(BOOL)arg5 ignoreInsertionsAndRemovals:(BOOL)arg6 {
    CGRect origframe = %orig;
    if (!quickSwitching)
        return origframe;

    CGSize size = KazeDeckSwitchController().view.bounds.size;
    CGFloat cardwidth = size.width * [self scaleForIndex:index mode:1] + cardMargin;
    count -= 1;
    CGFloat x = cardwidth * (count * scrollProgress - index);
    CGRect frame = (CGRect){{x, 0}, size};
    return frame;
}

// -(double)_scrollProgressForIndex:(unsigned long long)index displayItemsCount:(unsigned long long)count depth:(double)arg3 ignoreInsertionsAndRemovals:(BOOL)arg4 {
//     if (quickSwitching)
//         return count > 1 ? ((CGFloat)index) / (count - 1) : 0.4;
//     return %orig;
// }
// -(double)_scrollProgressForIndex:(unsigned long long)index {
//     if (quickSwitching)
//         return kAppLayouts.count > 1 ? ((CGFloat)index) / (kAppLayouts.count - 1) : 0.4;
//     return %orig;
// }
%end
