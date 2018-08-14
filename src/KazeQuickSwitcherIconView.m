#include "Headers.h"
#import "KazeQuickSwitcherIconView.h"

@implementation KazeQuickSwitcherIconView {
    SBIconView *_iconView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _iconView = [Alloc(SBIconView) initWithContentType:0];
        [self.contentView addSubview:_iconView];
    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGPoint scale = CGPointMake(bounds.size.width / _iconView.bounds.size.width, bounds.size.height / _iconView.bounds.size.height);
    _iconView.center = center;
    _iconView.transform = CGAffineTransformMakeScale(scale.x, scale.y);
}

- (void)loadIcon:(SBIcon *)icon {
    if (![_iconView.icon.applicationBundleID isEqualToString:icon.applicationBundleID]) {
        _iconView.icon = icon;
        _iconView.iconLabelAlpha = 0;
    }
}

@end