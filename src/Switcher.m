#import "Headers.h"

static BOOL switcherContinuityLock;
static BOOL interceptAnimation;

void setContentOffset(CGPoint offset) {
    KazeAnimate(0.2f, ^{
        [KazeDeckSwitchController().scrollView setContentOffset:offset animated:NO];
    }, nil);
}

void KazePresentInteractiveSwitcherBegin() {
    switcherContinuityLock = YES;
    // interceptAnimation = YES;
    [KazeSwitcherController() activateSwitcherNoninteractivelyWithSource:1];
    interceptAnimation = NO;
}

void KazePresentInteractiveSwitcherEnd(void) {
    switcherContinuityLock = NO;
}

void KazeDismissInteractiveSwitcher(void) {
    [KazeSwitcherController() dismissSwitcherNoninteractively];
}