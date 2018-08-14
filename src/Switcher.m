#import "Headers.h"

void KazePresentInteractiveSwitcherBegin(KazeCallback animtedAction, KazeCallback completion) {
    [KazeSwitcherController() activateSwitcherNoninteractivelyWithSource:0];
}

void KazeDismissInteractiveSwitcher(void) {
    [KazeSwitcherController() dismissSwitcherNoninteractively];
}

void setContentOffset(CGPoint offset) {
    KazeBasicAnimate(^{
        [KazeDeckSwitchController().scrollView setContentOffset:offset animated:NO];
    }, nil);
}