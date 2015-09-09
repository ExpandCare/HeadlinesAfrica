//
//  HLStartViewController.m
//  Headlines
//
//

#import "HLStartViewController.h"
#import "HLStatusBarView.h"
#import "UIFont+Consended.h"
#import <Parse/Parse.h>

@interface HLStartViewController ()

@property (weak, nonatomic) IBOutlet UIButton *gettingStartedButton;
@property (weak, nonatomic) IBOutlet UIButton *loginHereButton;
@property (weak, nonatomic) IBOutlet UILabel *haveAnAccountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *viewforGradient;

@end

@implementation HLStartViewController
{
    HLStatusBarView *statusBarView;
    CAGradientLayer *gradientLayer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.image = [UIImage imageNamed:@"newBackground"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.gettingStartedButton.layer.borderColor = self.gettingStartedButton.titleLabel.textColor.CGColor;
    self.gettingStartedButton.layer.borderWidth = 2;
    
    [self.gettingStartedButton.titleLabel setFont:[UIFont mediumConsendedWithSize:20]];
    //[self.gettingStartedButton setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, -3, 0)];
    
    self.haveAnAccountLabel.font = [UIFont consendedWithSize:15];
    //[self.haveAnAccountLabel setTextColor:[UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1]];
    self.loginHereButton.titleLabel.font = [UIFont consendedWithSize:19];
    
//    if (!gradientLayer)
//    {
//        self.viewforGradient.backgroundColor = [UIColor clearColor];
//        gradientLayer = [CAGradientLayer layer];
//        gradientLayer.frame = self.view.bounds;
//        gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7] CGColor], nil];
//        
//        [self.viewforGradient.layer insertSublayer:gradientLayer atIndex:0];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    statusBarView = [HLStatusBarView new];
    [self.view addSubview:statusBarView];
    [statusBarView present];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if ([PFUser currentUser].isAuthenticated)
        {
            [self performSegueWithIdentifier:@"toNewsController" sender:self];
        }
    });
}

#pragma mark - Actions

- (IBAction)loginPressed:(id)sender
{
    [self performSegueWithIdentifier:@"toLoginController" sender:self];
}

- (IBAction)gettingStartedPressed:(id)sender
{
    [self performSegueWithIdentifier:@"toRegistrationController" sender:self];
}

#pragma mark - Navigation

- (void)unwindTo:(UIStoryboardSegue *)segue
{
}

@end
