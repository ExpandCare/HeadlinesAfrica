//
//  ButtonCell.m
//  Headlines
//
//

#import "ButtonCell.h"
#import "UIFont+Consended.h"

@implementation ButtonCell

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    
    self.theButton.layer.borderWidth = 1;
    self.theButton.layer.borderColor = self.theButton.titleLabel.textColor.CGColor;
    self.theButton.layer.cornerRadius = CGRectGetHeight(self.theButton.frame) / 2;
}

- (void)setIsActive:(BOOL)isActive
{
    _isActive = isActive;
    
    if (isActive)
    {
        self.theButton.layer.borderWidth = 0;
        [self.theButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.theButton setBackgroundColor:[UIColor colorWithRed:0.03 green:0.6 blue:0.79 alpha:1]];
    }
    else
    {
        self.theButton.layer.borderWidth = 1;
        [self.theButton setTitleColor:[UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1] forState:UIControlStateNormal];
        [self.theButton setBackgroundColor:[UIColor clearColor]];
    }
}

@end
