//
//  HLPostDetailViewController.m
//  Headlines
//
//

#import "HLPostDetailViewController.h"
#import "HLNavigationController.h"
#import "HLLinkedInActivity.h"
#import "HLWebViewController.h"
#import "HLWhatsAppActivity.h"
#import "NSString+URLEncoding.h"
#import "NSObject+Celullar.h"
#import "NSDate+Extentions.h"
#import "UIFont+Consended.h"
#import "HLComment.h"
#import "HLPost.h"
#import "HLCommentsViewController.h"
#import "Post+Additions.h"
#import "HLLike.h"
#import "NSString+HTMLAdditions.h"
#import <SAMHUDView/SAMHUDView.h>

#define IMG_MARKER @"^||^"

#define FONT_SIZE_MIN 100
#define FONT_SIZE_DIFF 50

@interface HLPostDetailViewController () <UIWebViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *sharesCountLabel;

@property (strong, nonatomic) NSLayoutConstraint *firstBannerTopConstraint;
@property (strong, nonatomic) SAMHUDView *hud;

@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) HLPost *parsePost;

@property (nonatomic) BOOL isLiked;
@property (assign, nonatomic) BOOL isLiking;

@end

@implementation HLPostDetailViewController
{
    NSURL *urlToCall;
    
    NSInteger sharesCount;
    NSInteger likesCount;
    
    NSInteger commentsCount;
}

- (void)setParsePost:(HLPost *)parsePost
{
    _parsePost = parsePost;
    
    sharesCount = self.parsePost.sharesCount.integerValue;
    self.post.sharesCount = [NSNumber numberWithInteger:sharesCount];
    
    [self.webView.scrollView setShowsHorizontalScrollIndicator:NO];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
        
    }];
    
    [self configureBottomView];
}

- (void)setPostID:(NSString *)postID
{
    self.post = [Post MR_findFirstByAttribute:@"postID" withValue:postID];
    
    if (!self.post)
    {
        
    }
    else
    {
        commentsCount = [self.post.commentsCount integerValue];
        sharesCount = [self.post.sharesCount integerValue];
        likesCount = [self.post.likesCount integerValue];
        
        [self configureBottomView];
        
        if ([self.post.likedBy isEqualToString:[PFUser currentUser].objectId])
        {
            self.isLiked = YES;
        }
        
        self.title = self.post.category ? self.post.category : self.post.source;
        
        PFQuery *postQuery = [PFQuery queryWithClassName:NSStringFromClass([Post class]) predicate:[NSPredicate predicateWithFormat:@"objectId == %@", self.post.postID]];
        postQuery.limit = 1;
        
        __weak typeof(self) controller = self;
        [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            controller.parsePost = [[postQuery findObjects] lastObject];
            [controller getCounters];
        }];

        
        [self configureBottomView];
        
        [self loadPost];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!SMALL_BANNER || !BIG_BANNER)
    {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) loadBanners];
    }
    
    [self configureBackButtonWhite:YES];
    
    self.webView.scrollView.contentInset = self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.webView.scrollView.contentInset.top, 0, CGRectGetHeight(self.toolBarView.frame), 0);
    
    [((HLNavigationController *)self.navigationController) setBlueColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.commentsButton.enabled = YES;
    
    if (self.post)
    {
        [self loadPost];
        
        if ([self.post.likedBy isEqualToString:[PFUser currentUser].objectId])
        {
            self.isLiked = YES;
            
            [self configureBottomView];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doubleTap)
                                                 name:kNotificationDoubleTap
                                               object:nil];
    
    self.webView.scalesPageToFit = NO;
    self.webView.delegate = self;
    [self.webView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)]];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        int fontSize = 100;
//        NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", fontSize];
//        [self.webView stringByEvaluatingJavaScriptFromString:jsString];
//    });
    
    [self checkIsLiked];
    [self getCounters];
    
    [self configureBottomView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self moveAdBaner]
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.webView.delegate = nil;
    [self.webView stopLoading];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkIsLiked
{
    NSString *postIdentifier = self.parsePost.postID;
    
    if (!postIdentifier.length)
    {
        postIdentifier = self.post.postID;
    }
    
    NSDictionary *params = @{@"userId": [PFUser currentUser].objectId,
                             @"postId": postIdentifier};
    
    __weak typeof(self) controller = self;
    [PFCloud callFunctionInBackground:@"isLiked" withParameters:params block:^(id object, NSError *error) {
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        controller.isLiked = [object boolValue];
        
        if (controller.isLiked && ![controller.post.likedBy isEqualToString:[PFUser currentUser].objectId])
        {
            controller.post.likedBy = [PFUser currentUser].objectId;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        else if (!controller.isLiked && [controller.post.likedBy isEqualToString:[PFUser currentUser].objectId])
        {
            controller.post.likedBy = nil;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        
        [controller configureBottomView];
        NSLog(@"%@", object);
    }];
}

- (void)getCounters
{
    __weak typeof(self) controller = self;
    
    sharesCount = self.parsePost.sharesCount.integerValue;
    self.post.sharesCount = [NSNumber numberWithInteger:sharesCount];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
        [controller configureBottomView];
    }];
    
    NSDictionary *commentsParams = @{@"postId": self.post.postID};
    
    [PFCloud callFunctionInBackground:@"getCommentCount" withParameters:commentsParams block:^(id object, NSError *error)
     {
         commentsCount = [object integerValue];
         controller.post.commentsCount = [NSNumber numberWithInteger:commentsCount];
         
         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
             
             [controller configureBottomView];
         }];
     }];
    
    NSDictionary *params = @{@"postId": self.post.postID};
    
    [PFCloud callFunctionInBackground:@"getLikeCount" withParameters:params block:^(id object, NSError *error)
     {
         likesCount = [object integerValue];
         controller.post.likesCount = [NSNumber numberWithInteger:likesCount];
         
         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
             
             self.likeButton.enabled = YES;
             //[controller configureBottomView];
         }];
     }];
    
    [self checkIsLiked];
}

- (void)configureBottomView
{
    self.likeButton.selected = self.isLiked;
    
    self.sharesCountLabel.text = [NSString stringWithFormat:@"%li", (long)sharesCount];
    self.commentsCountLabel.text = [NSString stringWithFormat:@"%li", (long)commentsCount];
    self.likesCountLabel.text = [NSString stringWithFormat:@"%li", (long)likesCount];
}

- (void)addBannerToWebView
{
    for (UIView *view in self.webView.scrollView.subviews)
    {
        if (![view isKindOfClass:[UIImageView class]])
        {
            if (BIG_BANNER.superview == self.webView.scrollView)
            {
                return;
            }
            
            //CGRect frame = view.frame;
            //frame.origin.y += 60;
            //frame.size.height += 60;
            //view.frame = frame;
            
            [self.webView.scrollView addSubview:BIG_BANNER];
         
            [self addBanner:BIG_BANNER
                toSuperView:self.webView.scrollView
                contentView:view
                     bottom:YES];
            [self addBanner:SMALL_BANNER
                toSuperView:self.webView.scrollView
                contentView:view
                     bottom:NO];
            
            [view.superview layoutIfNeeded];
        }
    }
    
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(60, 0, 60 + BIG_BANNER_HEIGHT, 0);
}

- (void)addBanner:(GADBannerView *)banner toSuperView:(UIView *)parentView contentView:(UIView *)contentView bottom:(BOOL)bottom
{
    [parentView addSubview:banner];
    
    banner.translatesAutoresizingMaskIntoConstraints = NO;
    
    [banner addConstraint:[NSLayoutConstraint constraintWithItem:banner
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1
                                                        constant:CGRectGetHeight(banner.frame)]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:banner
                                                           attribute:NSLayoutAttributeLeft
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:contentView
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1
                                                            constant:0]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:banner
                                                           attribute:NSLayoutAttributeRight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:contentView
                                                           attribute:NSLayoutAttributeRight
                                                          multiplier:1
                                                            constant:0]];
    
    if (bottom)
    {
        [parentView addConstraint:[NSLayoutConstraint constraintWithItem:banner
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:contentView
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1
                                                                constant:0]];
    }
    else
    {
        self.firstBannerTopConstraint = [NSLayoutConstraint constraintWithItem:banner
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:contentView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:-50];
        
        [parentView addConstraint:self.firstBannerTopConstraint];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

- (void)doubleTap
{
    __weak typeof(self) controller = self;
    [UIView animateWithDuration:0.2 animations:^{
        
        controller.webView.scrollView.contentOffset = CGPointMake(0, -controller.webView.scrollView.contentInset.top);
    }];
}

#pragma mark - Recognizer

- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
    static CGFloat fontSize;
    static CGFloat scale;
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        scale = recognizer.scale;
    }
    else
    {
        CGFloat theDiff = recognizer.scale - scale;
        if (theDiff < 0)
        {
            theDiff = theDiff * (-1);
        }
        NSLog(@"diff: %f, %f, %f", theDiff, recognizer.scale, scale);
        
        if (theDiff > 0.1)
        {
            fontSize += (recognizer.scale - scale > 0) ? 10 : -10;
            scale = recognizer.scale;
            
            if (fontSize < FONT_SIZE_MIN)
            {
                fontSize = FONT_SIZE_MIN;
            }
            if (fontSize > (FONT_SIZE_MIN + FONT_SIZE_DIFF))
            {
                fontSize = (FONT_SIZE_MIN + FONT_SIZE_DIFF);
            }
            
            NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%f%%'", fontSize];
            [self.webView stringByEvaluatingJavaScriptFromString:jsString];
 
            [self moveAdBaner];
            
            NSLog(@"FontSize: %f", fontSize);
        }
    }
    
    //NSLog(@"%f", recognizer.scale);
}

- (void)moveAdBaner
{
    NSString *js = @"function f(){ var r = document.getElementById('%@').getBoundingClientRect(); return '{{'+r.left+','+r.top+'},{'+r.width+','+r.height+'}}'; } f();";
    NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:js, @"slsElement"]];
    CGRect rect = CGRectFromString(result);
    
    NSLog(@"%@", result);
    
    //bannerView2.frame = CGRectMake(0,rect.origin.y, CGRectGetWidth(self.view.bounds), BANNER_HEIGHT);
    self.firstBannerTopConstraint.constant = rect.origin.y + self.webView.scrollView.contentOffset.y + self.webView.scrollView.contentInset.top;

    [SMALL_BANNER.superview layoutIfNeeded];
}

- (CGFloat)sizeForScale:(CGFloat)scale
{
    return scale * (FONT_SIZE_MIN + FONT_SIZE_DIFF);
}

- (void)loadPost
{
    if (!self.post.content)
    {
        return;
    }
    
    NSString *contentString = self.post.content;
    
    NSString *html = [contentString htmlStringWithTitle:self.post.title
                                                 author:self.post.author
                                                 source:self.post.source
                                                country:self.post.country
                                                   date:[self.post.createdAt formattedString]
                                               imageURL:self.post.imageURL];
    
    [self.webView loadHTMLString:html baseURL:nil];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (urlToCall)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            [[UIApplication sharedApplication] openURL:urlToCall];
            urlToCall = nil;
        }
        
        return;
    }
}

#pragma mark - Webview

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString rangeOfString:@"itunes.apple.com"].location != NSNotFound ||
        [request.URL.host isEqualToString:@"appstore.com"] ||
        [request.URL.scheme isEqualToString:@"sms"] ||
        [request.URL.scheme isEqualToString:@"mailto"])
    {
        
        NSString *urlString = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"mailto:" withString:@"mailto:?to="];
        
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
        
        return NO;
    }
    if ([request.URL.scheme isEqualToString:@"tel"])
    {
        if (![NSObject hasCellular])
        {
            if([[UIApplication sharedApplication] canOpenURL:request.URL])
            {
                [[UIApplication sharedApplication] openURL:request.URL];
            }
            
            return NO;
        }
        
        urlToCall = request.URL;
        [[[UIAlertView alloc] initWithTitle:[[urlToCall.absoluteString encodedString] stringByReplacingOccurrencesOfString:@"tel:" withString:@""]
                                    message:nil
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Call", nil] show];
        return NO;
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSLog(@"Clecked");
        
        [self openWebViewWithUrl:request.URL];
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self addBannerToWebView];
    [self moveAdBaner];
}

#pragma mark - Actions

- (IBAction)commentsButtonPressed:(id)sender
{
    if (!IS_INTERNET_CONNECTED)
    {
        [[[UIAlertView alloc] initWithTitle:@"Failed"
                                    message:@"Connect to the Internet"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    self.commentsButton.enabled = NO;
    
    [self performSegueWithIdentifier:@"toCommentsScreen" sender:self];
    
    //[self openWebViewWithUrl:[NSURL URLWithString:@"http://google.com"]];
}

- (IBAction)likeButtonPressed:(UIButton *)sender
{
    if (!sender.enabled) return;
    if (!IS_INTERNET_CONNECTED)
    {
        [[[UIAlertView alloc] initWithTitle:@"Failed"
                                    message:@"Connect to the Internet"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    self.isLiking = NO;
    
    if (self.isLiking)
    {
        return;
    }
    
    self.isLiking = YES;
    
    __weak typeof(sender) button = sender;
    __weak typeof(self) controller = self;
    
    if (sender.selected)
    {
        //self.hud = [[SAMHUDView alloc] initWithTitle:@"Disliking.." loading:YES];
        self.likeButton.selected = NO;
        likesCount--;
        self.isLiked = NO;
//        
        self.post.likedBy = nil;
        self.post.likesCount = [NSNumber numberWithInteger:likesCount];
        
        [self configureBottomView];
        
        NSDictionary *params = @{@"userId": [PFUser currentUser].objectId,
                                 @"postId": self.post.postID};
        
        //[self.hud show];
        
        sender.userInteractionEnabled = NO;
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error)
        {
            [PFCloud callFunctionInBackground:@"unlike" withParameters:params block:^(id object, NSError *error)
            {
                controller.isLiking = NO;
//                likesCount --;
                button.userInteractionEnabled = YES;
                
                //[controller getCounters];
                //[self.hud completeAndDismissWithTitle:nil];
            }];
        }];
    }
    else
    {
        //self.hud = [[SAMHUDView alloc] initWithTitle:@"Liking.." loading:YES];
        //[self.hud show];
        
        self.likeButton.selected = YES;
        likesCount++;
        self.isLiked = YES;
        
        self.post.likedBy = [PFUser currentUser].objectId;;
        self.post.likesCount = [NSNumber numberWithInteger:likesCount];
        
        [self configureBottomView];
        
        NSDictionary *params = @{@"userId": [PFUser currentUser].objectId,
                                 @"postId": self.post.postID};
        
        
        sender.userInteractionEnabled = NO;
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error)
         {
             [PFCloud callFunctionInBackground:@"like" withParameters:params block:^(id object, NSError *error)
              {
                  controller.isLiking = NO;
                  //likesCount++;
                  button.userInteractionEnabled = YES;
                  
                  //[controller getCounters];
                  //[self.hud completeAndDismissWithTitle:nil];
              }];
         }];
        
//        self.hud = [[SAMHUDView alloc] initWithTitle:@"Liking.." loading:YES];
//        HLLike *like = [HLLike new];
//        like.userId = [PFUser currentUser];
//        like.postId = self.parsePost;
//        
//        self.likeButton.selected = YES;
//        likesCount++;
//        self.isLiked = YES;
//        
//        self.post.likedBy = [PFUser currentUser].objectId;
//        self.post.likesCount = [NSNumber numberWithInteger:likesCount];
//        
//        [self configureBottomView];
//        
//        [self.hud show];
//        
//        [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//        {
//            if (succeeded)
//            {
//                PFRelation *relation = [self.parsePost relationForKey:@"likes"];
//                [relation addObject:like];
//                
//                [controller.parsePost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//                {
//                    [controller getCounters];
//                    [self.hud completeAndDismissWithTitle:nil];
//                }];
//            }
//            else
//            {
//                button.enabled = YES;
//                [self.hud failAndDismissWithTitle:nil];
//            }
//        }];
    }
}

- (IBAction)shareButtonPressed:(id)sender
{
    HLLinkedInActivity *linkedInActivity = [HLLinkedInActivity new];
    HLWhatsAppActivity *whatsAppActivity = [HLWhatsAppActivity new];
    
    NSString *shareMessage = [NSString stringWithFormat:@"Sent from Headlines Africa app:\n\n%@\n\n", self.post.title];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[shareMessage, [NSURL URLWithString:self.post.link]] applicationActivities:@[linkedInActivity, whatsAppActivity]];
    
    __weak HLPostDetailViewController *controller = self;
    if ([UIDevice currentDevice].systemVersion.doubleValue < 8)
    {
        [activityController setCompletionHandler:^(NSString *activityType, BOOL completed){
            
            if (completed)
            {
                [controller incrementShares];
            }
            
            if ([activityType isEqualToString:LinkedInActivityName])
            {
            }
        }];
    }
    else
    {
        [activityController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
            
            if (completed)
            {
                [controller incrementShares];
            }
            
            if ([activityType isEqualToString:LinkedInActivityName])
            {
            }
        }];
    }
    
    [self presentViewController:activityController
                       animated:YES
                     completion:nil];
}

- (void)backButtonPressed:(UIButton *)sender
{
    [_webView stopLoading];
    _webView.delegate = nil;
    
    if(self.isSearchPost)
    {
       [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
       [self.navigationController dismissViewControllerAnimated:NO completion:NULL];
    }
    
}

- (void)incrementShares
{
    PFQuery *postQuery = [PFQuery queryWithClassName:NSStringFromClass([Post class]) predicate:[NSPredicate predicateWithFormat:@"objectId == %@", self.post.postID]];
    postQuery.limit = 1;
    
    sharesCount++;
    
    [self configureBottomView];
    
    self.post.sharesCount = [NSNumber numberWithInteger:sharesCount];
    
    [self configureBottomView];
    
    [self.parsePost incrementKey:kHLPostSharesCountKey];
    [self.parsePost saveInBackground];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
        
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toLinkedInLoginController"])
    {
        //HLLinkedInLoginViewController *loginController = segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:@"toCommentsScreen"])
    {
        HLCommentsViewController *controller = segue.destinationViewController;
        controller.postID = self.post.postID;
        controller.post = self.parsePost;
    }
}

- (void)openWebViewWithUrl:(NSURL *)url
{
    HLWebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDWebController];
    
    if (controller)
    {
        controller.url = url;
        controller.title = url.host;
        
        [self.navigationController pushViewController:controller animated:NO];
    }
}

@end
