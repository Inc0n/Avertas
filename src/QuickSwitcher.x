#import "Headers.h"
#import <SpringBoard/SBReduceMotionDeckSwitcherPersonality.h>
#import "KazeQuickSwitcherIconView.h"
#import "KazeQuickSwitcherIconListView.h"
#import "KazeQuickSwitcherHighlightView.h"
#import "KazeQuickSwitcherHighlightViewLayoutAttributes.h"

@interface KazeQuickSwitcherDeckViewController : SBDeckSwitcherViewController
// @property(assign, nonatomic) CGFloat normalizedOffset;
// - (void)setNormalizedOffset:(CGFloat)normalizedOffset animated:(BOOL)animated completion:(UIViewAnimationCompletionBlock)completion;
@end


static BOOL quickSwitching = NO;
static BOOL stopWithEmptySwitcher;

static NSArray *kAppLayouts;
static KazeQuickSwitcherIconListView *iconListView;



static void setNormalizedOffset(CGFloat normalizedOffset) {
    SBAppSwitcherScrollView *scrollView = KazeDeckSwitchController().scrollView;
    CGFloat fullWidth = scrollView.contentSize.width;
    CGFloat scrollWidth = scrollView.bounds.size.width;
    CGFloat normalizationFactor = fullWidth - scrollWidth;

    CGFloat offset = fullWidth - normalizedOffset * normalizationFactor - scrollWidth;
    setContentOffset(CGPointMake(offset, 0));
}

static void loadAppLayout(SBMainSwitcherViewController *switcherViewController) {
    kAppLayouts = [switcherViewController valueForKey:@"_appLayouts"];
    if (kAppLayouts.count == 0) {
        stopWithEmptySwitcher = YES;
        return;
    }
    if (quickSwitching) {
        [KazeContainerView() addSubview:iconListView];
        
        KazeBasicAnimate(^{
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

    KazeBasicAnimate(^{
        if (KazeHasFrontmostApplication()) {
            [KazeSpringBoard() _simulateHomeButtonPress];
        }
    }, ^(BOOL finished) {
        quickSwitching = YES;
        KazePresentInteractiveSwitcherBegin(NULL, NULL);
        loadAppLayout(KazeSwitcherController());
    });
    // KazePresentInteractiveSwitcherBegin();
    // KazeDeckSwitchController().scrollView.scrollEnabled = NO;
}


static void gestureChanged(CGPoint position) {
    if (kAppLayouts.count == 0) {
        return ;
    }

    CGFloat viewHeight = KazeContainerView().bounds.size.height;
    CGFloat maxTouchHeight = viewHeight / 3;
    CGFloat touchHeight = viewHeight - position.y;
    CGFloat highlightHeight = KazeRubberbandValue(touchHeight, maxTouchHeight);
    CGFloat step = highlightHeight / maxTouchHeight;
    CGPoint highlightPoint = CGPointMake(position.x, iconListView.bounds.size.height - highlightHeight);
    [iconListView setHighlightPoint:highlightPoint];
    [iconListView setHintShowing:step > 1.0];

    if (![KazeSwitcherController() isVisible]) {
        return ;
    }

    // NSUInteger highlightIndex = iconListView.highlightIndex;
    // SBAppLayout *applayout = kAppLayouts[highlightIndex];

    setNormalizedOffset(iconListView.normalizedHighlightOffset);
}

static void gestureEnded(CGPoint velocity) {
    quickSwitching = NO;
    [iconListView stopScrolling];

    KazeBasicAnimate(^{
        [iconListView hide:NO];
    }, nil);
    if (kAppLayouts.count > 0) {
        NSUInteger highlightIndex = iconListView.highlightIndex;
        [KazeDeckSwitchController() _updateScrollViewContentOffsetToFocusIndex:highlightIndex animated:NO completion:nil];
        SBAppLayout *applayout = kAppLayouts[highlightIndex];
        KazeSwitcherController()._returnToAppLayout = applayout;
    }
    [KazeSwitcherController() _rebuildAppListCache];
    [KazeDeckSwitchController() _updateScrollViewSizeAndSpacing];
    [iconListView removeFromSuperview];
    KazeDismissInteractiveSwitcher();
}

static void gestureCancelled(void) {
    return ;

    quickSwitching = NO;
    [iconListView stopScrolling];
    SBAppLayout *applayout = kAppLayouts[1];
    if (applayout) {
        [KazeSwitcherController() switcherContentController:KazeDeckSwitchController() bringAppLayoutToFront:applayout];
    }
    KazeSwitcherController()._returnToAppLayout = applayout;

    KazeDismissInteractiveSwitcher();
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
            KazeSBAnimate(^{
                gestureBegan();
            }, ^(BOOL finished){
                setNormalizedOffset(0);
            });
            gestureChanged(position); 
            break;
        case UIGestureRecognizerStateChanged:
            gestureChanged(position);
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"ended?? %ld", state);
            gestureEnded(velocity);
            break;
        default:
            NSLog(@"failed?? cancel?? %ld", state);
            break;
            gestureCancelled();
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
    // return %orig;
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
-(double)scaleForIndex:(unsigned long long)arg1 mode:(long long)arg2 {
    double scale = %orig;
    if (quickSwitching) 
        return scale;
    if ([KazeSwitcherController() isVisible])
        return 0.7;
    return scale;
}

-(double)_scrollProgressForIndex:(unsigned long long)index displayItemsCount:(unsigned long long)count depth:(double)arg3 ignoreInsertionsAndRemovals:(BOOL)arg4 {
    if (quickSwitching)
        return count > 1 ? ((CGFloat)index) / (count - 1) : 0.4;
    return %orig;
}
-(double)_scrollProgressForIndex:(unsigned long long)index {
    if (quickSwitching)
        return kAppLayouts.count > 1 ? ((CGFloat)index) / (kAppLayouts.count - 1) : 0.4;
    return %orig;
}
%end

// CHOptimizedMethod(1, super, double, KazeQuickSwitcherDeckViewController, _scaleForPresentedProgress, CGFloat, presentedProgress) {
//     return 1;
// }

// CHOptimizedMethod(2, super, CGFloat, KazeQuickSwitcherDeckViewController, _blurForIndex, NSUInteger, index, scrollProgress, double, progress) {
//     return 0;
// }

// CHOptimizedMethod(4, super, double, KazeQuickSwitcherDeckViewController, _scrollProgressForIndex, NSUInteger, index, displayItemsCount, NSUInteger, count, depth, double, depth, ignoringKillOffset, BOOL, ignoringKillOffset) {
//     return count > 1 ? ((CGFloat)index) / (count - 1) : 0;
// }


// @interface KazeQuickSwitcherIconListView () <UICollectionViewDataSource, UICollectionViewDelegate>
// - (SBLeafIcon *)iconAtIndex:(NSUInteger)index;
// @end