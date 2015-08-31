//
//  HLProfileViewController.m
//  Headlines
//
//

#import "HLProfileViewController.h"
#import "UIFont+Consended.h"
#import <Parse/Parse.h>
#import <PFFacebookUtils.h>

@interface HLProfileViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;

@end

@implementation HLProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.logoutButton setTitleColor:[UIColor colorWithRed:1 green:0.44 blue:0.45 alpha:1] forState:UIControlStateNormal];
    
    self.logoutButton.layer.borderWidth = 2;
    self.logoutButton.layer.borderColor = self.logoutButton.titleLabel.textColor.CGColor;
    
    [self.logoutButton.titleLabel setFont:[UIFont mediumConsendedWithSize:20]];
    //[self.logoutButton setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, -3, 0)];
    
    self.usernameLabel.font = [UIFont consendedWithSize:29];
    self.emailLabel.font = [UIFont consendedWithSize:20];
    
    if ([PFUser currentUser])
    {
        self.usernameLabel.text = [PFUser currentUser][kPFUserKeyDisplayName];
        if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]])
        {
            self.emailLabel.text = [PFUser currentUser].username;
        }
        else
        {
            self.emailLabel.text = @"";
        }
    }
    
    self.changePasswordButton.hidden = (BOOL)![[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsUserKeyPassword] length];
}

#pragma mark - Actions

- (IBAction)logoutButtonPressed:(id)sender
{
    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *inCookiesApi = [cookies cookies];
    
    for(NSHTTPCookie *cookie in inCookiesApi)
    {
        [cookies deleteCookie:cookie];
    }

    if(FBSession.activeSession.isOpen)
    {
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
        [FBSession setActiveSession:nil];
        NSLog(@"session close");
    }
    
    [PFUser logOut];
    
    [self performSegueWithIdentifier:@"backToStart" sender:self];
}

- (IBAction)changePasswordButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"toChangePasswordScreen" sender:self];
}

- (IBAction)inviteFriendsButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"toInviteFriendsScreen" sender:self];
}

@end
