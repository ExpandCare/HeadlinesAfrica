//
//  HLWebViewController.h
//  Headlines
//
//

#import "HLViewController.h"

@interface HLWebViewController : HLViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NSURL *url;

@end
