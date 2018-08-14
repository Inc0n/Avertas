#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CaptainHook.h>
#import <SpringBoard/SBGrabberTongue.h>
#import <SpringBoard/SBMainSwitcherViewController.h>

#import <BaseBoardUI/BSUIAnimationFactory.h>
#import <BaseBoard/BSSpringAnimationSettings.h>

#import <SpringBoard/SBIcon.h>
#import <SpringBoard/SBAppLayout.h>
#import <SpringBoard/SpringBoard-Class.h>
#import <SpringBoard/SBMainWorkspace.h>
#import <SpringBoard/SBMainDisplaySceneLayoutViewController.h>
#import <SpringBoard/SBMainDisplayLayoutState.h>
#import <SpringBoard/SBDeckSwitcherViewController.h>
#import <SpringBoard/SBControlCenterController.h>
#import <SpringBoard/SBRootAnimationSettings.h>
#import <SpringBoard/SBDeckSwitcherPersonality.h>
#import <SpringBoard/SBMainWorkspaceTransitionRequest.h>


#import <Hook.h>
#import <Constant.h>

#import "KazeQuickSwitcherIconView.h"
#import "KazeQuickSwitcherHighlightView.h"
#import "KazeQuickSwitcherIconListViewLayout.h"
#import "KazeQuickSwitcherHighlightViewLayoutAttributes.h"

typedef void (^UIViewAnimationActionsBlock)(void);
typedef void (^UIViewAnimationCompletionBlock)(BOOL finished);

@interface UIWindow (Private)
- (void)_setRotatableViewOrientation:(UIInterfaceOrientation)orientation updateStatusBar:(BOOL)updateStatusBar duration:(NSTimeInterval)duration force:(BOOL)force;
@end

@interface UIView (Private)
+ (void)_setupAnimationWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay view:(UIView *)view options:(UIViewAnimationOptions)options factory:(id<_UIBasicAnimationFactory>)factory animations:(UIViewAnimationActionsBlock)animations start:(id)start animationStateGenerator:(id)generator completion:(UIViewAnimationCompletionBlock)completion;
@end

@interface UIScrollView (Private)
- (void)handlePan:(UIPanGestureRecognizer *)gesture;
@end

@interface UIImage (Private)
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format scale:(CGFloat)scale;
- (UIImage *)_imageScaledToProportion:(CGFloat)proportion interpolationQuality:(CGInterpolationQuality)quality;
@end

@interface _UIBackdropView : UIView
@property (copy, nonatomic) NSString *groupName;
@property (assign, nonatomic) NSTimeInterval appliesOutputSettingsAnimationDuration;
- (instancetype)initWithStyle:(NSInteger)style;
- (instancetype)initWithPrivateStyle:(NSInteger)style;
@end

@interface CALayer (Private)
@property (assign) BOOL allowsGroupBlending;
@end

@interface BSEventQueueEvent : NSObject
@end

@interface BSEventQueue : NSObject
@property (retain, nonatomic) BSEventQueueEvent *executingEvent;
@property (copy, nonatomic, readonly) NSArray *pendingEvents;
@end


@interface FBWorkspaceEventQueue : BSEventQueue
+ (instancetype)sharedInstance;
@end

extern void BKSHIDServicesSetBacklightFactorWithFadeDuration(float factor, float duration, BOOL unknown);

extern void BKSHIDServicesSetBacklightFactorWithFadeDurationSilently(float factor, float duration, BOOL unknown);
// unknown = NO  in -[SBPowerDownView actionSlider:didUpdateSlideWithValue:], -[SBPowerDownView _resetScreenBrightness]
// unknown = YES in -[SBBacklightController _animateBacklightToFactor:duration:source:silently:completion:]

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
@end

@interface SBDisplayItem : NSObject
@property(copy, nonatomic, readonly) NSString *displayIdentifier;
@property(copy, nonatomic, readonly) NSString *type;
+ (instancetype)displayItemWithType:(NSString *)type displayIdentifier:(id)identifier;
+ (instancetype)homeScreenDisplayItem;
+ (instancetype)sideSwitcherDisplayItem;
@end

@interface SBBestAppSuggestion : NSObject
@property(copy, readonly) NSString *bundleIdentifier;
@end

@interface SBWorkspaceTransaction : NSObject
@end

@interface SBMainWorkspaceTransaction : SBWorkspaceTransaction
@end

typedef BOOL (^SBValidator)(SBWorkspaceTransitionRequest *);
typedef void (^SBTransitionRequestBuilder)(SBWorkspaceTransitionRequest *);
typedef SBWorkspaceTransaction * (^SBTransactionProvider)(SBWorkspaceTransitionRequest *);

@interface SBWorkspaceEntity : NSObject
@end

typedef NS_ENUM(NSUInteger, SBSystemGestureType) {
    SBSystemGestureTypeNotificationCenter = 1,
    SBSystemGestureTypeDismissBanner = 2,
    SBSystemGestureTypeControlCenter = 3,
    SBSystemGestureTypeForcePressSwitcher = 13
};

@interface SBScreenEdgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer
@end

@interface SBSystemGestureManager : NSObject {
    NSMutableDictionary *_typeToGesture;
    NSMutableDictionary *_typeToState;
    NSMutableSet *_recognizingGestures;
}
@property(retain, nonatomic, readonly) id display;
@property(assign, nonatomic, readonly, getter=isAnyTouchGestureRunning) BOOL anyTouchGestureRunning;
@property(assign, nonatomic, getter=areSystemGesturesDisabledForAccessibility) BOOL systemGesturesDisabledForAccessibility;
+ (instancetype)mainDisplayManager;
- (instancetype)initWithDisplay:(id)display;
- (void)addGestureRecognizer:(UIGestureRecognizer *)recognizer withType:(SBSystemGestureType)type;
- (BOOL)isGestureWithTypeAllowed:(SBSystemGestureType)typeAllowed;
- (void)removeGestureRecognizer:(UIGestureRecognizer *)recognizer;
- (void)updateUserPreferences;
@end

@interface SBAppSwitcherScrollView : UIScrollView
@end

@class SBAppSwitcherPageView;

@protocol SBAppSwitcherPageContentView <NSObject>
- (CGFloat)cornerRadius;
- (void)setCornerRadius:(CGFloat)radius;
- (void)invalidate;
@optional
- (void)prepareToBecomeVisibleIfNecessary;
- (void)respondToBecomingInvisibleIfNecessary;
- (void)viewPresenting:(SBAppSwitcherPageView *)view withInteraction:(BOOL)interaction andInitialProgress:(CGFloat)initialProgress forTransitionRequest:(SBWorkspaceTransitionRequest *)transitionRequest;
- (void)viewDismissing:(SBAppSwitcherPageView *)view withInteraction:(BOOL)interaction andInitialProgress:(CGFloat)initialProgress forTransitionRequest:(SBWorkspaceTransitionRequest *)transitionRequest;
- (void)updateTransitionProgress:(CGFloat)progress;
- (void)interactionDidEnd:(BOOL)interaction;
- (void)transitionDidEnd:(BOOL)transition forPresentation:(BOOL)presentation;
@end

@protocol SBMainAppSwitcherPageContentView <SBAppSwitcherPageContentView>
- (UIInterfaceOrientation)orientation;
- (void)setOrientation:(UIInterfaceOrientation)orientation;
@optional
- (void)simplifyForMotion;
- (void)unsimplifyAfterMotion;
@end

@interface SBSwitcherWallpaperPageContentView : UIView <SBMainAppSwitcherPageContentView>
@end

@interface SBSwitcherMetahostingHomePageContentView : SBSwitcherWallpaperPageContentView
- (NSInteger)_targetWallpaperStyle;
@end

@interface SBAppSwitcherPageView : UIView {
    UIView *_hitTestBlocker;
}
@property(retain, nonatomic) UIView<SBAppSwitcherPageContentView> *view;
- (void)setBlocksTouches:(BOOL)touches;
- (void)updateTransitionProgress:(CGFloat)progress;
@end

@interface SBDeckSwitcherPageView : SBAppSwitcherPageView
@property(retain, nonatomic) UIView<SBMainAppSwitcherPageContentView> *view;
@end

@class SBDeckSwitcherItemContainer;

@protocol SBDeckSwitcherItemContainerDelegate <NSObject>
- (CGRect)frameForPageViewOfContainer:(SBDeckSwitcherItemContainer *)container fullyPresented:(BOOL)fullyPresented;
- (BOOL)shouldShowIconAndLabelOfContainer:(SBDeckSwitcherItemContainer *)container;
- (BOOL)canSelectDisplayItemOfContainer:(SBDeckSwitcherItemContainer *)container numberOfTaps:(NSInteger)taps;
- (BOOL)isDisplayItemOfContainerRemovable:(SBDeckSwitcherItemContainer *)container;
- (CGFloat)minimumVerticalTranslationForKillingOfContainer:(SBDeckSwitcherItemContainer *)container;
- (void)scrollViewKillingProgressUpdated:(CGFloat)killingProgress ofContainer:(SBDeckSwitcherItemContainer *)container;
- (void)selectedDisplayItemOfContainer:(SBDeckSwitcherItemContainer *)container;
- (void)killDisplayItemOfContainer:(SBDeckSwitcherItemContainer *)container withVelocity:(CGFloat)velocity;
@end

@interface SBDeckSwitcherItemContainer : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    UIScrollView *_verticalScrollView;
}
@property(assign, nonatomic, readonly) id<SBDeckSwitcherItemContainerDelegate> delegate;
@property(retain, nonatomic, readonly) SBDisplayItem *displayItem;
@property(retain, nonatomic) SBDeckSwitcherPageView *pageView;
@property(assign, nonatomic, readonly) CGFloat killingProgress;
@property(assign, nonatomic) CGFloat unobscuredMargin;
- (UIScrollView *)_createScrollView;
- (void)updateTransitionProgress:(CGFloat)progress;
@end

@interface SBDeckSwitcherPageViewProvider : NSObject
- (SBDeckSwitcherPageView *)pageViewForDisplayItem:(SBDisplayItem *)displayItem synchronously:(BOOL)synchronously;
- (void)purgePageViewForDisplayItem:(SBDisplayItem *)displayItem;
- (void)updateCachedPageViewsWithVisibleItemRange:(NSRange)visibleItemRange scrollDirection:(BOOL)direction allItems:(NSArray *)items;
- (CGSize)_pageViewSizeForDisplayItem:(SBDisplayItem *)displayItem;
- (CGSize)_contentSizeForDisplayItem:(SBDisplayItem *)displayItem;
@end

typedef struct {
    CGFloat progress;
    CGFloat cornerRadiusProgress;
    CGFloat initialItemTranslation;
    CGFloat dimming;
} SBTransitionParameters;


@interface SBLayoutElementContainerView : UIView
@property(retain, nonatomic) UIView *contentView;
@end

@interface SBLayoutElementViewController : UIViewController
@end


@interface SBUIController : NSObject
+ (instancetype)sharedInstance;
- (BOOL)clickedMenuButton;
- (BOOL)handleMenuDoubleTap;
@end

// typedef NS_ENUM(int, SBIconLocation) {
//     SBIconLocationHomeScreen = 1,
//     SBIconLocationCarPlay = 2,
//     SBIconLocationDock = 3,
//     SBIconLocationFolder = 6
// };


@interface SBLeafIcon : SBIcon
- (instancetype)initWithLeafIdentifier:(NSString *)leafIdentifier applicationBundleID:(NSString *)applicationIdentifier;
@end

@interface SBApplicationIcon : SBLeafIcon
@end

@interface SBFolder : NSObject
@end

@interface SBIconImageView : UIView {
    UIImageView *_overlayView;
}
@property(assign, nonatomic) CGFloat overlayAlpha;
@end

@protocol SBIconViewDelegate;

@interface SBIconView : UIView
@property(retain, nonatomic) SBIcon *icon;
@property(assign, nonatomic) id<SBIconViewDelegate> delegate;
@property(assign, nonatomic) CGFloat iconImageAlpha;
@property(assign, nonatomic) CGFloat iconAccessoryAlpha;
@property(assign, nonatomic) CGFloat iconLabelAlpha;
@property(assign, nonatomic, getter=isHighlighted) BOOL highlighted;
+ (CGSize)defaultIconSize;
- (instancetype)initWithContentType:(NSUInteger)contentType;
- (SBIconImageView *)_iconImageView;
@end

@protocol SBIconViewDelegate <NSObject>
@optional
- (CGFloat)scale;
- (CGFloat)iconLabelWidth;
- (BOOL)iconShouldAllowTap:(SBIconView *)iconView;
- (BOOL)iconViewDisplaysCloseBox:(SBIconView *)iconView;
- (BOOL)iconViewDisplaysBadges:(SBIconView *)iconView;
- (BOOL)icon:(SBIconView *)iconView canReceiveGrabbedIcon:(SBIconView *)grabbedIcon;
- (void)iconTapped:(SBIconView *)iconView;
- (void)iconCloseBoxTapped:(SBIconView *)iconView;
- (void)iconHandleLongPress:(SBIconView *)iconView;
- (void)icon:(SBIconView *)iconView openFolder:(SBFolder *)folder animated:(BOOL)animated;
- (void)iconTouchBegan:(SBIconView *)iconView;
- (void)icon:(SBIconView *)iconView touchMoved:(UITouch *)touch;
- (void)icon:(SBIconView *)iconView touchEnded:(BOOL)flag;
@end

@interface SBAppSwitcherIconView : SBIconView
@end

@interface SBIconModel : NSObject
@property(retain, nonatomic) NSDictionary *leafIconsByIdentifier;
- (SBLeafIcon *)leafIconForIdentifier:(NSString *)identifier;
- (SBApplicationIcon *)applicationIconForBundleIdentifier:(NSString *)identifier;
- (void)addIcon:(SBIcon *)icon;
- (void)addIconForApplication:(SBApplication *)application;
- (void)removeIcon:(SBIcon *)icon;
- (void)removeIconForIdentifier:(NSString *)identifier;
- (void)loadAllIcons;
- (BOOL)isIconVisible:(SBIcon *)icon;
@end

@interface SBIconController : NSObject
+ (SBIconController *)sharedInstance;
- (SBIconModel *)model;
@end

#import <SpringBoard/SBControlCenterController.h>

@interface SBMediaController : NSObject
@property(assign, nonatomic, readonly) SBApplication *nowPlayingApplication;
+ (instancetype)sharedInstance;
@end

#import <SpringBoard/SBReachabilityManager.h>
#import <SpringBoard/SBOrientationLockManager.h>
#import <SpringBoard/SBReachabilityManager.h>

typedef NS_ENUM(int, SBLockSource) {
    SBLockSourceLockButton = 0,
    SBLockSourceKeyboard = 1,
    SBLockSourceSmartCover = 2,
    SBLockSourceNotificationCenter = 3,
    SBLockSourceIdleTimer = 4,
    SBLockSourcePlugin = 5
};

#import <SpringBoard/SBBacklightController.h>
#import <SpringBoard/SBLockScreenManager.h>

typedef NS_ENUM(NSInteger, SBAppSwitcherStyle) {
    SBAppSwitcherStyleDeck,
    SBAppSwitcherStyleMinimal
};

#import <SpringBoard/SBAppSwitcherSettings.h>
#import <SpringBoard/SBRootSettings.h>

// @interface SBRootSettings : _UISettings
// - (SBAppSwitcherSettings *)appSwitcherSettings;
// @end

@interface SBPrototypeController : NSObject
+ (instancetype)sharedInstance;
- (SBRootSettings *)rootSettings;
@end

static SBScreenEdgePanGestureRecognizer *currentRecognizer;

extern SpringBoard *KazeSpringBoard(void);
extern SBWorkspace *KazeWorkspace(void);
extern SBUIController *KazeUIController(void);
extern SBMainSwitcherViewController *KazeSwitcherController(void);
extern SBDeckSwitcherViewController *KazeDeckSwitchController(void);
extern SBMainDisplaySceneLayoutViewController *KazeSceneLayoutController(void);
extern UIView *KazeContainerView(void);
extern BOOL KazeInterfaceIdiomPhone(void);
extern BOOL KazeSystemVersion(NSInteger major, NSInteger minor, NSInteger patch);

extern BOOL KazeDeviceLocked(void);
extern BOOL KazeSwitcherShowing(void);
extern BOOL KazeSwitcherAllowed(void);
extern BOOL KazeHasFrontmostApplication(void);

extern void KazeSwitcherLock(BOOL enabled);
extern void KazeSBAnimate(UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion);
extern void KazeAnimate(NSTimeInterval duration, UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion);
extern void KazeBasicAnimate(UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion);
extern void KazeSpring(NSTimeInterval duration, CGFloat damping, CGFloat velocity, UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion);
extern void KazeTransit(UIView *view, NSTimeInterval duration, UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion);
extern CGFloat KazeRubberbandValue(CGFloat value, CGFloat max);
extern id KazePreferencesValue(NSString *key);

typedef NS_ENUM(NSUInteger, KazeGestureRegion) {
    KazeGestureRegionCenter,
    KazeGestureRegionLeft,
    KazeGestureRegionRight,
};

typedef void (^KazeCallback)(void);
typedef BOOL (^KazeGestureConditionBlock)(KazeGestureRegion region);
typedef void (^KazeGestureHandlerBlock)(UIGestureRecognizerState state, CGPoint position, CGPoint velocity);

extern void KazeRegisterGesture(KazeGestureConditionBlock condition, KazeGestureHandlerBlock handler);
extern void KazePresentInteractiveSwitcherBegin(KazeCallback action, KazeCallback completion);
extern void KazeDismissInteractiveSwitcher(void);
extern void setContentOffset(CGPoint contentOffset);


extern KazeGestureConditionBlock KazeQuickSwitcherCondition;
KazeGestureHandlerBlock KazeQuickSwitcherHandler;
extern KazeGestureConditionBlock KazeLockScreenCondition;
extern KazeGestureHandlerBlock KazeLockScreenHandler;
extern KazeGestureConditionBlock KazeHomeScreenCondition;
extern KazeGestureHandlerBlock KazeHomeScreenHandler;

CHInline static NSString *KazeIdentifier(void) { return @"com.kunderscore.kaze"; }
CHInline static NSBundle *KazeBundle(void) { return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/AvertasPreferences.bundle"]; }
CHInline static UIImage *KazeImage(NSString *name) { return [UIImage imageNamed:name inBundle:KazeBundle()]; }

#define kScreenFrame UIScreen.mainScreen.bounds


#define KazePreferencesKey(name) CHInline static NSString *k ## name ## Key(void) { return @#name; }
KazePreferencesKey(QuickSwitcherEnabled)
KazePreferencesKey(HotCornersEnabled)
KazePreferencesKey(AccessAppSwitcher)
KazePreferencesKey(DisableLockGesture)
KazePreferencesKey(InvertHotCorners)
KazePreferencesKey(CardOpacity)
#undef KazePreferencesKey

#define KazePreferencesKeyPrefix(name) CHInline static NSString *k ## name ## Key(NSString *subkey) { return [@#name"-" stringByAppendingString:subkey ?: @""]; }
KazePreferencesKeyPrefix(DisableInApps)
#undef KazePreferencesKeyPrefix

CHInline static NSUserDefaults *KazePreferences(void) {
    NSUserDefaults *preferences = [[NSUserDefaults alloc]initWithSuiteName:KazeIdentifier()];
    [preferences registerDefaults:@{
        kQuickSwitcherEnabledKey(): @YES,
        kHotCornersEnabledKey(): @YES,
    }];
    return preferences;
}
