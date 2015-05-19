//
//  Comment+Additions.h
//  Headlines
//
//

#import "Comment.h"
#import <Parse/Parse.h>

typedef void (^CommentsUpdatingCompletion)(BOOL success, NSError *error);

@interface Comment (Additions)

+ (void)createOrUpdateCommentsInBackground:(NSArray *)comments completion:(CommentsUpdatingCompletion)completion;

@end
