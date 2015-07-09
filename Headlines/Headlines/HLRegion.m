//
//  HLRegion.m
//  Headlines
//
//  Created by Алексей Поляков on 07.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import "HLRegion.h"
#import "HLCountry.h"

@implementation HLRegion

+ (HLRegion *)regionWithName:(NSString *)name countries:(NSArray *)countries
{
    HLRegion *region = [self new];
    
    region.name = name;
    region.countries = countries;
    
    [region checkCountrySelection];
    
    return region;
}

- (BOOL)isAllCountriesSelected
{
    for (HLCountry *country in self.countries)
    {
        if (!country.selected)
        {
            return NO;
        }
    }
    
    return YES;
}

- (void)checkCountrySelection
{
    if ([self isAllCountriesSelected])
    {
        self.selected = YES;
    }
}

@end
