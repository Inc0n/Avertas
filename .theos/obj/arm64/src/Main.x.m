#line 1 "src/Main.x"
#import "Headers.h"
#import <SpringBoard/SBFluidSwitcherPanGestureRecognizer.h>




static SBGrabberTongue *grabber;
static NSMutableArray<NSArray *> *gestureRegistry;
static KazeGestureHandlerBlock currentHandler;

void KazeRegisterGesture(KazeGestureConditionBlock condition, KazeGestureHandlerBlock handler) {
    [gestureRegistry addObject:@[condition, handler]];
}


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

@class SBDeckSwitcherPersonality; @class SBUIController; @class SBGrabberTongue; 
static SBUIController* (*_logos_orig$_ungrouped$SBUIController$init)(_LOGOS_SELF_TYPE_INIT SBUIController*, SEL) _LOGOS_RETURN_RETAINED; static SBUIController* _logos_method$_ungrouped$SBUIController$init(_LOGOS_SELF_TYPE_INIT SBUIController*, SEL) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$SBDeckSwitcherPersonality$didBeginGesture$)(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SBDeckSwitcherPersonality$didBeginGesture$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST, SEL, id); static SBGrabberTongue* (*_logos_orig$_ungrouped$SBGrabberTongue$initWithDelegate$edge$type$)(_LOGOS_SELF_TYPE_INIT SBGrabberTongue*, SEL, id, unsigned long long, unsigned long long) _LOGOS_RETURN_RETAINED; static SBGrabberTongue* _logos_method$_ungrouped$SBGrabberTongue$initWithDelegate$edge$type$(_LOGOS_SELF_TYPE_INIT SBGrabberTongue*, SEL, id, unsigned long long, unsigned long long) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$SBGrabberTongue$_handlePullGesture$)(_LOGOS_SELF_TYPE_NORMAL SBGrabberTongue* _LOGOS_SELF_CONST, SEL, SBScreenEdgePanGestureRecognizer *); static void _logos_method$_ungrouped$SBGrabberTongue$_handlePullGesture$(_LOGOS_SELF_TYPE_NORMAL SBGrabberTongue* _LOGOS_SELF_CONST, SEL, SBScreenEdgePanGestureRecognizer *); 

#line 15 "src/Main.x"

static SBUIController* _logos_method$_ungrouped$SBUIController$init(_LOGOS_SELF_TYPE_INIT SBUIController* __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
    self = _logos_orig$_ungrouped$SBUIController$init(self, _cmd);
    KazeRegisterGesture(KazeQuickSwitcherCondition, KazeQuickSwitcherHandler);
    KazeRegisterGesture(KazeLockScreenCondition, KazeLockScreenHandler);
    KazeRegisterGesture(KazeHomeScreenCondition, KazeHomeScreenHandler);
    return self;
}


static SBGrabberTongue *thisgrabber;


static void _logos_method$_ungrouped$SBDeckSwitcherPersonality$didBeginGesture$(_LOGOS_SELF_TYPE_NORMAL SBDeckSwitcherPersonality* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), arg1);
}



static SBGrabberTongue* _logos_method$_ungrouped$SBGrabberTongue$initWithDelegate$edge$type$(_LOGOS_SELF_TYPE_INIT SBGrabberTongue* __unused self, SEL __unused _cmd, id arg1, unsigned long long arg2, unsigned long long arg3) _LOGOS_RETURN_RETAINED {
    if (IsClass(arg1, SBControlCenterController)) {
        
        
    }
    return _logos_orig$_ungrouped$SBGrabberTongue$initWithDelegate$edge$type$(self, _cmd, arg1, arg2, arg3);
}
static void _logos_method$_ungrouped$SBGrabberTongue$_handlePullGesture$(_LOGOS_SELF_TYPE_NORMAL SBGrabberTongue* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, SBScreenEdgePanGestureRecognizer * recognizer) {
    if (grabber == nil) {
        id obj = [self valueForKey:@"_delegate"];
    
        if (IsClass(obj, SBControlCenterController)) {
            grabber = self;      
            currentRecognizer = recognizer;     
        }
    }
    if (self != grabber) {
        _logos_orig$_ungrouped$SBGrabberTongue$_handlePullGesture$(self, _cmd, recognizer); 
        return;
    }

    UIGestureRecognizerState state = recognizer.state;
    UIInterfaceOrientation orientation = KazeSpringBoard().activeInterfaceOrientation;
    UIWindow *window = recognizer.view.window;
    CGSize size = window.bounds.size;
    CGPoint position = [recognizer locationInView:window];
    CGPoint velocity = [recognizer velocityInView:window];
    switch (orientation) {
        case 1:
            break;
        case 2:
            position = CGPointMake(size.width - position.x, size.height - position.y);
            velocity = CGPointMake(-velocity.x, -velocity.y);
            break;
        case 3:
            size = CGSizeMake(size.height, size.width);
            position = CGPointMake(position.y, size.height - position.x);
            velocity = CGPointMake(velocity.y, -velocity.x);
            break;
        case 4:
            size = CGSizeMake(size.height, size.width);
            position = CGPointMake(size.width - position.y, position.x);
            velocity = CGPointMake(-velocity.y, velocity.x);
            break;
        default:
            break;
    }
    if (state == UIGestureRecognizerStateBegan) {

        currentHandler = nil;
        if (![KazePreferencesValue(kDisableInAppsKey(KazeSpringBoard()._accessibilityFrontMostApplication.bundleIdentifier)) boolValue]) {
            KazeGestureRegion region = ({
                CGFloat x = position.x;
                CGFloat width = size.width;
                KazeGestureRegion region = KazeGestureRegionCenter;
                if (x < width * 0.25) {
                    region = KazeGestureRegionLeft;
                } else if (x > width * 0.75) {
                    region = KazeGestureRegionRight;
                } else {
                    region = KazeGestureRegionCenter;
                }
                region;
            });
            
            [gestureRegistry enumerateObjectsUsingBlock:^(NSArray *gestureArray, NSUInteger index, BOOL *stop) {
                KazeGestureConditionBlock condition = gestureArray[0];
                KazeGestureHandlerBlock handler = gestureArray[1];
                if (condition(region)) {
                    currentHandler = handler;
                    *stop = YES;
                }
            }];
        }
    }
    if (currentHandler) {
        NSString *reason = KazeIdentifier();
        
        switch (state) {
            case UIGestureRecognizerStateBegan:
                [SharedInstance(SBOrientationLockManager) setLockOverrideEnabled:YES forReason:reason];
                [SharedInstance(SBBacklightController) preventIdleSleep];
                currentHandler(state, position, velocity);
                break;
            case UIGestureRecognizerStateChanged:
                currentHandler(state, position, velocity);
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
                currentHandler(state, position, velocity);
                [SharedInstance(SBOrientationLockManager) setLockOverrideEnabled:NO forReason:reason];
                [SharedInstance(SBBacklightController) allowIdleSleep];
            default:
                currentHandler = nil;
                break;
        }
    } else {
        _logos_orig$_ungrouped$SBGrabberTongue$_handlePullGesture$(self, _cmd, recognizer);
    }
}



static __attribute__((constructor)) void _logosLocalCtor_5998d7e0(int __unused argc, char __unused **argv, char __unused **envp) {
    NSLog(@"Gestureregistry initializedd");
    gestureRegistry = [NSMutableArray array];
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBUIController = objc_getClass("SBUIController"); MSHookMessageEx(_logos_class$_ungrouped$SBUIController, @selector(init), (IMP)&_logos_method$_ungrouped$SBUIController$init, (IMP*)&_logos_orig$_ungrouped$SBUIController$init);Class _logos_class$_ungrouped$SBDeckSwitcherPersonality = objc_getClass("SBDeckSwitcherPersonality"); MSHookMessageEx(_logos_class$_ungrouped$SBDeckSwitcherPersonality, @selector(didBeginGesture:), (IMP)&_logos_method$_ungrouped$SBDeckSwitcherPersonality$didBeginGesture$, (IMP*)&_logos_orig$_ungrouped$SBDeckSwitcherPersonality$didBeginGesture$);Class _logos_class$_ungrouped$SBGrabberTongue = objc_getClass("SBGrabberTongue"); MSHookMessageEx(_logos_class$_ungrouped$SBGrabberTongue, @selector(initWithDelegate:edge:type:), (IMP)&_logos_method$_ungrouped$SBGrabberTongue$initWithDelegate$edge$type$, (IMP*)&_logos_orig$_ungrouped$SBGrabberTongue$initWithDelegate$edge$type$);MSHookMessageEx(_logos_class$_ungrouped$SBGrabberTongue, @selector(_handlePullGesture:), (IMP)&_logos_method$_ungrouped$SBGrabberTongue$_handlePullGesture$, (IMP*)&_logos_orig$_ungrouped$SBGrabberTongue$_handlePullGesture$);} }
#line 142 "src/Main.x"
