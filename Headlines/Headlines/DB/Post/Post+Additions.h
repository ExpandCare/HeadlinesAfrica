//
//  Post+Additions.h
//  Headlines
//
//

#import "Post.h"
#import <Parse/Parse.h>

typedef void (^PostsUpdatingCompletion)(BOOL success, NSError *error);

@interface Post (Additions)

+ (instancetype)createOrUpdatePostWithPost:(PFObject *)post;
+ (void)createOrUpdatePostsInBackground:(NSArray *)posts completion:(PostsUpdatingCompletion)completion;

@end
