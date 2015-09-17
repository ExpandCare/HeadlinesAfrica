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
                if([[images firstObject] isKindOfClass:[NSArray class]])
                {
                    thePost.imageURL = [[[[images firstObject] firstObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                else
                {
                    thePost.imageURL = [[[images firstObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                
            }
            
            if ([thePost.imageURL rangeOfString:@"dailyguideghana.com"].location != NSNotFound)
            {
                thePost.imageURL = nil;
            }
            
            if([thePost.source isEqualToString:@"Cameroon Online"])
            {
                if([thePost.category isEqualToString:@"Blogs"])
                {
                    thePost.imageURL = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:@"images-17" ofType:@"jpeg"]];
                }
                else if ([thePost.category isEqualToString:@"Technology"])
                {
                    thePost.imageURL = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:@"images-16" ofType:@"jpeg"]];
                }
                else if ([thePost.category isEqualToString:@"Politics"])
                {
                    thePost.imageURL = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:@"images-18" ofType:@"jpeg"]];
                }
            }
            
            thePost.link = post.link;
        }
        
    } completion:^(BOOL success, NSError *error) {
        
        if (completionCopy)
        {
            completionCopy(success, error);
        }
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
