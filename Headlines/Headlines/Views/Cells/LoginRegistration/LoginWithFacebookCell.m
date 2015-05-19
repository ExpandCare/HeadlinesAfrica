//
//  LoginWithFacebookCell.m
//  Headlines
//
//

#import "LoginWithFacebookCell.h"
#import "UIFont+Consended.h"

@implementation LoginWithFacebookCell

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
 
    [self.usingEmailLabel setFont:[UIFont consendedWithSize:14]];
    self.usingEmailLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    
    //[self.facebookButton.titleLabel setFont:[UIFont mediumConsendedWithSize:20]];
    self.facebookButton.layer.masksToBounds = YES;
    self.facebookButton.layer.cornerRadius = CGRectGetHeight(self.facebookButton.frame) / 2;
    //[self.facebookButton setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, -3, 0)];
}

@end
