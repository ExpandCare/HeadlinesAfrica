//
//  HLCountryCell.m
//  Headlines
//
//  Created by Алексей Поляков on 06.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#define BORDER_COLOR [UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1]
#define TEXT_COLOR [UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1]

#import "HLCountryCell.h"

@implementation HLCountryCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.containerView.layer.cornerRadius = 8;
    self.indicatorView.layer.cornerRadius = CGRectGetWidth(self.indicatorView.frame) / 2;
    self.theLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        self.containerView.backgroundColor = HEADLINES_BLUE_NEW;
        self.containerView.layer.borderColor = HEADLINES_BLUE_NEW.CGColor;
        self.theLabel.textColor = [UIColor whiteColor];
        self.indicatorView.backgroundColor = [UIColor whiteColor];
        self.indicatorView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    else
    {
        self.containerView.backgroundColor = [UIColor clearColor];
        self.containerView.layer.borderColor = BORDER_COLOR.CGColor;
        self.containerView.layer.borderWidth = 1.f;
        self.theLabel.textColor = TEXT_COLOR;
        self.indicatorView.backgroundColor = [UIColor clearColor];
     
        self.indicatorView.layer.borderWidth = 0.5f;
        self.indicatorView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

@end
