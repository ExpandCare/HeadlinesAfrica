//
//  HLCommentsViewController.h
//  Headlines
//
//

#import "HLViewController.h"
#import "HLPost.h"

@interface HLCommentsViewController : HLViewController

@property (strong, nonatomic) NSString *postID;
@property (strong, nonatomic) HLPost *post;

@end
