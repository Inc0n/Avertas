
#import "Headers.h"
#import <SpringBoard/VolumeControl.h>


#pragma mark external methods 

extern void BKSDisplayBrightnessSet(float value);
extern float BKSDisplayBrightnessGetCurrent();


#pragma mark interface declaration 

@interface DualSliderContainerView : UIView
@property (copy) UISlider *slider;
@end

typedef enum : int {
	ModeBrightness,
	ModeVolumn
} SlideMode;

@interface MultiCenter : UIView <UICollectionViewDelegate, UICollectionViewDataSource> {
	VolumeControl *volumeControl;
	UIView *_sliderContainer;
}
@property (assign) SlideMode mode;
@property UISlider *slider;
@property (nonatomic, readonly) UICollectionView *collectionView;
@end

@interface UIToggle : UIButton
@property BOOL toggled;
@property UICollectionViewCell *cell;
@property (nonatomic, copy) void (^action)(UIToggle *toggle);
@end

@interface MCCollectionViewLayout : UICollectionViewFlowLayout
@end

#pragma mark global variable 

static NSArray *toggles;
static MultiCenter *center;


#pragma mark hooks

%hook SBDeckSwitcherViewController
- (void)viewDidLoad {
	center = [MultiCenter new];
	center.userInteractionEnabled = YES;
	%orig;
}

- (void)viewDidLayoutSubviews {
	%orig;
	if ([KazeSwitcherController() isVisible]) {
		[self.view addSubview:center];
		[self.view bringSubviewToFront:center];
	} else {
		[center removeFromSuperview];
	}

}
%end

%hook CCUIConnectivityModuleViewController
- (void)viewDidLayoutSubviews {
	%orig;
	if ([KazeSwitcherController() isVisible]) {
		[self.view addSubview:center];
		[self.view bringSubviewToFront:center];
	} else {
		[center removeFromSuperview];
	}

}

%end

#pragma mark implementation for interfaces

@implementation MultiCenter

static NSString * const reuseIdentifier = @"Cell";
static CGFloat collectionViewHeight = 75;

- (MultiCenter *)init {
	CGFloat height = kScreenHeight / 4;
	self = [super initWithFrame:CGRectMake(0, height * 3, kScreenWidth, height)];

	if (self) {
		self.mode = ModeVolumn;
		self.backgroundColor = UIColor.lightGrayColor;

		MCCollectionViewLayout *layout = [MCCollectionViewLayout new];
		_collectionView = [UICollectionView.alloc initWithFrame:CGRectMake(0, 0, kScreenWidth, collectionViewHeight) collectionViewLayout:layout];
		_collectionView.backgroundColor = UIColor.whiteColor;
		_collectionView.delegate = self;
		_collectionView.dataSource = self;
		[_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
		[self addSubview:_collectionView];
		[self setupSlider:(CGSize){kScreenWidth, height - collectionViewHeight}];
		volumeControl = [%c(VolumeControl) sharedVolumeControl];
	}
	return self;
}

- (void)setupSlider:(CGSize)size {
	CGFloat sliderHeight = size.height;
	_sliderContainer = [UIView.alloc initWithFrame:CGRectMake(0, collectionViewHeight, kScreenWidth, sliderHeight)];

	CGFloat sliderX = 75;
	self.slider = [UISlider.alloc initWithFrame:CGRectMake(sliderX, 0, kScreenWidth - 150, sliderHeight)];
	[self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
	[self.slider setMinimumTrackTintColor:[UIColor whiteColor]];
	[_sliderContainer addSubview:_slider];
	
	CGFloat buttonWidth = 18;
	CGFloat buttonX = (sliderX - buttonWidth) / 2;
	CGFloat yOffset = (sliderHeight - buttonWidth) / 2;
	UIToggle *brightness = [self getButtonWith:@"LessBright" frame:CGRectMake(buttonX, yOffset, buttonWidth, buttonWidth) action:@selector(changeMode:)];
	[_sliderContainer addSubview:brightness];
	
	UIToggle *volume = [self getButtonWith:@"speaker" frame:CGRectMake(size.width - buttonX - buttonWidth, yOffset, buttonWidth, buttonWidth) action:@selector(changeMode:)];
	[_sliderContainer addSubview:volume];

	[self addSubview:_sliderContainer];
	[self changeMode:brightness];
}

- (UIColor *)selectedBlueColor {
	return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
}

- (UIColor *)lightGrayColor {
	return [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:0.7];
}

- (UIToggle *)getButtonWith:(NSString *)imgName frame:(CGRect)frame action:(SEL)selector {

    UIToggle *button = [UIToggle buttonWithType:UIButtonTypeCustom];
    button.frame = frame;

    UIImage *image = [KazeImage(imgName) imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:image forState:UIControlStateNormal]; 

    button.tintColor = UIColor.blackColor;
	
	[button addTarget:center action:selector forControlEvents:UIControlEventTouchUpInside];

    return button;
}
# pragma mark action
- (void)sliderChanged:(UISlider *)sender {
	// NSLog(@"%@ %@", NSStringFromSelector(_cmd), sender);
	CGFloat value = sender.value;

	if (self.mode == ModeBrightness) {
		BKSDisplayBrightnessSet(value);
	} else if (self.mode == ModeVolumn) {
		[volumeControl setMediaVolume:value];
		[volumeControl hideVolumeHUDIfVisible];
	}
}

- (void)changeMode:(UIToggle *)modeToggle {
	if (self.mode == ModeBrightness) {
		self.mode = ModeVolumn;
		self.slider.value = [volumeControl volume];
	} else {
		self.mode = ModeBrightness;
		self.slider.value = BKSDisplayBrightnessGetCurrent();

	}
}

- (void)colorIfChosen:(UIToggle *)sender {
	sender.toggled = !sender.toggled;

	if (sender.toggled) {
		sender.cell.contentView.backgroundColor = [self selectedBlueColor];
		sender.tintColor = UIColor.whiteColor;
	} else {
		sender.cell.contentView.backgroundColor = [self lightGrayColor];
		sender.tintColor = UIColor.blackColor;
	}
	if (sender.action)
		sender.action(sender);
}

# pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSLog(@"%@", NSStringFromSelector(_cmd));

	
	NSString *imgName = toggles[indexPath.row];
	
	// UIImageView *imgView = [UIImageView.alloc initWithImage:KazeImage(imgName)];
	UIToggle *toggle = [self getButtonWith:imgName frame:CGRectMake(9, 9, 30, 30) action:@selector(colorIfChosen:)];
	toggle.cell = cell;

	[cell.contentView addSubview:toggle];

	cell.contentView.backgroundColor = [self lightGrayColor];
	cell.contentView.layer.cornerRadius = 24;

    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return CGSizeMake(48, 48);
}

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
@end

@implementation DualSliderContainerView
- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	return self;
}
@end

@implementation UIToggle
@end

@implementation MCCollectionViewLayout
- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
	MultiCenter* controller = (MultiCenter *)self.collectionView.delegate;

	NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];

	CGSize size = [controller collectionView:self.collectionView layout:self sizeForItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
	CGFloat xOffset = (kScreenWidth - 17.5 * 4 - size.width * 5 ) / 2;
	CGFloat yOffset = (CGRectGetHeight(self.collectionView.frame) - size.height ) / 2;

	for (int i = 0; attributes.count > i; i++) {
		UICollectionViewLayoutAttributes* curAttributes = attributes[i];
		curAttributes.frame = CGRectOffset(curAttributes.frame, xOffset, yOffset);
	}
	return attributes;
}
@end

%ctor {
	// controlBlueColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
	// lightGrayColor = [UIColor colorWithRed:211.0f/255.0f green:211.0f/255.0f blue:211.0f/255.0f alpha:0.8f];
	toggles = @[@"Airplane", @"Wifi", @"CCBluetooth", @"DND", @"locked"];
}