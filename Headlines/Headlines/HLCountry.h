//
//  HLCountry.h
//  Headlines
//
//  Created by Алексей Поляков on 07.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLRegion.h"

@interface HLCountry : NSObject

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL selected;
@property (strong, nonatomic) HLRegion *region;

+ (HLCountry *)countryWithName:(NSString *)name;
+ (NSArray *)countriesWithNames:(NSArray *)names;

@end
