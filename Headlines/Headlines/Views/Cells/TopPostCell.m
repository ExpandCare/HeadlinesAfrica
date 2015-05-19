//
//  TopPostCell.m
//  Headlines
//
//

#import "TopPostCell.h"
#import "UIFont+Consended.h"
#import <QuartzCore/QuartzCore.h>

#define DOWN_BUTTON_HEIGHT 20
#define DOWN_BUTTON_BOTTOM 11

@interface TopPostCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollDownHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollDownBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *gradientView;

@end

@implementation TopPostCell
{
    CAGradientLayer *gradientLayer;
}

- (void)awakeFromNib
{
    [self.titleLabel setFont:[UIFont mediumConsendedWithSize:30]];
    [self.authorLabel setFont:[UIFont consendedWithSize:19]];
    [self.dateLabel setFont:[UIFont consendedWithSize:19]];
    
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    
    self.titleLabel.minimumScaleFactor = 0.5;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.logoView.layer.masksToBounds = YES;
    self.backgroundImage.clipsToBounds = YES;
    
    self.dateLabel.minimumScaleFactor = 0.5;
    self.dateLabel.adjustsFontSizeToFitWidth = YES;
    
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.gradientView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[HEADLINES_BLUE CGColor], nil];
    
    [self.gradientView.layer insertSublayer:gradientLayer atIndex:0];
    
    self.scrollDownButton.contentEdgeInsets = UIEdgeInsetsMake(4, 8, 4, 8);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.gradientView.bounds;
    bounds.size.width = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    gradientLayer.frame = bounds;
}

- (void)configureForCategoryScreen:(BOOL)isCategoryNews
{
    self.scrollDownButton.hidden = (isCategoryNews ? NO : YES);
    self.logoView.hidden = YES;//(isCategoryNews ? YES : NO);
    
    self.scrollDownHeightConstraint.constant = (isCategoryNews ? DOWN_BUTTON_HEIGHT : 0);
    self.scrollDownBottomConstraint.constant = (isCategoryNews ? DOWN_BUTTON_BOTTOM : 0);
    
    [self layoutIfNeeded];
}

@end
