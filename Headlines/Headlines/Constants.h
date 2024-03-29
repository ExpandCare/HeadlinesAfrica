//
//  Constants.h
//  Headlines
//
//

#import <Foundation/Foundation.h>

#define HEADLINES_BLUE [UIColor colorWithRed:0.02 green:0.62 blue:0.85 alpha:1]
#define HEADLINES_FONT @"HelveticaNeue-CondensedBold"

#define BANNER_INDEX_PADDING 20 + BIG_BANNER_CELL_INDEX

#define IS_SMALL_BANNER_INDEX(x) (x%35 == SMALL_BANNER_CELL_INDEX || x == SMALL_BANNER_CELL_INDEX)
#define IS_BIG_BANNER_INDEX(x) (x%35 == BIG_BANNER_CELL_INDEX || x == BIG_BANNER_CELL_INDEX)

#define SMALL_BANNER_CELL_INDEX 3
#define BIG_BANNER_CELL_INDEX 15
#define BANNER_HEIGHT 50
#define BIG_BANNER_HEIGHT 100

#pragma mark - Storyboard IS's
extern NSString * const kStoryboardIDNewsController;
extern NSString * const kStoryboardIDWebController;
extern NSString * const kStoryboardIDLinkedInLoginController;

#pragma mark - LinkedIn
extern NSString * const kLinkedInApiKey;
extern NSString * const kLinkedInSecret;
extern NSString * const kLinkedInToken;
extern NSString * const kLinkedInExpires;

#pragma mark - PFUser
extern NSString * const kPFUserKeyDisplayName;

#pragma mark - HLPost
extern NSString * const kHLPostSharesCountKey;
extern NSString * const kHLPostLikesCountKey;
extern NSString * const kHLPostCommentsCountKey;

#pragma mark - Notification
extern NSString * const kNotificationDoubleTap;
extern NSString * const kNotificationDownloadedPosts;
extern NSString * const kNotificationOpenPost;

#pragma mark - Defaults
extern NSString * const kDefaultsUserKeyPassword;
