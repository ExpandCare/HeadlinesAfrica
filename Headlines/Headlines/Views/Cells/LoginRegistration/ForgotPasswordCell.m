//
//  ForgotPasswordCell.m
//  Headlines
//
//

#import "ForgotPasswordCell.h"
#import "UIFont+Consended.h"

@implementation ForgotPasswordCell

- (void)awakeFromNib
{
    [self.forgotPasswordButton.titleLabel setFont:[UIFont consendedWithSize:13]];
}

@end
