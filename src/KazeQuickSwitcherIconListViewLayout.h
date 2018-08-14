
#import "Headers.h"

@interface KazeQuickSwitcherIconListViewLayout : UICollectionViewLayout
- (void)prepareForPresentation;
- (void)setReversedLayout:(BOOL)isReversed;
- (void)setHighlightPoint:(CGPoint)highlightPoint;
- (void)setHintShowing:(BOOL)hintShowing;
- (CGFloat)xPositionForIndex:(NSUInteger)index;
- (NSUInteger)indexForXPosition:(CGFloat)x;
- (CGPoint)contentOffsetForStartingIndex:(NSUInteger)index;
- (NSUInteger)highlightIndex;
- (CGFloat)normalizedHighlightOffset;
- (void)setScrollingHandler:(void (^)(void))handler;
- (void)startScrolling:(NSInteger)direction;
- (void)stopScrolling;
@end
