//
//  HLLinkedInLoginViewController.m
//  Headlines
//
//

#import "HLLinkedInLoginViewController.h"
#import <KissXML/DDXML.h>
#import "Constants.h"

static NSString * scope = @"w_share%20r_basicprofile";
static NSString * redirectUri = @"http://www.headlines.com";

@interface HLLinkedInLoginViewController () <UIWebViewDelegate>

@end

@implementation HLLinkedInLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureBackButtonWhite:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    self.webView.delegate = self;
    
    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *inCookiesApi = [cookies cookiesForURL:[NSURL URLWithString:@"https://www.linkedin.com"]];
    
    for(NSHTTPCookie* cookie in inCookiesApi)
    {
        [cookies deleteCookie:cookie];
    }
    
    NSString *inAuthorizeURL = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=%@&scope=%@&state=LFEEFWF45KJGsdffef151&redirect_uri=%@", kLinkedInApiKey, scope, redirectUri];
    NSURL *url = [NSURL URLWithString:inAuthorizeURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - WebView

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    __weak HLLinkedInLoginViewController *controller = self;
    
    NSString *requestPath = [[request URL] absoluteString];
    if ([requestPath rangeOfString:redirectUri].location != NSNotFound && [requestPath rangeOfString:@"code="].location != NSNotFound)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString* code = [self stringBetweenString:@"code=" andString:@"&" innerString:requestPath];
            NSMutableURLRequest *requestToken = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/accessToken?grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@", code, redirectUri, kLinkedInApiKey,kLinkedInSecret]]];
            NSError *error = nil; NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:requestToken returningResponse:&response error:&error];
            
            if(data)
            {
                NSError* error = nil;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:kNilOptions
                                      error:&error];
                NSString* token = [json objectForKey:@"access_token"];
                NSString* expired_in = [json objectForKey:@"expires_in"];
                
                NSDate *today = [NSDate date];
                NSDate *expireDate = [today dateByAddingTimeInterval:[expired_in intValue]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (controller.delegate)
                    {
                        [controller.delegate signedInWithToken:token
                                                       expired:expireDate];
                    }
                });
                
//                NSDictionary* user = [self getUserInfoWithToken:token];
//                
//                if(user)
//                {
//                    NSString* userID = [user objectForKey:@"id"];
//                    NSString* name = [user objectForKey:@"name"];
//                    NSString* photoURL = [user objectForKey:@"photo"];
//                    
//                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (controller.delegate)
                    {
                        [controller.delegate loginFailed];
                    }
                });
            }
        });
    }
    else if([requestPath rangeOfString:@"the+user+denied+your+request"].location != NSNotFound)
    {
        if (self.delegate)
        {
            [self.delegate loginCanceled];
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Instruments
                       
- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end innerString:(NSString*)str
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if([scanner scanString:start intoString:NULL])
    {
        NSString *result = nil;
        
        if([scanner scanUpToString:end intoString:&result])
        {
            return result;
        }
    }
    
    return nil;
}

-(NSDictionary*)getUserInfoWithToken:(NSString*)token
{
    NSMutableURLRequest *userRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.linkedin.com/v1/people/~:(first-name,last-name,picture-url,id)?oauth2_access_token=%@",token]]];
    
    NSError *error = nil; NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:userRequest returningResponse:&response error:&error];
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    
    if(data)
    {
        DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
        DDXMLElement *rootElement = xmlDocument.rootElement;
        DDXMLElement* userIDElement = [[rootElement elementsForName:@"id"] objectAtIndex:0];
        NSString* userID = [userIDElement stringValue];
        DDXMLElement* firstNameElement = [[rootElement elementsForName:@"first-name"] objectAtIndex:0];
        NSString* firstName = [firstNameElement stringValue];
        DDXMLElement* lastNameElement = [[rootElement elementsForName:@"last-name"] objectAtIndex:0];
        NSString* lastName = [lastNameElement stringValue];
        NSString* name = nil;
        if(firstName)
        {
            if(firstName.length>0)
            {
                name = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
            }
            else
            {
                name = [NSString stringWithFormat:@"%@",lastName];
            }
        }
        else
        {
            name = [NSString stringWithFormat:@"%@",lastName];
        }
        
        NSArray* photoURLElementsArray = [rootElement elementsForName:@"picture-url"]; //check if image-url exist
        NSString* photoURL = nil;
        if(photoURLElementsArray)
        {
            DDXMLElement* photoURLElement = [photoURLElementsArray lastObject];
            photoURL = [photoURLElement stringValue];
        }
        if (userID)
            [result setObject:userID forKey:@"id"];
        if(name)
            [result setObject:name forKey:@"name"];
        if(photoURL)
            [result setObject:photoURL forKey:@"photo"];
    }
    return result;
}

#pragma mark - Actions

- (void)backButtonPressed:(UIButton *)sender
{
    if (self.delegate)
    {
        [self.delegate loginCanceled];
    }
}

@end