//
//  HLWebViewController.m
//  Headlines
//
//

#import "HLWebViewController.h"

@interface HLWebViewController () <UIWebViewDelegate>

@end

@implementation HLWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureBackButtonWhite:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

#pragma mark - WebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.title = webView.request.mainDocumentURL.host;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Actions

- (void)backButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
