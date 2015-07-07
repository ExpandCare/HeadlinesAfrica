//
//  HLPostDetailViewController.h
//  Headlines
//
//

#import "HLViewController.h"
#import "Post+Additions.h"

@interface HLPostDetailViewController : HLViewController

@property (strong, nonatomic) NSString *postID;
@property (assign, nonatomic) BOOL isSearchPost;

@end
