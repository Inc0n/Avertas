#import "KazeQuickSwitcherIconListView.h"


@implementation KazeQuickSwitcherIconListView {
    NSArray *_applications;
    UICollectionView *_collectionView;
    KazeQuickSwitcherIconListViewLayout *_collectionViewLayout;
    KazeQuickSwitcherHighlightView *highlightView;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bounds = {CGPointZero, frame.size};
        self.userInteractionEnabled = YES;
        _collectionViewLayout = [[KazeQuickSwitcherIconListViewLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:bounds collectionViewLayout:_collectionViewLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = nil;
        _collectionView.clipsToBounds = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:KazeQuickSwitcherIconView.class forCellWithReuseIdentifier:NSStringFromClass(KazeQuickSwitcherIconView.class)];
        [_collectionView registerClass:KazeQuickSwitcherHighlightView.class forSupplementaryViewOfKind:NSStringFromClass(KazeQuickSwitcherHighlightView.class) withReuseIdentifier:NSStringFromClass(KazeQuickSwitcherHighlightView.class)];
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)loadApplications {

}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *subview = [super hitTest:point withEvent:event];
    // if (subview == _collectionView) {
    //     // [self hide:YES];        
    //     return nil;
    // }
    // NSLog(@"%@ %@", NSStringFromSelector(_cmd), subview);
    return subview;
}

- (void)show {
    CGSize size = KazeContainerView().bounds.size;
    self.frame = CGRectMake(0, 0, size.width, size.height);
}

- (void)hide:(BOOL)animate { 
    void (^hideByFrame)() = ^() {
        CGSize size = KazeContainerView().bounds.size;
        self.frame = CGRectMake(0, size.height, size.width, size.height);
    };
    if (animate) {
        KazeBasicAnimate(^{
            hideByFrame();
        }, nil);
    }
    else {
        hideByFrame();
    }
}

- (void)layoutSubviews {
    _collectionView.frame = self.bounds;
}

- (void)loadApplications:(NSArray *)applications startingIndex:(NSUInteger)startingIndex isReversed:(BOOL)isReversed {
    _applications = applications;
    [_collectionView reloadData];
    [self setContentOffsetToStartingIndex:startingIndex isReversed:isReversed];
    [_collectionViewLayout prepareForPresentation];
}

- (SBLeafIcon *)iconAtIndex:(NSUInteger)index {
    return [SharedInstance(SBIconController).model leafIconForIdentifier:_applications[index]];
}

- (void)setHighlightPoint:(CGPoint)highlightPoint {
    _collectionViewLayout.highlightPoint = [self convertPoint:highlightPoint toView:_collectionView];
}

- (void)setHintShowing:(BOOL)hintShowing {
    _collectionViewLayout.hintShowing = hintShowing;
}

- (void)setContentOffsetToStartingIndex:(NSUInteger)index isReversed:(BOOL)isReversed {
    [_collectionViewLayout setReversedLayout:isReversed];
    _collectionView.contentOffset = [_collectionViewLayout contentOffsetForStartingIndex:index];
}

- (NSUInteger)highlightIndex {
    return _collectionViewLayout.highlightIndex;
}

- (CGFloat)normalizedHighlightOffset {
    return _collectionViewLayout.normalizedHighlightOffset;
}

- (void)setScrollingHandler:(void (^)(void))handler {
    [_collectionViewLayout setScrollingHandler:handler];
}

- (void)stopScrolling {
    [_collectionViewLayout stopScrolling];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _applications.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KazeQuickSwitcherIconView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(KazeQuickSwitcherIconView.class) forIndexPath:indexPath];
    [cell loadIcon:[self iconAtIndex:indexPath.item]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    highlightView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(KazeQuickSwitcherHighlightView.class) forIndexPath:indexPath];
    return highlightView;
}

@end
