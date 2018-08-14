

#import "Headers.h"

@interface PSLegalTextCell : PSTableCell {
	UIImageView *iconView;
	UILabel *titleLabel;
}
@end

@implementation PSLegalTextCell

// UITableViewCEllStyle
- (instancetype)initWithStyle:(long long)style reuseIdentifier:(id)reuseIdentifier specifier:(id)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	if (self) {

		// NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		// style.alignment = NSTextAlignmentJustified;
		// style.firstLineHeadIndent = 20.0f;
		// style.headIndent = 20.0f;
		// style.tailIndent = -20.0f;

		// NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:KazeString(@"LICENSE") attributes:@{ NSParagraphStyleAttributeName : style}];  

		UITextView *textView = [UITextView.alloc initWithFrame:kScreenFrame];
		textView.textContainerInset = UIEdgeInsetsMake(20, 20, 0, 20);
		textView.text = KazeString(@"LICENSE");
		textView.font = [UIFont systemFontOfSize:13];
		[self addSubview:textView];
		// titleLabel = [UILabel.alloc initWithFrame:kScreenFrame];
		// titleLabel.attributedText = attrText;
		// titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
		// titleLabel.numberOfLines = 0;
		// [titleLabel sizeToFit];
		// titleLabel.center = self.center;
		// [self addSubview:titleLabel];
	}
	return self;
}
- (instancetype)initWithSpecifier:(id)specifier {
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	return [self initWithStyle:style reuseIdentifier:@"PHPrefsHeaderCell" specifier:specifier];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width inTableView:(id)tableView {
	return kScreenHeight;
}
@end

@implementation PSLegalController

- (id)specifiers {
	if(_specifiers == nil) {
		PSSpecifier *legalText = [self newGroupSpecifierForIdentifier:nil name:nil footer:nil updateBlock:NULL];
		[legalText setProperty:@"PSLegalTextCell" forKey:@"headerCellClass"];

		_specifiers = @[legalText];
		
	}
	return _specifiers;
}
@end