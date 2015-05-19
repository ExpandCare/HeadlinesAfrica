//
//  AppDelegate.h
//  Headlines
//
//

#import <UIKit/UIKit.h>
#import <Reachability/Reachability.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#define IS_INTERNET_CONNECTED ((AppDelegate *)[[UIApplication sharedApplication] delegate]).isInternetConnected
#define SMALL_BANNER ((AppDelegate *)[[UIApplication sharedApplication] delegate]).smallBanner
#define BIG_BANNER ((AppDelegate *)[[UIApplication sharedApplication] delegate]).bigBanner

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *statusBarWindow;

@property (assign, nonatomic) BOOL isInternetConnected;

@property (strong, nonatomic) GADBannerView *smallBanner;
@property (strong, nonatomic) GADBannerView *bigBanner;

@property (strong, nonatomic, readonly) NSString *articleIdToOpen;
- (void)clearArticleIdToOpen;

- (void)loadBanners;

@end

