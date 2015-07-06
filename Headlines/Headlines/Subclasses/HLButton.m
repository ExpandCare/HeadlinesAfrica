//
//  HLButton.m
//  Headlines
//
//  Created by Алексей Поляков on 06.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import "HLButton.h"

#define BORDER_COLOR [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1]

@implementation HLButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 7;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        self.backgroundColor = HEADLINES_BLUE_NEW;
        [self setTitleColor:[UIColor whiteColor]
                   forState:UIControlStateNormal];
        self.layer.borderColor = HEADLINES_BLUE_NEW.CGColor;
        self.layer.borderWidth = 0;
    }
    else
    {
        self.backgroundColor = [UIColor clearColor];
        [self setTitleColor:[UIColor grayColor]
                   forState:UIControlStateNormal];
        self.layer.borderColor = BORDER_COLOR.CGColor;
        self.layer.borderWidth = 1;
    }
}

@end
