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
#define RECTANGLE_BANNER ((AppDelegate *)[[UIApplication sharedApplication] delegate]).rectangleBanner
#define SHOW_INTERNET_FAILED_ALERT [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Connection failed", nil) message: NSLocalizedString(@"Please check your internet connection or try again later.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
#define SHOW_ALERT_WITH_TITLE_AND_MESSAGE(alertTitle, alertMessage)  [[[UIAlertView alloc] initWithTitle: alertTitle message: alertMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *statusBarWindow;

@property (assign, nonatomic) BOOL isInternetConnected;

@property (strong, nonatomic) GADBannerView *smallBanner;
@property (strong, nonatomic) GADBannerView *bigBanner;
@property (strong, nonatomic) GADBannerView *rectangleBanner;

@property (strong, nonatomic, readonly) NSString *articleIdToOpen;
- (void)clearArticleIdToOpen;

- (void)loadBanners;

@end

