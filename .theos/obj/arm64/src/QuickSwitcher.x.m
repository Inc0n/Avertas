#line 1 "src/QuickSwitcher.x"
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

    if (KazeHasFrontmostApplication()) { 
        [KazeSpringBoard() _simulateHomeButtonPress];
    }
    quickSwitching = YES;
    isSwitcherEmpty = NO;
    origTransform = KazeContainerView().transform;
    KazePresentInteractiveSwitcherBegin();
    loadAppLayout(KazeSwitcherController());
    setNormalizedOffset(0); 
}


static void gestureChanged(CGPoint position) {
    if (isSwitcherEmpty) {
        return ; 
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




#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SBDeckSwitcherPersonality; 
static double (*_logos_orig$_ungrouped$SBDeckSwitcherPersonality$opacityForIndex$)(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, unsigned long long); static double _logos_method$_ungrouped$SBDeckSwitcherPersonality$opacityForIndex$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, unsigned long long); static double (*_logos_orig$_ungrouped$SBDeckSwitcherPersonality$titleAndIconOpacityForIndex$)(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, unsigned long long); static double _logos_method$_ungrouped$SBDeckSwitcherPersonality$titleAndIconOpacityForIndex$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, unsigned long long); static double (*_logos_orig$_ungrouped$SBDeckSwitcherPersonality$titleOpacityForIndex$)(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, unsigned long long); static double _logos_method$_ungrouped$SBDeckSwitcherPersonality$titleOpacityForIndex$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, unsigned long long); static double (*_logos_orig$_ungrouped$SBDeckSwitcherPersonality$_depthForIndex$displayItemsCount$scrollProgress$ignoreInsertionsAndRemovals$)(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, unsigned long long, unsigned long long, double, BOOL); static double _logos_method$_ungrouped$SBDeckSwitcherPersonality$_depthForIndex$displayItemsCount$scrollProgress$ignoreInsertionsAndRemovals$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, unsigned long long, unsigned long long, double, BOOL); static CGRect (*_logos_orig$_ungrouped$SBDeckSwitcherPersonality$_frameForIndex$displayItemsCount$stackedProgress$scrollProgress$ignoringScrollOffset$ignoreInsertionsAndRemovals$)(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, unsigned long long, unsigned long long, double, double, BOOL, BOOL); static CGRect _logos_method$_ungrouped$SBDeckSwitcherPersonality$_frameForIndex$displayItemsCount$stackedProgress$scrollProgress$ignoringScrollOffset$ignoreInsertionsAndRemovals$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, unsigned long long, unsigned long long, double, double, BOOL, BOOL); 

#line 151 "src/QuickSwitcher.x"


static double _logos_method$_ungrouped$SBDeckSwitcherPersonality$opacityForIndex$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, unsigned long long arg1) {
    if (quickSwitching)
        return [KazePreferencesValue(kCardOpacityKey()) floatValue];
    return _logos_orig$_ungrouped$SBDeckSwitcherPersonality$opacityForIndex$(self, _cmd, arg1);
}
static double _logos_method$_ungrouped$SBDeckSwitcherPersonality$titleAndIconOpacityForIndex$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, unsigned long long arg1) {
    if (quickSwitching)
        return 0;
    return _logos_orig$_ungrouped$SBDeckSwitcherPersonality$titleAndIconOpacityForIndex$(self, _cmd, arg1);
}
static double _logos_method$_ungrouped$SBDeckSwitcherPersonality$titleOpacityForIndex$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, unsigned long long arg1) {
    if (quickSwitching)
        return 0;
    return _logos_orig$_ungrouped$SBDeckSwitcherPersonality$titleOpacityForIndex$(self, _cmd, arg1);
}
static double _logos_method$_ungrouped$SBDeckSwitcherPersonality$_depthForIndex$displayItemsCount$scrollProgress$ignoreInsertionsAndRemovals$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, unsigned long long index, unsigned long long count, double scrollProgress, BOOL arg4) {
    double origdepth = _logos_orig$_ungrouped$SBDeckSwitcherPersonality$_depthForIndex$displayItemsCount$scrollProgress$ignoreInsertionsAndRemovals$(self, _cmd, index, count, scrollProgress, arg4);
    if (!quickSwitching)
        return origdepth;

    CGFloat effectiveIndex = index;
    CGFloat effectiveHighlightIndex = scrollProgress * (count - 1);
    CGFloat distance = ABS(effectiveIndex - effectiveHighlightIndex);
    CGFloat depth = distance > 1 ? minDepth : (-0.5 * (cos(distance * M_PI) - 1)) * minDepth;
    return depth;
}
static CGRect _logos_method$_ungrouped$SBDeckSwitcherPersonality$_frameForIndex$displayItemsCount$stackedProgress$scrollProgress$ignoringScrollOffset$ignoreInsertionsAndRemovals$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, unsigned long long index, unsigned long long count, double stackedProgress, double scrollProgress, BOOL arg5, BOOL arg6) {
    CGRect origframe = _logos_orig$_ungrouped$SBDeckSwitcherPersonality$_frameForIndex$displayItemsCount$stackedProgress$scrollProgress$ignoringScrollOffset$ignoreInsertionsAndRemovals$(self, _cmd, index, count, stackedProgress, scrollProgress, arg5, arg6);
    if (!quickSwitching)
        return origframe;

    CGSize size = KazeDeckSwitchController().view.bounds.size;
    CGFloat cardwidth = size.width * [self scaleForIndex:index mode:1] + cardMargin;
    count -= 1;
    CGFloat x = cardwidth * (count * scrollProgress - index);
    CGRect frame = (CGRect){{x, 0}, size};
    return frame;
}












static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBDeckSwitcherPersonality = objc_getClass("SBDeckSwitcherPersonality"); MSHookMessageEx(_logos_class$_ungrouped$SBDeckSwitcherPersonality, @selector(opacityForIndex:), (IMP)&_logos_method$_ungrouped$SBDeckSwitcherPersonality$opacityForIndex$, (IMP*)&_logos_orig$_ungrouped$SBDeckSwitcherPersonality$opacityForIndex$);MSHookMessageEx(_logos_class$_ungrouped$SBDeckSwitcherPersonality, @selector(titleAndIconOpacityForIndex:), (IMP)&_logos_method$_ungrouped$SBDeckSwitcherPersonality$titleAndIconOpacityForIndex$, (IMP*)&_logos_orig$_ungrouped$SBDeckSwitcherPersonality$titleAndIconOpacityForIndex$);MSHookMessageEx(_logos_class$_ungrouped$SBDeckSwitcherPersonality, @selector(titleOpacityForIndex:), (IMP)&_logos_method$_ungrouped$SBDeckSwitcherPersonality$titleOpacityForIndex$, (IMP*)&_logos_orig$_ungrouped$SBDeckSwitcherPersonality$titleOpacityForIndex$);MSHookMessageEx(_logos_class$_ungrouped$SBDeckSwitcherPersonality, @selector(_depthForIndex:displayItemsCount:scrollProgress:ignoreInsertionsAndRemovals:), (IMP)&_logos_method$_ungrouped$SBDeckSwitcherPersonality$_depthForIndex$displayItemsCount$scrollProgress$ignoreInsertionsAndRemovals$, (IMP*)&_logos_orig$_ungrouped$SBDeckSwitcherPersonality$_depthForIndex$displayItemsCount$scrollProgress$ignoreInsertionsAndRemovals$);MSHookMessageEx(_logos_class$_ungrouped$SBDeckSwitcherPersonality, @selector(_frameForIndex:displayItemsCount:stackedProgress:scrollProgress:ignoringScrollOffset:ignoreInsertionsAndRemovals:), (IMP)&_logos_method$_ungrouped$SBDeckSwitcherPersonality$_frameForIndex$displayItemsCount$stackedProgress$scrollProgress$ignoringScrollOffset$ignoreInsertionsAndRemovals$, (IMP*)&_logos_orig$_ungrouped$SBDeckSwitcherPersonality$_frameForIndex$displayItemsCount$stackedProgress$scrollProgress$ignoringScrollOffset$ignoreInsertionsAndRemovals$);} }
#line 203 "src/QuickSwitcher.x"
