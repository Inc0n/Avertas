#import "KazeQuickSwitcherHighlightViewLayoutAttributes.h"

@implementation KazeQuickSwitcherHighlightViewLayoutAttributes

- (id)copyWithZone:(NSZone *)zone {
    KazeQuickSwitcherHighlightViewLayoutAttributes *copy = [super copyWithZone:zone];
    copy.titleText = self.titleText;
    copy.hintShowing = self.hintShowing;
    return copy;
}

- (BOOL)isEqual:(id)object {
    return [super isEqual:object] && [object isKindOfClass:self.class]
    && ((self.titleText == nil && [object titleText] == nil) || [self.titleText isEqualToString:[object titleText]])
    && self.hintShowing == [object hintShowing];
}

@end