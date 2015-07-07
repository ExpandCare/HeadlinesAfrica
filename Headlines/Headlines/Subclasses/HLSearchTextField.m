//
//  HLSearchTextField.m
//  Headlines
//
//  Created by Алексей Поляков on 07.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import "HLSearchTextField.h"

#define LEFT_PADDING 30
#define TEXT_COLOR [UIColor colorWithRed:0.54 green:0.54 blue:0.54 alpha:1]

@implementation HLSearchTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.textColor = TEXT_COLOR;
    self.layer.cornerRadius = 8;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    
    UIToolbar* keyboardCancelButtonView = [[UIToolbar alloc] init];
    [keyboardCancelButtonView sizeToFit];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(cancelPressed:)];
    
    cancelButton.tintColor = HEADLINES_BLUE_NEW;
    
    [keyboardCancelButtonView setItems:[NSArray arrayWithObjects:flexibleSpace, cancelButton, nil]];
    self.inputAccessoryView = keyboardCancelButtonView;
}

- (void)cancelPressed:(UIButton *)sender
{
    self.text = nil;
    
    [self resignFirstResponder];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [super textRectForBounds:bounds];
    
    rect.origin.x = LEFT_PADDING;
    rect.size.width -= LEFT_PADDING;
    
    return rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x = LEFT_PADDING;
    bounds.size.width -= LEFT_PADDING;
    
    return bounds;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGRect rect = [super placeholderRectForBounds:bounds];
    
    rect.origin.x = LEFT_PADDING;
    rect.size.width -= LEFT_PADDING;
    
    return rect;
}

- (void) drawPlaceholderInRect:(CGRect)rect
{
    if (self.placeholder)
    {
        UIFont *font = self.font;
        
        CGSize drawSize = [self.placeholder sizeWithAttributes:[NSDictionary dictionaryWithObject:font
                                                                                           forKey:NSFontAttributeName]];
        CGRect drawRect = rect;
        
        // verticially align text
        drawRect.origin.y = (rect.size.height - drawSize.height) * 0.5;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = self.textAlignment;
        
        [[self placeholder] drawInRect:drawRect withAttributes:@{NSForegroundColorAttributeName: TEXT_COLOR,
                                                                 NSFontAttributeName: font,
                                                                 NSParagraphStyleAttributeName : paragraphStyle}];
    }
}

@end
