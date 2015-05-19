//
//  HLLinkedInActivity.m
//  Headlines
//
//

#import "HLLinkedInActivity.h"
#import "HLLoginViewController.h"
#import "HLNavigationController.h"
#import "AppDelegate.h"
#import "HLLinkedInLoginViewController.h"

#define TIME_OUT 20
#define SUCCESS_CODE 201

@interface HLLinkedInActivity () <LinkedInLoginDelegate>

@property (copy, nonatomic) NSArray *items;
@property (strong, nonatomic) UIWindow *window;

@end

@implementation HLLinkedInActivity

- (NSString *)activityType
{
    return @"LinkedIn";
}

- (NSString *)activityTitle
{
    return @"LinkedIn";
}

-(UIImage *)activityImage
{
    return [UIImage imageNamed:@"ic_linkedin"];
}

- (void)performActivity
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kLinkedInToken];
    NSDate *expired = [[NSUserDefaults standardUserDefaults] objectForKey:kLinkedInExpires];
    
    if (!token || [expired timeIntervalSinceDate:[NSDate date]] <= 0)
    {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        //[[[UIApplication sharedApplication].delegate window] addSubview:self.window];
        
        HLLinkedInLoginViewController *loginController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kStoryboardIDLinkedInLoginController];
        
        if (loginController)
        {
            loginController.title = @"LinkedIn";
            
            HLNavigationController *navController = [[HLNavigationController alloc] initWithRootViewController:loginController];
            
            loginController.delegate = self;
            
            self.window.windowLevel = UIWindowLevelNormal;
            self.window.rootViewController = navController;
            [self.window makeKeyAndVisible];
            
            [((AppDelegate *)[UIApplication sharedApplication].delegate).statusBarWindow makeKeyAndVisible];
            
            [navController setBlueColor];
        }
        else
        {
            [self loginFailed];
        }
    }
    else
    {
        [self signedInWithToken:token expired:expired];
    }
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    self.items = activityItems;
}

-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)postMessage:(NSString *)message link:(NSURL *)link description:(NSString *)description imageURL:(NSURL *)imageURL
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kLinkedInToken];
    
    NSMutableDictionary* update = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* visibility = [[NSMutableDictionary alloc] init];
    [visibility setObject:@"anyone"
                   forKey:@"code"];
    [update setObject:visibility
               forKey:@"visibility"];
    
    if (message)
    {
        [update setObject:message
                   forKey:@"comment"];
    }
    if (link)
    {
        NSMutableDictionary * content = [[NSMutableDictionary alloc] init];
        
        if (link)
        {
            [content setObject:[link absoluteString]
                        forKey:@"submittedUrl"];
        }
        if(description)
        {
            [content setObject:description
                        forKey:@"description"];
        }
        if(imageURL)
        {
            [content setObject:[imageURL absoluteString]
                        forKey:@"submittedImageUrl"];
        }
        
        [update setObject:content forKey:@"content"];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"https://api.linkedin.com/v1/people/~/shares?oauth2_access_token=%@", token]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:TIME_OUT];
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    NSString *updateString = nil;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:update
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (!jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }
    else
    {
        updateString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSURLResponse *response = nil;
    [request setHTTPBody:[updateString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSInteger code = [httpResponse statusCode];
    
    if (code == SUCCESS_CODE)
    {
        [super activityDidFinish:YES];
    }
    else
    {
        [super activityDidFinish:NO];
    }
}

#pragma mark - Login

- (void)loginFailed
{
    [super activityDidFinish:NO];
    
    self.window.rootViewController = nil;
    
    [self.window removeFromSuperview];
    self.window = nil;
}

- (void)loginCanceled
{
    [super activityDidFinish:NO];
    
    self.window.rootViewController = nil;
    
    [self.window removeFromSuperview];
    self.window = nil;
}

- (void)signedInWithToken:(NSString *)token expired:(NSDate *)expired
{
    if (self.window)
    {
        self.window.rootViewController = nil;
        
        [self.window removeFromSuperview];
        self.window = nil;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:token
                                              forKey:kLinkedInToken];
    [[NSUserDefaults standardUserDefaults] setObject:expired
                                              forKey:kLinkedInExpires];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *msg = nil;
    NSURL *link = nil;
    NSURL *imgURL = nil;
    
    for (id item in self.items)
    {
        if ([[item class] isSubclassOfClass:[NSString class]])
        {
            msg = item;
        }
        if ([[item class] isSubclassOfClass:[NSURL class]])
        {
            link = item;
        }
    }
    
    [self postMessage:msg
                 link:link
          description:nil
             imageURL:imgURL];
}

@end
