//
//  HLRegion.m
//  Headlines
//
//  Created by Алексей Поляков on 07.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import "HLRegion.h"

@implementation HLRegion

+ (HLRegion *)regionWithName:(NSString *)name countries:(NSArray *)countries
{
    HLRegion *region = [self new];
    
    region.name = name;
    region.countries = countries;
    
    return region;
}

@end
