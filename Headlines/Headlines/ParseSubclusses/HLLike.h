//
//  HLLike.h
//  Headlines
//
//

#import <Parse/Parse.h>
#import <Parse/PFSubclassing.h>
#import <Parse/PFObject+Subclass.h>

@interface HLLike : PFObject <PFSubclassing>

@property (nonatomic) PFUser *userId;
@property (nonatomic) PFObject *postId;

@end
