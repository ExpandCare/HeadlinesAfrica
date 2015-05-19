//
//  HLTextField.m
//  Headlines
//
//

#import "HLTextField.h"
#import "UIFont+Consended.h"

#define PADDING 0

@interface HLTextField ()

@property (strong, nonatomic) UIView *theLine;

@end

@implementation HLTextField

- (void)awakeFromNib
{
    UIFont *theFont = [UIFont consendedWithSize:15];
    
    self.font = theFont;
}

- (BOOL)becomeFirstResponder
{
    BOOL outcome = [super becomeFirstResponder];
    
    if (self.HLTextFieldDelegate && [self.HLTextFieldDelegate respondsToSelector:@selector(textFieldIsActive)])
    {
        [self.HLTextFieldDelegate textFieldIsActive];
    }
    
    return outcome;
}

- (BOOL)resignFirstResponder
{
    BOOL outcome = [super resignFirstResponder];
    
    if (self.HLTextFieldDelegate && [self.HLTextFieldDelegate respondsToSelector:@selector(textFieldIsInactive)])
    {
        [self.HLTextFieldDelegate textFieldIsInactive];
    }
    
    return outcome;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [self rectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self rectForBounds:bounds];
}

- (CGRect)rectForBounds:(CGRect)bounds
{
    bounds.origin.x = PADDING;
    bounds.size.width -= PADDING;
    
    return bounds;
}

- (void) drawPlaceholderInRect:(CGRect)rect
{
    if (self.placeholder)
    {
        UIFont *font = self.font;//[UIFont consendedWithSize:25];
        
        CGSize drawSize = [self.placeholder sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
        CGRect drawRect = rect;
        
        // verticially align text
        drawRect.origin.y = (rect.size.height - drawSize.height) * 0.5;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = self.textAlignment;
        
        [[self placeholder] drawInRect:drawRect withAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1],
                                                                 NSFontAttributeName: font,
                                                                 NSParagraphStyleAttributeName : paragraphStyle}];
    }
}

@end
