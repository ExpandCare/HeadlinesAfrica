//
//  HLTermsAndPrivacyViewController.m
//  Headlines


#import "HLTermsAndPrivacyViewController.h"
#import "HLNavigationController.h"

@interface HLTermsAndPrivacyViewController()

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation HLTermsAndPrivacyViewController

#pragma mark - Private

- (void)backButtonPressed:(UIButton *)backButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error = nil;
    NSString *path;
    
    
    if(self.currentContentType == HLContentTypePrivacy)
    {
        self.title = @"Privacy Statement";
        path = [[NSBundle mainBundle] pathForResource: @"PrivacyStatement" ofType: @"html"];
    }
    else if (self.currentContentType == HLContentTypeTerms)
    {
        self.title = @"Terms of Service";
        path = [[NSBundle mainBundle] pathForResource: @"TermsOfService" ofType: @"html"];
    }
    else if (self.currentContentType == HLContentTypeAboutUs)
    {
        self.title = @"About Us";
        path = [[NSBundle mainBundle] pathForResource: @"AboutUs" ofType: @"html"];
    }
    
    NSString *res = [NSString stringWithContentsOfFile: path encoding:NSUTF8StringEncoding error: &error];
    [self.webView loadHTMLString:res baseURL:nil];
    
    [self configureBackButtonWhite:NO];
    [((HLNavigationController *)self.navigationController) setWhiteColor];
    
}

@end
