//
//  AppDelegate.m
//  Headlines
//
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>
#import "HLWindow.h"
#import <SAMHUDView/SAMHUDView.h>
#import "Post+Additions.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <TestFairy/TestFairy.h>

NSString * const kGoogleAnalyticsKey = @"UA-61736612-2";

//Twitter
NSString * const kTwitterConsumerKey = @"QmspYnu7HSPGVjqxn35si7aCK";
NSString * const kTwitterConsumerSecret = @"gkKWvLpgJvww3IWX3cGWpM8TGVGx8OotKBpWIfOmtRgKUUelS2";

@interface AppDelegate () <UIAlertViewDelegate>

@property (strong, nonatomic, readwrite) NSString *articleIdToOpen;
@property (strong, nonatomic) SAMHUDView *hud;

@end

@implementation AppDelegate
{
    Reachability *theReachability;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //--- reachability pod deploying
    theReachability = [Reachability reachabilityForInternetConnection];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangedInternetConnectionStatus:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.isInternetConnected = ([theReachability currentReachabilityStatus] != NotReachable);
    
    [theReachability startNotifier];
    //---
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
 
    //Push
    [self registerForRemoteNotifications];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey])
    {
        NSLog(@"Push notification: %@", [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]);
        
        NSDictionary *notificationDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [self processPush:notificationDict];
    }
    
    [FBAppEvents activateApp];
    
    [Parse enableLocalDatastore];
    [ParseCrashReporting enable];
    
    // Initialize Parse.
    [Parse setApplicationId:@"7iYJMHDqqHJ2xmIiimYjDSBOeia4IcKz6cUJluqB"
                  clientKey:@"pMRiYDDR4uyWV8o6ZMonubGRxZhBQ6UbCqGIUzIk"];
    
//    // [Optional] Track statistics around application opens.
//    [PFAnalytics trackAppOpenedWithLaunchOptionsInBackground:launchOptions block:^(BOOL succeeded, NSError *PF_NULLABLE_S error){
//        
//        
//    }];
    
    [PFFacebookUtils initializeFacebook];
    
    //Twitter
    [PFTwitterUtils initializeWithConsumerKey:kTwitterConsumerKey
                               consumerSecret:kTwitterConsumerSecret];
    
    
    // Magical Record
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Model"];
    
    [PFQuery clearAllCachedResults];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
//    if (application.applicationState != UIApplicationStateBackground) {
//        // Track an app open here if we launch with a push, unless
//        // "content_available" was used to trigger a background push (introduced
//        // in iOS 7). In that case, we skip tracking here to avoid double
//        // counting the app-open.
//        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
//        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
//        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload)
//        {
//            //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
//        }
//    }
    
#pragma mark - Google Analitics
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsKey];
    
    // Assumes a tracker has already been initialized with a property ID, otherwise
    // getDefaultTracker returns nil.
    //id tracker = [[GAI sharedInstance] defaultTracker];
    
    // Enable Advertising Features.
    tracker.allowIDFACollection = YES;
    
#pragma mark - TestFairy
    
    [TestFairy begin:@"f27b0eb034db2c4a7e184f00b4eb348224bcda07"];
    
    [self loadBanners];
        
    return YES;
}

- (void)registerForRemoteNotifications
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (application.applicationState == UIApplicationStateInactive)
    {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        //[PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    
    //NSLog(@"Push %@", userInfo);
    [self processPush:userInfo];
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//      fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    NSLog(@"Push %@", userInfo);
//    //[self processPush:userInfo];
//    
//    //[PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
//    
//    if (application.applicationState == UIApplicationStateInactive)
//    {
//        //[PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
//    }
//}

- (void)processPush:(NSDictionary*)userInfo
{
    //[PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    
    NSLog(@"%@", userInfo);
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    
    self.articleIdToOpen = userInfo[@"articleId"];
    
    if (state == UIApplicationStateActive)
    {
        dispatch_async(dispatch_get_main_queue(), ^()
        {
            if ([PFUser currentUser])
            {
                if (self.articleIdToOpen)
                {
                    [[[UIAlertView alloc] initWithTitle:@"Push"
                                                message:userInfo[@"aps"][@"alert"]
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Read", nil] show];
                }
            }
        });
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    if (application.applicationState != UIApplicationStateActive)
    {
        return;
    }
    
    NSString *tokenStr = [NSString stringWithFormat:@"%@",deviceToken];
    tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSLog(@"DeviceToken: %@", tokenStr);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

- (void)loadBanners
{
    if (!self.smallBanner)
    {
        self.smallBanner = [[GADBannerView alloc] initWithAdSize:GADAdSizeFullWidthPortraitWithHeight(50)];
        
        self.smallBanner.adUnitID = @"ca-app-pub-7204105635035592/3354045064";
        self.smallBanner.rootViewController = [self window].rootViewController;
        [self.smallBanner loadRequest:[GADRequest request]];
        self.smallBanner.autoloadEnabled = NO;
    }
    
    if (!self.bigBanner)
    {
        self.bigBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLargeBanner];
        
        self.bigBanner.adUnitID = @"ca-app-pub-7204105635035592/3354045064";
        self.bigBanner.rootViewController = [self window].rootViewController;
        [self.bigBanner loadRequest:[GADRequest request]];
        self.bigBanner.autoloadEnabled = NO;
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [PFInstallation currentInstallation].badge = 0;
    //[PFAnalytics trackAppOpenedWithLaunchOptions:nil];
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    //Track the app with parse analytics each time it opens.
    //[PFAnalytics trackAppOpenedWithLaunchOptions:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Reachability

- (void)didChangedInternetConnectionStatus:(NSNotification *)notification
{
    Reachability *reach = [notification object];
    
    self.isInternetConnected = ([reach currentReachabilityStatus] != NotReachable);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [self openArticleWithId:self.articleIdToOpen];
    }
}

- (void)openArticleWithId:(NSString*)articleId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    self.hud = [[SAMHUDView alloc] initWithTitle:@"Opening up an article.." loading:YES];
    [query getObjectInBackgroundWithId:articleId block:^(PFObject *post, NSError *error)
    {
        if (!error)
        {
            [Post createOrUpdatePostsInBackground:@[post] completion:^(BOOL success, NSError *error)
            {
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationOpenPost object:[Post MR_findFirstByAttribute:@"postID" withValue:articleId]]];
                [self.hud completeAndDismissWithTitle:@"Success"];
            }];
        }
        else
        {
            [self.hud failAndDismissWithTitle:@"Fail"];
        }
    }];
}

- (void)clearArticleIdToOpen
{
    self.articleIdToOpen = nil;
}

@end
