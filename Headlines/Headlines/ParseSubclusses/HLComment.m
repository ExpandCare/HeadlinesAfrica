//
//  HLComment.m
//  Headlines
//
//

#import "HLComment.h"

@implementation HLComment

@dynamic userId;
@dynamic postId;
@dynamic text;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Comment";
}

@end
