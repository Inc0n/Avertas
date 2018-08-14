#import "Headers.h"
#import <SpringBoard/SBFluidSwitcherPanGestureRecognizer.h>

/*
    kaze stuff
*/
static SBGrabberTongue *grabber;
static NSMutableArray<NSArray *> *gestureRegistry;
static KazeGestureHandlerBlock currentHandler;

void KazeRegisterGesture(KazeGestureConditionBlock condition, KazeGestureHandlerBlock handler) {
    [gestureRegistry addObject:@[condition, handler]];
}

%hook SBUIController
-(id)init {
    self = %orig;
    KazeRegisterGesture(KazeQuickSwitcherCondition, KazeQuickSwitcherHandler);
    KazeRegisterGesture(KazeLockScreenCondition, KazeLockScreenHandler);
    KazeRegisterGesture(KazeHomeScreenCondition, KazeHomeScreenHandler);
    return self;
}
%end

static SBGrabberTongue *thisgrabber;

%hook SBDeckSwitcherPersonality
-(void)didBeginGesture:(id)arg1 {
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), arg1);
}
%end

%hook SBGrabberTongue
-(id)initWithDelegate:(id)arg1 edge:(unsigned long long)arg2 type:(unsigned long long)arg3 {
    if (IsClass(arg1, SBControlCenterController)) {
        // gesturedelegate = [KazeBottomGesture new];
        // return %orig(gesturedelegate, arg2, arg3);
    }
    return %orig;
}
- (void)_handlePullGesture:(SBScreenEdgePanGestureRecognizer *)recognizer {
    if (grabber == nil) {
        id obj = [self valueForKey:@"_delegate"];
    
        if (IsClass(obj, SBControlCenterController)) {
            grabber = self;      
            currentRecognizer = recognizer;     
        }
    }
    if (self != grabber) {
        %orig; 
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
        %orig;
    }
}
%end


%ctor {
    NSLog(@"Gestureregistry initializedd");
    gestureRegistry = [NSMutableArray array];
}