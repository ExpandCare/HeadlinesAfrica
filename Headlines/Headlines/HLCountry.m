//
//  HLCountry.m
//  Headlines
//
//  Created by Алексей Поляков on 07.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import "HLCountry.h"
#import "NSUserDefaults+Countries.h"

@implementation HLCountry

+ (HLCountry *)countryWithName:(NSString *)name
{
    HLCountry *country = [self new];
    
    country.name = name;
    
    if ([[NSUserDefaults enabledCountries] containsObject:country.name])
    {
        country.selected = YES;
    }
    
    return country;
}

+ (NSArray *)countriesWithNames:(NSArray *)names
{
    NSMutableArray *countries = [NSMutableArray new];
    
    for (NSString *name in names)
    {
        [countries addObject:[self countryWithName:name]];
    }
    
    return countries;
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFilterChanged
                                                            object:nil];
        
        if (selected)
        {
            [NSUserDefaults countryEnabled:self.name];
        }
        else
        {
            [NSUserDefaults countryDisabled:self.name];
        }
        
        [NSUserDefaults setCountryPostsUpdateNeeded];
    }
    
    _selected = selected;
}

@end
