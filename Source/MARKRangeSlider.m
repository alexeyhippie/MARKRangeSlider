#import "MARKRangeSlider.h"

static NSString * const kMARKRangeSliderThumbImage = @"rangeSliderThumb.png";
static NSString * const kMARKRangeSliderTrackImage = @"rangeSliderTrack.png";
static NSString * const kMARKRangeSliderTrackRangeImage = @"rangeSliderTrackRange.png";

@interface MARKRangeSlider ()

@property (nonatomic) CGFloat currentLeftValue;
@property (nonatomic) CGFloat currentRightValue;

@property (nonatomic) UIImageView *trackImageView;
@property (nonatomic) UIImageView *rangeImageView;

@property (nonatomic) UIImageView *leftThumbImageView;
@property (nonatomic) UIImageView *rightThumbImageView;

@end

@implementation MARKRangeSlider

@synthesize currentLeftValue = _currentLeftValue;
@synthesize currentRightValue = _currentRightValue;
@synthesize trackImage = _trackImage;
@synthesize rangeImage = _rangeImage;
@synthesize leftThumbImage = _leftThumbImage;
@synthesize rightThumbImage = _rightThumbImage;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
        [self setUpViewComponents];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
        [self setUpViewComponents];
    }
    return self;
}

#pragma mark - Public

- (void)setMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue {
    self.maximumValue = maxValue;
    self.minimumValue = minValue;
}

- (void)setLeftValue:(CGFloat)leftValue rightValue:(CGFloat)rightValue {
    if (leftValue == 0 && rightValue == 0) {
        self.currentLeftValue = leftValue;
        self.currentRightValue = rightValue;
    } else {
        self.currentRightValue = rightValue;
        self.currentLeftValue = leftValue;
    }
}

#pragma mark - Configuration

- (void)setDefaults
{
    self.minimumValue = 0.0f;
    self.maximumValue = 1.0f;
    self.currentLeftValue = self.minimumDistance;
    self.currentRightValue = self.maximumValue;
    self.minimumDistance = 0.2f;
}

- (void)setUpViewComponents
{
    self.multipleTouchEnabled = YES;

    // Init track image
    self.trackImageView = [[UIImageView alloc] initWithImage:self.trackImage];
    [self addSubview:self.trackImageView];

    // Init range image
    self.rangeImageView = [[UIImageView alloc] initWithImage:self.rangeImage];
    [self addSubview:self.rangeImageView];

    // Init left thumb image
    self.leftThumbImageView = [[UIImageView alloc] initWithImage:self.leftThumbImage];
    self.leftThumbImageView.userInteractionEnabled = YES;
    self.leftThumbImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.leftThumbImageView];

    // Add left pan recognizer
    UIPanGestureRecognizer *leftPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    [self.leftThumbImageView addGestureRecognizer:leftPanRecognizer];

    // Init right thumb image
    self.rightThumbImageView = [[UIImageView alloc] initWithImage:self.rightThumbImage];
    self.rightThumbImageView.userInteractionEnabled = YES;
    self.rightThumbImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.rightThumbImageView];

    // Add right pan recognizer
    UIPanGestureRecognizer *rightPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    [self.rightThumbImageView addGestureRecognizer:rightPanRecognizer];
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    CGFloat width = _trackImage.size.width + _leftThumbImage.size.width + _rightThumbImage.size.width;
    CGFloat height = MAX(_leftThumbImage.size.height, _rightThumbImage.size.height);

    return CGSizeMake(width, height);
}

- (void)layoutSubviews
{
    // Calculate coords & sizes
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);

    CGFloat trackHeight = _trackImage.size.height;

    CGSize leftThumbImageSize = self.leftThumbImageView.image.size;
    CGSize rightThumbImageSize = self.rightThumbImageView.image.size;

    CGFloat leftAvailableWidth = width - leftThumbImageSize.width;
    CGFloat rightAvailableWidth = width - rightThumbImageSize.width;
    if (self.disableOverlapping) {
        leftAvailableWidth -= leftThumbImageSize.width;
        rightAvailableWidth -= rightThumbImageSize.width;
    }

    CGFloat leftInset = leftThumbImageSize.width / 2;
    CGFloat rightInset = rightThumbImageSize.width / 2;

    CGFloat trackRange = self.maximumValue - self.minimumValue;

    CGFloat leftX = floorf((self.currentLeftValue - self.minimumValue) / trackRange * leftAvailableWidth);
    if (isnan(leftX)) {
        leftX = 0.0;
    }

    CGFloat rightX = floorf((self.currentRightValue - self.minimumValue) / trackRange * rightAvailableWidth);
    if (isnan(rightX)) {
        rightX = 0.0;
    }

    CGFloat trackY = (height - trackHeight) / 2;
    CGFloat gap = 1.0;

    // Set track frame
    CGFloat trackX = gap;
    CGFloat trackWidth = width - gap * 2;
    if (self.disableOverlapping) {
        trackX += leftInset;
        trackWidth -= leftInset + rightInset;
    }
    self.trackImageView.frame = CGRectMake(trackX, trackY, trackWidth, trackHeight);

    // Set range frame
    CGFloat rangeWidth = rightX - leftX;
    if (self.disableOverlapping) {
        rangeWidth += rightInset + gap;
    }
    self.rangeImageView.frame = CGRectMake(leftX + leftInset, trackY, rangeWidth, trackHeight);

    // Set thumb image view frame sizes
    CGRect leftImageViewFrame = { CGPointMake(0, 0), leftThumbImageSize };
    CGRect rightImageViewFrame = { CGPointMake(0, 0), rightThumbImageSize };
    self.leftThumbImageView.frame = leftImageViewFrame;
    self.rightThumbImageView.frame = rightImageViewFrame;

    // Set left & right thumb frames
    leftX += leftInset;
    rightX += rightInset;
    if (self.disableOverlapping) {
        rightX = rightX + rightInset * 2 - gap;
    }
    self.leftThumbImageView.center = CGPointMake(leftX, height / 2);
    self.rightThumbImageView.center = CGPointMake(rightX, height / 2);
}

#pragma mark - Gesture recognition

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        //Fix when minimumDistance = 0.0 and slider is move to 1.0-1.0
        [self bringSubviewToFront:self.leftThumbImageView];

        CGPoint translation = [gesture translationInView:self];
        CGFloat trackRange = self.maximumValue - self.minimumValue;
        CGFloat width = CGRectGetWidth(self.frame) - CGRectGetWidth(self.leftThumbImageView.frame);

        // Change left value
        self.currentLeftValue += translation.x / width * trackRange;

        [gesture setTranslation:CGPointZero inView:self];

        [self sendActionsForControlEvents:UIControlEventValueChanged];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self sendActionsForControlEvents:UIControlEventTouchDragExit];
        self.currentLeftValue = self.leftValue;
    }
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        //Fix when minimumDistance = 0.0 and slider is move to 1.0-1.0
        [self bringSubviewToFront:self.rightThumbImageView];

        CGPoint translation = [gesture translationInView:self];
        CGFloat trackRange = self.maximumValue - self.minimumValue;
        CGFloat width = CGRectGetWidth(self.frame) - CGRectGetWidth(self.rightThumbImageView.frame);

        // Change right value
        self.currentRightValue += translation.x / width * trackRange;

        [gesture setTranslation:CGPointZero inView:self];

        [self sendActionsForControlEvents:UIControlEventValueChanged];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        self.currentRightValue = self.rightValue;
        [self sendActionsForControlEvents:UIControlEventTouchDragExit];
    }
}

#pragma mark - Getters

- (UIView *)leftThumbView
{
    return self.leftThumbImageView;
}

- (UIView *)rightThumbView
{
    return self.rightThumbImageView;
}

- (UIImage *)trackImage
{
    if (!_trackImage) {
        _trackImage = [self bundleImageNamed: kMARKRangeSliderTrackImage];
    }
    return _trackImage;
}

- (UIImage *)rangeImage
{
    if (!_rangeImage) {
        _rangeImage = [self bundleImageNamed: kMARKRangeSliderTrackRangeImage];
    }
    return _rangeImage;
}

- (UIImage *)leftThumbImage
{
    if (!_leftThumbImage) {
        _leftThumbImage = [self bundleImageNamed: kMARKRangeSliderThumbImage];
    }
    return _leftThumbImage;
}

- (UIImage *)rightThumbImage
{
    if (!_rightThumbImage) {
        _rightThumbImage = [self bundleImageNamed: kMARKRangeSliderThumbImage];
    }
    return _rightThumbImage;
}

#pragma mark - Setters

- (void)setMinimumValue:(CGFloat)minimumValue
{
    if (minimumValue >= self.maximumValue) {
        minimumValue = self.maximumValue - self.minimumDistance;
    }

    if (self.currentLeftValue < minimumValue) {
        self.currentLeftValue = minimumValue;
    }

    if (self.currentRightValue < minimumValue) {
        self.currentRightValue = self.maximumValue;
    }

    _minimumValue = minimumValue;

    [self checkMinimumDistance];

    [self setNeedsLayout];
}

- (void)setMaximumValue:(CGFloat)maximumValue
{
    if (maximumValue <= self.minimumValue) {
        maximumValue = self.minimumValue + self.minimumDistance;
    }

    if (self.currentLeftValue > maximumValue) {
        self.currentLeftValue = self.minimumValue;
    }

    if (self.currentRightValue > maximumValue) {
        self.currentRightValue = maximumValue;
    }

    _maximumValue = maximumValue;

    [self checkMinimumDistance];

    [self setNeedsLayout];
}

- (void)setCurrentLeftValue:(CGFloat)currentLeftValue
{
    CGFloat allowedValue = self.currentRightValue - self.minimumDistance;
    if (currentLeftValue > allowedValue) {
        if (self.pushable) {
            CGFloat rightSpace = self.maximumValue - self.currentRightValue;
            CGFloat deltaLeft = self.minimumDistance - (self.currentRightValue - currentLeftValue);
            if (deltaLeft > 0 && rightSpace > deltaLeft) {
                self.currentRightValue += deltaLeft;
            }
            else {
                currentLeftValue = allowedValue;
            }
        }
        else {
            currentLeftValue = allowedValue;
        }
    }
    
    if (currentLeftValue < self.minimumValue) {
        currentLeftValue = self.minimumValue;
        if (self.currentRightValue - currentLeftValue < self.minimumDistance) {
            self.currentRightValue = currentLeftValue + self.minimumDistance;
        }
    }
    
    _currentLeftValue = currentLeftValue;
    
    [self setNeedsLayout];
}

- (void)setCurrentRightValue:(CGFloat)currentRightValue
{
    CGFloat allowedValue = self.currentLeftValue + self.minimumDistance;
    if (currentRightValue < allowedValue) {
        if (self.pushable) {
            CGFloat leftSpace = self.currentLeftValue - self.minimumValue;
            CGFloat deltaRight = self.minimumDistance - (currentRightValue - self.currentLeftValue);
            if (deltaRight > 0 && leftSpace > deltaRight) {
                self.currentLeftValue -= deltaRight;
            }
            else {
                currentRightValue = allowedValue;
            }
        }
        else {
            currentRightValue = allowedValue;
        }
    }
    
    if (currentRightValue > self.maximumValue) {
        currentRightValue = self.maximumValue;
        if (currentRightValue - self.currentLeftValue < self.minimumDistance) {
            self.currentLeftValue = currentRightValue - self.minimumDistance;
        }
    }
    
    _currentRightValue = currentRightValue;
    
    [self setNeedsLayout];
}

- (CGFloat)leftValue
{
    return [self _nearestAllowedValueTo: self.currentLeftValue];
}

- (CGFloat)rightValue
{
    return [self _nearestAllowedValueTo: self.currentRightValue];
}

- (CGFloat)_nearestAllowedValueTo:(CGFloat) value
{
    CGFloat result = value;
    
    if (self.allowedValues.count != 0) {
        
        CGFloat highValue = 0.0;
        NSInteger index = 0;
        for (NSNumber* anAllowedValue in self.allowedValues) {
            if (anAllowedValue.floatValue > value) {
                highValue = anAllowedValue.floatValue;
                break;
            }
            index++;
        }
        if (highValue == 0.0) {
            highValue = [(NSNumber *)self.allowedValues.lastObject floatValue];
            index = self.allowedValues.count - 1;
        }
        
        if (index != 0)
        {
            CGFloat lowValue = [(NSNumber *)(self.allowedValues[index - 1]) floatValue];
            if ((value - lowValue) > (highValue - value)) {
                result = highValue;
            } else {
                result = lowValue;
            }
        } else {
            result = highValue;
        }
    }
    
    return result;
}

- (void)setMinimumDistance:(CGFloat)minimumDistance
{
    CGFloat distance = self.maximumValue - self.minimumValue;
    if (minimumDistance > distance) {
        minimumDistance = distance;
    }

    if (self.currentRightValue - self.currentLeftValue < minimumDistance) {
        // Reset left and right values
        self.currentLeftValue = self.minimumValue;
        self.currentRightValue = self.maximumValue;
    }

    _minimumDistance = minimumDistance;

    [self setNeedsLayout];
}

#pragma mark - Setters

- (void)setTrackImage:(UIImage *)trackImage
{
    _trackImage = trackImage;
    self.trackImageView.image = _trackImage;
}

- (void)setRangeImage:(UIImage *)rangeImage
{
    _rangeImage = rangeImage;
    self.rangeImageView.image = _rangeImage;
}

- (void)setLeftThumbImage:(UIImage *)leftThumbImage
{
    _leftThumbImage = leftThumbImage;
    self.leftThumbImageView.image = _leftThumbImage;
}

- (void)setRightThumbImage:(UIImage *)rightThumbImage
{
    _rightThumbImage = rightThumbImage;
    self.rightThumbImageView.image = _rightThumbImage;
}

#pragma mark - Helpers

- (UIImage *)bundleImageNamed:(NSString *)imageName
{
    NSString *bundlePath = [[[NSBundle bundleForClass:self.class] resourcePath]
                            stringByAppendingPathComponent:@"MARKRangeSlider.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath: bundlePath];
    if ([UITraitCollection class]) {
        // Use default traits associated with main screen
        return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        // Backward compatible for pre iOS 8
        return [self imageNamed:imageName inBundle:bundle];
    }
}

- (UIImage *)imageNamed:(NSString *)imageName inBundle:(NSBundle *)bundle
{
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        NSInteger scale = [[UIScreen mainScreen] scale];
        NSString *scalledImagePath = [[bundle resourcePath]
                            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@%ldx.%@",
                                                            [imageName stringByDeletingPathExtension],
                                                            (long) scale,
                                                            [imageName pathExtension]]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:scalledImagePath]) {
            return [[UIImage alloc] initWithContentsOfFile:scalledImagePath];
        }
    }
    return nil;
}

- (void)checkMinimumDistance
{
    if (self.maximumValue - self.minimumValue < self.minimumDistance) {
        self.minimumDistance = 0.0f;
    }
}

@end
