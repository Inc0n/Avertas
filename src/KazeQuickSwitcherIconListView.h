#import "Headers.h"

@interface KazeQuickSwitcherIconListView : UIView
- (void)loadApplications:(NSArray *)applications startingIndex:(NSUInteger)startingIndex isReversed:(BOOL)isReversed;
- (void)setHighlightPoint:(CGPoint)highlightPoint;
- (void)setHintShowing:(BOOL)hintShowing;
- (NSUInteger)highlightIndex;
- (CGFloat)normalizedHighlightOffset;
- (void)setScrollingHandler:(void (^)(void))handler;
- (void)stopScrolling;

- (void)show;
- (void)hide:(BOOL)animate;
@end

@interface KazeQuickSwitcherIconListView () <UICollectionViewDataSource, UICollectionViewDelegate>
- (SBLeafIcon *)iconAtIndex:(NSUInteger)index;
@end

