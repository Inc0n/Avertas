
#import "KazeQuickSwitcherHighlightView.h"
#import "KazeQuickSwitcherHighlightViewLayoutAttributes.h"


@interface KazePanGestureRecognizer : UIPanGestureRecognizer 
// @property (nonatomic, readwrite) UIGestureRecognizerState state;
@end

@implementation KazePanGestureRecognizer
@end


@implementation KazeQuickSwitcherHighlightView {
    _UIBackdropView *_backgroundView;
    UILabel *_titleView;
    UILabel *_hintLabel;
    KazePanGestureRecognizer *panrecognizer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 7;
        self.layer.masksToBounds = YES;
        self.layer.allowsGroupBlending = NO;
        _backgroundView = [[_UIBackdropView alloc]initWithStyle:0x80c];
        _backgroundView.groupName = KazeIdentifier();
        _backgroundView.appliesOutputSettingsAnimationDuration = 1;
        _titleView = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleView.font = [UIFont systemFontOfSize:12];
        _titleView.textColor = [UIColor whiteColor];
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.adjustsFontSizeToFitWidth = YES;
        _titleView.minimumScaleFactor = 0.6;
        _titleView.layer.shadowOpacity = 0.6;
        _titleView.layer.shadowRadius = 3.0;
        _titleView.layer.shadowOffset = CGSizeZero;
        _titleView.layer.shadowColor = [UIColor blackColor].CGColor;
        _hintLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _hintLabel.text = @"←→";
        _hintLabel.font = [UIFont systemFontOfSize:14];
        _hintLabel.textColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.numberOfLines = 1;
        _hintLabel.layer.compositingFilter = @"plusD";
        _hintLabel.alpha = 0;
        [self addSubview:_backgroundView];
        [self addSubview:_titleView];
        [self addSubview:_hintLabel];

        panrecognizer = [KazePanGestureRecognizer.alloc initWithTarget:self action:@selector(handlePanGesture:)];
        panrecognizer.delegate = self;
        [self addGestureRecognizer:panrecognizer];
    }
    return self;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    // NSLog(@"%@ %@", NSStringFromSelector(_cmd), recognizer);
    UIGestureRecognizerState state = recognizer.state;
    UIWindow *window = recognizer.view.window;
    CGPoint position = [recognizer locationInView:window];
    CGPoint velocity = [recognizer velocityInView:window];
    if (state == UIGestureRecognizerStateBegan) return ;
    KazeQuickSwitcherHandler(state, position, velocity);
}

- (void)layoutSubviews {
    CGRect frame = self.bounds;
    _backgroundView.frame = frame;
    frame.size.height = 22;
    frame.size.width -= 2;
    frame.origin.x += 1;
    _titleView.frame = frame;
    [_hintLabel sizeToFit];
    _hintLabel.center = CGPointMake(frame.size.width / 2.0, 140);
}

- (void)applyLayoutAttributes:(KazeQuickSwitcherHighlightViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    [self setTitleText:layoutAttributes.titleText];
    [self setHintShowing:layoutAttributes.hintShowing];
}

- (void)setTitleText:(NSString *)titleText {
    if (![_titleView.text isEqualToString:titleText]) {
        KazeTransit(_titleView, 0.25, ^{
            _titleView.text = titleText;
        }, NULL);
    }
}

- (void)setHintShowing:(BOOL)showing {
    CGFloat alpha = showing ? 1.0 : 0.0;
    if (_hintLabel.alpha != alpha) {
        KazeAnimate(1.0, ^{
            _hintLabel.alpha = alpha;
        }, NULL);
    }
}

@end
