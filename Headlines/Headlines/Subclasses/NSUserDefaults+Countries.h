//
//  NSUserDefaults+Countries.h
//  Headlines
//
//  Created by Алексей Поляков on 08.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Countries)

+ (void)setCountryPostsUpdateNeeded;
+ (void)countryPostsUpdated;
+ (BOOL)countryPostsUpdateNeeded;
+ (void)countryEnabled:(NSString *)countryName;
+ (void)countryDisabled:(NSString *)countryName;
+ (NSArray *)enabledCountries;

@end
