//
//  HLHeaderViewCell.m
//  Headlines
//
//

#import "HLHeaderViewCell.h"

@implementation HLHeaderViewCell

- (void)awakeFromNib
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Africa's #1\n"
                                      "news platform"];
    
    [str addAttribute:NSFontAttributeName
                value:[UIFont boldSystemFontOfSize:15]
                range:NSMakeRange(0, str.length)];
    [str addAttribute:NSForegroundColorAttributeName
                value:[UIColor colorWithRed:0.5 green:0.5 blue:0.52 alpha:1]
                range:NSMakeRange(0, str.length)];
    [str addAttribute:NSFontAttributeName
                value:[UIFont boldSystemFontOfSize:19]
                range:NSMakeRange(0, @"Africa's #1".length)];
    [str addAttribute:NSForegroundColorAttributeName
                value:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]
                range:NSMakeRange(0, @"Africa's #1".length)];
    
    self.textView.attributedText = str;
    
    self.textView.minimumScaleFactor = 0.3;
    self.textView.adjustsFontSizeToFitWidth = YES;
}

@end
