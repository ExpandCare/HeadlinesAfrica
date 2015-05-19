//
//  HLLike.m
//  Headlines
//
//

#import "HLLike.h"

@implementation HLLike

@dynamic userId;
@dynamic postId;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Like";
}

@end
