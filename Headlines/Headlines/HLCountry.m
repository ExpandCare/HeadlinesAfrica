//
//  HLCountry.m
//  Headlines
//
//  Created by Алексей Поляков on 07.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import "HLCountry.h"

@implementation HLCountry

+ (HLCountry *)countryWithName:(NSString *)name
{
    HLCountry *country = [self new];
    
    country.name = name;
    
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

@end
