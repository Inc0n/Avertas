
#import "KazeQuickSwitcherIconListViewLayout.h"
#import "KazeQuickSwitcherIconListView.h"

@implementation KazeQuickSwitcherIconListViewLayout {
    CGSize _viewMargin;
    CGFloat _iconMargin;
    CGSize _largeIconSize;
    CGSize _smallIconSize;
    CGFloat _iconSpacing;
    CGFloat _iconOffset;
    CGFloat _normalizedZeroBound;
    CGFloat _scrollingArea;
    BOOL _reversedLayout;
    CGPoint _highlightPoint;
    BOOL _hintShowing;
    BOOL _scrollingAreaAccessed;
    NSTimer *_scrollingTimer;
    void (^_scrollingHandler)(void);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _viewMargin = CGSizeMake(23.0, 11.0);
        _iconMargin = 9.0;
        _largeIconSize = [OfClass(SBIconView) defaultIconSize];
        _smallIconSize = CGSizeMake(_largeIconSize.width * 0.45, _largeIconSize.height * 0.45);
        _iconSpacing = _smallIconSize.width + _iconMargin * 2;
        _iconOffset = 20.0;
        _normalizedZeroBound = _viewMargin.width + _iconSpacing * 0.5;
        _scrollingArea = _viewMargin.width + _iconMargin + _largeIconSize.width * 0.5;
    }
    return self;
}

- (void)prepareForPresentation {
    _scrollingAreaAccessed = NO;
}

- (void)setReversedLayout:(BOOL)isReversed {
    _reversedLayout = isReversed;
    self.collectionView.transform = CGAffineTransformMakeScale(_reversedLayout ? -1 : 1, 1);
}

- (void)setHighlightPoint:(CGPoint)highlightPoint {
    CGFloat x = MIN(MAX(highlightPoint.x, _normalizedZeroBound), self.collectionViewContentSize.width - _normalizedZeroBound);
    CGFloat settledX = [self xPositionForIndex:[self indexForXPosition:x]];
    x = settledX + pow(x - settledX, 3) / pow(_iconSpacing * 0.5, 2);
    _highlightPoint = CGPointMake(x, highlightPoint.y);
    [self invalidateLayout];
    [self updateScrollingState];
}

- (void)setHintShowing:(BOOL)hintShowing {
    _hintShowing = hintShowing;
    [self invalidateLayout];
}

- (CGSize)collectionViewContentSize {
    UICollectionView *collectionView = self.collectionView;
    NSInteger count = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:0];
    CGFloat width = _viewMargin.width * 2 + _iconSpacing * count;
    CGFloat height = collectionView.bounds.size.height;
    return CGSizeMake(width, height);
}

- (CGFloat)xPositionForIndex:(NSUInteger)index {
    return _viewMargin.width + _iconSpacing * ((CGFloat)index + 0.5);
}

- (NSUInteger)indexForXPosition:(CGFloat)x {
    return floor((x - _viewMargin.width) / _iconSpacing);
}

- (CGFloat)xOffsetWithLeftmostIndex:(NSUInteger)index {
    return _iconSpacing * index;
}

- (CGFloat)xOffsetWithRightmostIndex:(NSUInteger)index {
    return _iconSpacing * (index + 1) + _viewMargin.width * 2 - self.collectionView.bounds.size.width;
}

- (CGPoint)contentOffsetForStartingIndex:(NSUInteger)index {
    return CGPointMake([self xOffsetWithLeftmostIndex:index], 0);
}

- (NSUInteger)highlightIndex {
    return [self indexForXPosition:_highlightPoint.x];
}

- (CGFloat)normalizedHighlightOffset {
    return (_highlightPoint.x - _normalizedZeroBound) / (self.collectionViewContentSize.width - _normalizedZeroBound * 2);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.item;
    CGFloat modelX = [self xPositionForIndex:index];
    CGFloat distance = modelX - _highlightPoint.x;
    CGSize size = _smallIconSize;
    if (ABS(distance) < _iconSpacing) {
        CGFloat upScaleStep = (cos(ABS(distance) / _iconSpacing * M_PI) + 1.0) * 0.5;
        size.width += (_largeIconSize.width - _smallIconSize.width) * upScaleStep;
        size.height += (_largeIconSize.height - _smallIconSize.height) * upScaleStep;
    }
    CGFloat offsetX = 0;
    if (distance < -_iconSpacing) {
        offsetX = -_iconOffset;
    } else if (distance > _iconSpacing) {
        offsetX = _iconOffset;
    } else {
        offsetX = _iconOffset * sin(distance / _iconSpacing * M_PI_2);
    }
    CGFloat x = modelX + offsetX;
    static CGFloat const constant = 2;
    CGFloat lowestY = self.collectionView.bounds.size.height - _viewMargin.height - _iconMargin - _smallIconSize.height * 0.5;
    CGFloat highestY = _highlightPoint.y - _largeIconSize.height - _iconOffset;
    CGFloat y = highestY + (lowestY - highestY) * (1.0 - 1.0 / (ABS(distance) * constant / (lowestY - highestY) + 1.0));
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.center = CGPointMake(x, y);
    attributes.size = size;
    attributes.transform = CGAffineTransformMakeScale(_reversedLayout ? -1 : 1, 1);
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = _largeIconSize.width + _iconMargin * 2;
    CGFloat height = self.collectionView.bounds.size.height;
    CGFloat x = _highlightPoint.x - width / 2;
    CGFloat y = _highlightPoint.y - _largeIconSize.height - _iconOffset - _largeIconSize.height * 0.5 - _iconMargin - _viewMargin.height;
    KazeQuickSwitcherHighlightViewLayoutAttributes *attributes = [KazeQuickSwitcherHighlightViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    attributes.frame = CGRectMake(x, y, width, height);
    attributes.zIndex = -1;
    attributes.transform = CGAffineTransformMakeScale(_reversedLayout ? -1 : 1, 1);
    attributes.titleText = [[(KazeQuickSwitcherIconListView *)self.collectionView.dataSource iconAtIndex:self.highlightIndex] displayNameForLocation:SBIconLocationHomeScreen];
    attributes.hintShowing = _hintShowing;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    return [self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    return [self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
    UICollectionView *collectionView = self.collectionView;
    NSInteger count = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:0];
    NSInteger minIndex = MAX([self indexForXPosition:CGRectGetMinX(rect)], 0);
    NSInteger maxIndex = MIN([self indexForXPosition:CGRectGetMaxX(rect)], count - 1);
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSInteger index = minIndex; index <= maxIndex; index++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
    }
    return indexPaths;
}

- (NSIndexPath *)indexPathForHighlightViewInRect:(CGRect)rect {
    return [NSIndexPath indexPathForItem:0 inSection:0];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    [[self indexPathsForItemsInRect:rect]enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger index, BOOL *stop) {
        [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }];
    [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:NSStringFromClass(KazeQuickSwitcherHighlightView.class) atIndexPath:[self indexPathForHighlightViewInRect:rect]]];
    return layoutAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (void)updateScrollingState {
    CGRect bounds = self.collectionView.bounds;
    CGFloat leftBoundDistance = _highlightPoint.x - CGRectGetMinX(bounds);
    CGFloat rightBoundDistance = CGRectGetMaxX(bounds) - _highlightPoint.x;
    if (leftBoundDistance < _scrollingArea) {
        if (_scrollingAreaAccessed) {
            [self startScrolling:-1];
        }
    } else if (rightBoundDistance < _scrollingArea) {
        if (_scrollingAreaAccessed) {
            [self startScrolling:+1];
        }
    } else {
        [self stopScrolling];
        _scrollingAreaAccessed = YES;
    }
}

- (void)startScrolling:(NSInteger)direction {
    if (_scrollingTimer.valid && [_scrollingTimer.userInfo integerValue] == direction) {
        return;
    }
    [self stopScrolling];
    _scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(scrollingTimerFired) userInfo:@(direction) repeats:YES];
    _scrollingTimer.tolerance = 0.1;
}

- (void)stopScrolling {
    if (_scrollingTimer == nil) {
        return;
    }
    [_scrollingTimer invalidate];
    _scrollingTimer = nil;
}

- (void)scrollingTimerFired {
    UICollectionView *collectionView = self.collectionView;
    NSInteger direction = [_scrollingTimer.userInfo integerValue];
    CGRect bounds = collectionView.bounds;
    NSInteger count = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:0];
    CGFloat oldXOffset = collectionView.contentOffset.x;
    CGFloat newXOffset = oldXOffset;
    if (direction == -1) {
        NSInteger nextHighlightIndex = MIN(MAX([self indexForXPosition:CGRectGetMinX(bounds) - 1], 0), count - 1);
        newXOffset = [self xOffsetWithLeftmostIndex:nextHighlightIndex];
    } else if (direction == 1) {
        NSInteger nextHighlightIndex = MIN(MAX([self indexForXPosition:CGRectGetMaxX(bounds) + 1], 0), count - 1);
        newXOffset = [self xOffsetWithRightmostIndex:nextHighlightIndex];
    }
    if (oldXOffset == newXOffset) {
        [self stopScrolling];
        return;
    }
    KazeAnimate(0.25, ^{
        [self setHighlightPoint:CGPointMake(_highlightPoint.x + (newXOffset - oldXOffset), _highlightPoint.y)];
        collectionView.contentOffset = CGPointMake(newXOffset, 0);
        if (_scrollingHandler) {
            _scrollingHandler();
        }
    }, NULL);
}

- (void)setScrollingHandler:(void (^)(void))handler {
    _scrollingHandler = handler;
}

@end
