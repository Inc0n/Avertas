//Mostly the same as FLASHHeaderCell.m
//Thanks agian, David
#import "Headers.h"

@implementation PSHeaderCell

// UITableViewCEllStyle
- (instancetype)initWithStyle:(long long)style reuseIdentifier:(id)reuseIdentifier specifier:(id)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	if (self) {
		self.backgroundColor = [UIColor clearColor];

		titleLabel = [UILabel new];
		titleLabel.text = @"Avertas";
		titleLabel.font = [UIFont systemFontOfSize:36];
		[titleLabel sizeToFit];
		[self addSubview:titleLabel];

		iconView = [UIImageView new];
		iconView.image = [UIImage imageNamed:@"Avertas" inBundle:KazeBundle() compatibleWithTraitCollection:nil];
		[self addSubview:iconView];
	}
	return self;
}

- (instancetype)initWithSpecifier:(id)specifier {
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	return [self initWithStyle:style reuseIdentifier:@"PHPrefsHeaderCell" specifier:specifier];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width inTableView:(id)tableView {
	return 100;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGFloat iconSize = CGRectGetHeight(self.bounds) / 2;
	CGFloat labelWidth = CGRectGetWidth(titleLabel.frame);
	CGFloat padding = 8;

	CGFloat centerX = CGRectGetWidth(self.bounds) * 0.5;
	CGFloat startx = (CGRectGetWidth(self.bounds) - labelWidth - iconSize) / 2 - padding;

	CGFloat starty = 0.175 * iconSize * 2;
    NSLog(@"%@ %f", NSStringFromSelector(_cmd), CGRectGetWidth(titleLabel.frame));

	iconView.frame = CGRectMake(startx, CGRectGetMidY(self.bounds) - iconSize/2 + starty, iconSize, iconSize);
	titleLabel.frame = CGRectMake(startx + iconSize + padding * 2, starty, CGRectGetWidth(self.bounds) - (centerX + padding), CGRectGetHeight(self.bounds));
}

// Fix for iPad alignment issue.  
- (void)setFrame:(CGRect)frame {
	frame.origin.x = 0;
	[super setFrame:frame];
}

@end