//
//  HLSearchField.m
//  Headlines

#import "HLSearchField.h"

@implementation HLSearchField

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        self.clipsToBounds = NO;
        [self setLeftViewMode:UITextFieldViewModeAlways];
        UIImageView *searchImagView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"_0003_icon_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [searchImagView setTintColor:[UIColor colorWithRed:0.54 green:0.8 blue:0.92 alpha:1]];
        self.leftView = searchImagView;
    }
    
    return self;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect textRect = [super leftViewRectForBounds:bounds];
    textRect.origin.x -= 10;
    return textRect;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset( bounds, 10, 0 );
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset( bounds, 10, 0 );
}

@end
