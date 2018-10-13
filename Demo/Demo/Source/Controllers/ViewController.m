#import "ViewController.h"
#import "MARKRangeSlider.h"
#import "UIColor+Demo.h"

static CGFloat const kViewControllerRangeSliderWidth = 290.0;
static CGFloat const kViewControllerLabelWidth = 100.0;

@interface ViewController ()

@property (nonatomic, strong) MARKRangeSlider *rangeSlider;
@property (nonatomic, strong) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Additional setup after loading the view
    self.title = @"Slider Demo";
    self.view.backgroundColor = [UIColor backgroundColor];
    [self setUpViewComponents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat labelX = (CGRectGetWidth(self.view.frame) - kViewControllerLabelWidth) / 2;
    self.label.frame = CGRectMake(labelX, 210.0, kViewControllerLabelWidth, 20.0);

    CGFloat sliderX = (CGRectGetWidth(self.view.frame) - kViewControllerRangeSliderWidth) / 2;
    self.rangeSlider.frame = CGRectMake(sliderX, CGRectGetMaxY(self.label.frame) + 20.0, 290.0, 20.0);
}

#pragma mark - Actions

- (void)rangeSliderValueDidChange:(MARKRangeSlider *)slider
{
    [self updateRangeText];
}

#pragma mark - UI

- (void)setUpViewComponents
{
    // Text label
    self.label = [[UILabel alloc] initWithFrame:CGRectZero];
    self.label.backgroundColor = [UIColor backgroundColor];
    self.label.numberOfLines = 1;
    self.label.textColor = [UIColor secondaryTextColor];

    // Init slider
    self.rangeSlider = [[MARKRangeSlider alloc] initWithFrame:CGRectZero];
    self.rangeSlider.backgroundColor = [UIColor backgroundColor];
    [self.rangeSlider addTarget:self
                         action:@selector(rangeSliderValueDidChange:)
               forControlEvents:UIControlEventValueChanged];

    [self.rangeSlider setMinValue:1 maxValue:1000];
    [self.rangeSlider setLeftValue:100 rightValue:700];
    [self.rangeSlider setAllowedValues:@[@1, @5, @10, @15, @20, @25, @30, @35, @40, @45, @50, @60, @70, @80, @90, @100, @130, @160, @190, @220, @250, @300, @350, @400, @450, @500, @600, @700, @800, @900, @1000]];

    self.rangeSlider.minimumDistance = 0.2;

    [self updateRangeText];

    [self.view addSubview:self.label];
    [self.view addSubview:self.rangeSlider];
}

- (void)updateRangeText
{
//    NSLog(@"%0.2f - %0.2f", self.rangeSlider.leftValue, self.rangeSlider.rightValue);
    self.label.text = [NSString stringWithFormat:@"%li - %li",
                       (long)self.rangeSlider.leftValue, (long)self.rangeSlider.rightValue];
}

@end
