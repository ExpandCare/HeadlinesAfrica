//
//  HLComment.h
//  Headlines
//
//

#import <Parse/Parse.h>
#import <Parse/PFSubclassing.h>
#import <Parse/PFObject+Subclass.h>

@interface HLComment : PFObject <PFSubclassing>

@property (nonatomic) PFUser *userId;
@property (nonatomic) PFObject *postId;
@property (nonatomic) NSString *text;

@end
