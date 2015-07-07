//
//  Comment+Additions.m
//  Headlines
//
//

#import "Comment+Additions.h"
#import "HLComment.h"

@implementation Comment (Additions)

+ (void)createOrUpdateCommentsInBackground:(NSArray *)comments completion:(CommentsUpdatingCompletion)completion
{
    CommentsUpdatingCompletion completionCopy = [completion copy];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        
        for (HLComment *comment in comments)
        {
            Comment *theComment = [Comment MR_findFirstByAttribute:@"commentID" withValue:comment.objectId];
            
            if (!theComment)
            {
                theComment = [Comment MR_createEntityInContext:localContext];
                
                theComment.commentID = comment.objectId;
            }
            
            theComment.text = comment.text;
            theComment.username = comment[kPFUserKeyDisplayName];
            theComment.createdAt = comment.createdAt;
            theComment.postID = comment.postId.objectId;
        }
        
    } completion:^(BOOL success, NSError *error) {
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            
            if (completionCopy)
            {
                completionCopy(success, error);
            }
        }];
    }];
}

@end
