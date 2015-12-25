//
//  HLPost.m
//  Headlines
//
//

#import "HLPost.h"

@implementation HLPost

@dynamic author;
@dynamic category;
@dynamic content;
@dynamic country;
@dynamic createdAt;
@dynamic imageURL;
@dynamic link;
@dynamic postID;
@dynamic title;
@dynamic titleImage;
@dynamic updatedAt;
@dynamic url;
@dynamic source;
@dynamic sharesCount;
@dynamic likesCount;
@dynamic commentsCount;
@dynamic thumb;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Post";
}

@end
