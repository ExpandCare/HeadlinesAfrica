//
//  NSUserDefaults+Countries.m
//  Headlines
//
//  Created by Алексей Поляков on 08.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import "NSUserDefaults+Countries.h"

@implementation NSUserDefaults (Countries)

+ (void)setCountryPostsUpdateNeeded
{
    [[NSUserDefaults standardUserDefaults] setBool:YES
                                            forKey:kDefaultsNeedToUpdate];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Need to update now");
}

+ (void)countryPostsUpdated
{
    [[NSUserDefaults standardUserDefaults] setBool:NO
                                            forKey:kDefaultsNeedToUpdate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)countryPostsUpdateNeeded
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsNeedToUpdate];
}

+ (void)countryEnabled:(NSString *)countryName
{
    NSArray *arr = [self enabledCountries];
    
    if (!arr)
    {
        arr = @[];
    }
    
    if (![arr containsObject:countryName])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[arr arrayByAddingObject:countryName]
                                                  forKey:kDefaultsEnabledCountries];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)countryDisabled:(NSString *)countryName
{
    NSArray *arr = [self enabledCountries];
    
    if (!arr.count)
    {
        return;
    }
    
    NSMutableArray *newCountriesList = [NSMutableArray new];
    
    for (NSString *tmpCountryName in arr)
    {
        if (![tmpCountryName isEqualToString:countryName])
        {
            [newCountriesList addObject:tmpCountryName];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:newCountriesList]
                                              forKey:kDefaultsEnabledCountries];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)enabledCountries
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsEnabledCountries];
}

@end
