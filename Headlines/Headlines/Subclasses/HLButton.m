//
//  HLButton.m
//  Headlines
//
//  Created by Алексей Поляков on 06.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import "HLButton.h"

@implementation HLButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        self.backgroundColor = HEADLINES_BLUE;
        [self setTitleColor:[UIColor whiteColor]
                   forState:UIControlStateNormal];
        self.layer.borderColor = HEADLINES_BLUE.CGColor;
        self.layer.borderWidth = 0;
    }
    else
    {
        self.backgroundColor = [UIColor clearColor];
        [self setTitleColor:[UIColor grayColor]
                   forState:UIControlStateNormal];
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 1;
    }
}

@end
