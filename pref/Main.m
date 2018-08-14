#import "Headers.h"
#import <Social/Social.h>
#import "PSHeaderCell.h"

@interface ASPreferencesController : QSPSListController
@end

// static PSSpecifier *header;
@implementation ASPreferencesController

+ (void)initialize {
    [[NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/AppList.bundle"]load];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *heartButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [heartButton setImage:KazeImage(@"Heart") forState:UIControlStateNormal];
    [heartButton sizeToFit];
    [heartButton addTarget:self action:@selector(heartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:heartButton];

    [self loadSpecifiersFromPlistName:@"Root" target:self];
}

- (NSArray *)newAllSpecifiers {
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), KazeBundle());
    PSSpecifier *header = [self newGroupSpecifierForIdentifier:nil name:nil footer:nil updateBlock:NULL];
    [header setProperty:@"PSHeaderCell" forKey:@"headerCellClass"];

    return @[
        header,
        [self newGroupSpecifierForIdentifier:nil name:@"BASIC" footer:KazeString(@"INSTRUCTION") updateBlock:NULL],
        [self newSpecifierForIdentifier:kQuickSwitcherEnabledKey() name:KazeString(@"QUICKSWITCHER") image:KazeImage(@"QuickSwitcher") cell:PSSwitchCell setupBlock:NULL updateBlock:NULL isShowingBlock:NULL isEnabledBlock:NULL],
        [self newSpecifierForIdentifier:kHotCornersEnabledKey() name:KazeString(@"HOTCORNERS") image:KazeImage(@"HotCorners") cell:PSSwitchCell setupBlock:NULL updateBlock:NULL isShowingBlock:NULL isEnabledBlock:NULL],
        
        [self newGroupSpecifierForIdentifier:nil name:@"Sliders" footer:KazeString(@"CARD_OPACITY") updateBlock:NULL],
        [self newSpecifierForIdentifier:kCardOpacityKey() name:KazeString(@"CARD_OPACITY") image:nil cell:PSSliderCell setupBlock:NULL updateBlock:NULL isShowingBlock:NULL isEnabledBlock:NULL],

        [self newGroupSpecifierForIdentifier:nil name:@"MORE" footer:@"" updateBlock:NULL],
        [self newSpecifierForIdentifier:kDisableLockGestureKey() name:KazeString(@"DISABLE_LOCK_GESTURE") image:nil cell:PSSwitchCell setupBlock:NULL updateBlock:NULL isShowingBlock:NULL isEnabledBlock:^BOOL(PSSpecifier *specifier) {
            return [self.preferences boolForKey:kHotCornersEnabledKey()];
        }],
        [self newSpecifierForIdentifier:kInvertHotCornersKey() name:KazeString(@"INVERT_HOT_CORNERS") image:nil cell:PSSwitchCell setupBlock:NULL updateBlock:NULL isShowingBlock:NULL isEnabledBlock:^BOOL(PSSpecifier *specifier) {
            return [self.preferences boolForKey:kQuickSwitcherEnabledKey()] || [self.preferences boolForKey:kHotCornersEnabledKey()];
        }],
        [self newSpecifierForIdentifier:nil name:KazeString(@"DISABLE_IN_APPS") image:nil cell:PSLinkCell setupBlock:^(PSSpecifier *specifier) {
            specifier->detailControllerClass = NSClassFromString(@"ALApplicationPreferenceViewController");
            [specifier setProperty:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", KazeIdentifier()] forKey:@"ALSettingsPath"];
            [specifier setProperty:kDisableInAppsKey(nil) forKey:@"ALSettingsKeyPrefix"];
        } updateBlock:NULL isShowingBlock:NULL isEnabledBlock:^BOOL(PSSpecifier *specifier) {
            return [self.preferences boolForKey:kQuickSwitcherEnabledKey()] || [self.preferences boolForKey:kHotCornersEnabledKey()];
        }],

        [self newGroupSpecifierForIdentifier:nil name:@"LICENSE & COPYRIGHT" footer:KazeString(@"CREDIT") updateBlock:NULL],
        [self newSpecifierForIdentifier:nil name:KazeString(@"LEGAL") image:nil cell:PSLinkCell setupBlock:^(PSSpecifier *specifier) {
            specifier->detailControllerClass = NSClassFromString(@"PSLegalController");
            // [specifier setProperty:@"Legal" forKey:@"label"]; 
            // [specifier setProperty:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", KazeIdentifier()] forKey:@"ALSettingsPath"]; 
        } updateBlock:NULL isShowingBlock:NULL isEnabledBlock:NULL],
    ];
}

- (void)heartButtonAction:(UIButton *)sender {
    // SLComposeViewController *composeSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    // [composeSheet setInitialText:KazeString(@"SHARE_TEXT")];
    // [(UIViewController *)self presentViewController:composeSheet animated:YES completion:nil];
}

@end
