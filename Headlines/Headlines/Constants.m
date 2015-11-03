//
//  Constants.m
//  Headlines
//
//

#import "Constants.h"

#pragma mark - StroryboardID's
NSString * const kStoryboardIDNewsController = @"newsControllerID";
NSString * const kStoryboardIDWebController = @"WebViewControllerID";
NSString * const kStoryboardIDLinkedInLoginController = @"LinkedInLoginController";

NSString * const kContactCellIdentifier = @"contactCellIdentifier";

#pragma mark - LinkedIn
NSString * const kLinkedInApiKey = @"78rm1g6m4y4m4i";
NSString * const kLinkedInSecret = @"WQlGcdtunKEOlyIJ";
NSString * const kLinkedInToken = @"kLinkedInToken";
NSString * const kLinkedInExpires = @"kLinkedInExpires";

#pragma mark - PFUser
NSString * const kPFUserKeyDisplayName = @"displayName";

#pragma mark - HLPost
NSString * const kHLPostSharesCountKey = @"sharesCount";
NSString * const kHLPostLikesCountKey = @"likesCount";
NSString * const kHLPostCommentsCountKey = @"commentsCount";

#pragma mark - Notification
NSString * const kNotificationDoubleTap = @"kNotificationDoubleTap";
NSString * const kNotificationDownloadedPosts = @"kNotificationDownloadedPosts";
NSString * const kNotificationOpenPost = @"kNotificationOpenPost";
NSString * const kNotificationFilterChanged = @"kNotificationFilterChanged";

#pragma mark - Defaults
NSString * const kDefaultsUserKeyPassword = @"kPFUserKeyPassword";
NSString * const kDefaultsNeedToUpdate = @"kNeedToUpdate";
NSString * const kDefaultsEnabledCountries = @"kDefaultsEnabledCountries";

#pragma mark - Static Images

NSString * const kCamerronOnlineBlogsStaticImage = @"cameroonOnlineBlogs.jpg";
NSString * const kCamerronOnlineTechStaticImage = @"cameroonOnlineTech.jpg";
NSString * const kCamerronOnlinePoliticsStaticImage = @"cameroonOnlinePolitics.jpg";

#ifdef DEVTARGET
NSString * const kParseAppID                            = @"p8rrpMQXg6sEysabNDfbfRxaPmpzFrrBRO3TaWoH";
NSString * const kParseClientKey                        = @"ZClqTF0b2sFxsIB5ZopM8Z6vI3cqvZg0KyHoyIwT";

//Twitter
NSString * const kTwitterConsumerKey = @"Ht4cBklqQAbVb2JlDy7ih3tFn";
NSString * const kTwitterConsumerSecret = @"DPTwWFf3jh6LKuiuWelxcyP1bexmyUDG83Wpglvoi9FevSuIGx";

#elif PRODTARGET
NSString * const kParseAppID                            = @"7iYJMHDqqHJ2xmIiimYjDSBOeia4IcKz6cUJluqB";
NSString * const kParseClientKey                        = @"pMRiYDDR4uyWV8o6ZMonubGRxZhBQ6UbCqGIUzIk";

//Twitter
NSString * const kTwitterConsumerKey = @"QmspYnu7HSPGVjqxn35si7aCK";
NSString * const kTwitterConsumerSecret = @"gkKWvLpgJvww3IWX3cGWpM8TGVGx8OotKBpWIfOmtRgKUUelS2";

#endif

#pragma mark - Google AdMob

NSString * const kGoogleAdMob50pxHeightBannerId  = @"ca-app-pub-7204105635035592/3354045064";
NSString * const kGoogleAdMob100pxHeightBannerId = @"ca-app-pub-7204105635035592/3434770265";
NSString * const kGoogleAdMob250pxHeightBannerId = @"";
