//
//  HLLinkedInLoginViewController.h
//  Headlines
//
//

#import "HLViewController.h"

@protocol LinkedInLoginDelegate <NSObject>

- (void)signedInWithToken:(NSString *)token expired:(NSDate *)expired;
- (void)loginCanceled;
- (void)loginFailed;

@end

@interface HLLinkedInLoginViewController : HLViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) id <LinkedInLoginDelegate> delegate;

@end
