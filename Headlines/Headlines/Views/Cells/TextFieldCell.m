//
//  TextFieldCell.m
//  Headlines
//
//

#import "TextFieldCell.h"

#define ACTIVE_COLOR [UIColor colorWithRed:0.02 green:0.57 blue:0.84 alpha:1]
#define INACTIVE_COLOR [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1]

@interface TextFieldCell () <HLTextFieldDelegate>

@end

@implementation TextFieldCell

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.theTextField.backgroundColor = [UIColor clearColor];
    self.theTextField.HLTextFieldDelegate = self;
    
    self.theTextField.textAlignment = NSTextAlignmentLeft;
    
    [self.theTextField resignFirstResponder];
}

#pragma mark - HLTextFieldDelegate

- (void)textFieldIsActive
{
    self.lineView.backgroundColor = ACTIVE_COLOR;
}

- (void)textFieldIsInactive
{
    self.lineView.backgroundColor = INACTIVE_COLOR;
}

@end
