//
//  Post+Additions.m
//  Headlines
//
//

#import "Post+Additions.h"
#import "HLPost.h"

@implementation Post (Additions)

+ (instancetype)createOrUpdatePostWithPost:(PFObject *)post
{
    Post *thePost = [Post MR_findFirstByAttribute:@"postID" withValue:post.objectId];
    
    if (!thePost)
    {
        thePost = [Post MR_createEntity];
        
        thePost.postID = post.objectId;
    }
    
    thePost.title = post[@"title"];
    thePost.author = post[@"author"];
    
    NSArray *images = post[@"image"];
    if (images.count)
    {
        thePost.imageURL = [images firstObject];
    }
    
    thePost.link = post[@"link"];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    return thePost;
}

+ (void)createOrUpdatePostsInBackground:(NSArray *)posts completion:(PostsUpdatingCompletion)completion
{
    PostsUpdatingCompletion completionCopy = [completion copy];
    
    posts = [Post filterOutDuplicatePosts:posts];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        
        for (HLPost *post in posts)
        {
            if (!post.content.length)
            {
                continue;
            }
            
            Post *thePost = [Post MR_findFirstByAttribute:@"postID" withValue:post.objectId];
            
            if (!thePost)
            {
                thePost = [Post MR_findFirstByAttribute:@"title" withValue:post.title];
                
                if(!thePost)
                {
                    thePost = [Post MR_createEntityInContext:localContext];
                    
                    thePost.postID = post.objectId;
                }
                else
                {
                    continue;
                }
            }
            
            thePost.title = post.title;
            thePost.author = post.author;
            thePost.country = post.country.length ? post.country : @"Nigeria";
            thePost.source = post.source;
            thePost.createdAt = post.createdAt;
            thePost.content = post.content;
            thePost.category = post.category;
            thePost.sharesCount = post.sharesCount;
            
            NSArray *images = post[@"image"];
            
            if (images.count)
            {
                thePost.imageURL = [[[images firstObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            
            thePost.link = post.link;
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

+ (NSArray *)filterOutDuplicatePosts:(NSArray *)unFilteredArray
{
    NSMutableArray *filteredArrayOfObjects = [[NSMutableArray alloc] init];
    
    for (HLPost *post in unFilteredArray)
    {
        if(!([[filteredArrayOfObjects valueForKeyPath:@"title"] containsObject:post.title]))
        {
            [filteredArrayOfObjects addObject:post];
        }
    }
    return filteredArrayOfObjects;
}

@end
