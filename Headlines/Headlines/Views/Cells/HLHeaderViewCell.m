//
//  HLHeaderViewCell.m
//  Headlines
//
//

#import "HLHeaderViewCell.h"

@implementation HLHeaderViewCell

- (void)awakeFromNib
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Featuring:\n"
                                      "Vanguard\n"
                                      "Punch\n"
                                      "This Day Live\n"
                                      "Bella Naija\n"
                                      "Linda Ikeji\n"
                                      "& more...\n"];
    
    [str addAttribute:NSFontAttributeName
                value:[UIFont boldSystemFontOfSize:20]
                range:NSMakeRange(0, str.length)];
    [str addAttribute:NSForegroundColorAttributeName
                value:[UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1]
                range:NSMakeRange(0, str.length)];
    [str addAttribute:NSForegroundColorAttributeName
                value:[UIColor colorWithRed:0.73 green:0.73 blue:0.73 alpha:1]
                range:NSMakeRange(0, @"Featuring:".length)];
    
    self.textView.attributedText = str;
    
    self.textView.minimumScaleFactor = 0.3;
    self.textView.adjustsFontSizeToFitWidth = YES;
}

@end
