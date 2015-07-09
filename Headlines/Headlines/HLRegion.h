//
//  HLRegion.h
//  Headlines
//
//  Created by Алексей Поляков on 07.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSUserDefaults+Countries.h"

@interface HLRegion : NSObject

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL selected;
@property (strong, nonatomic) NSArray *countries;

+ (HLRegion *)regionWithName:(NSString *)name countries:(NSArray *)countries;

@end
