//
//  HLProfileViewController.m
//  Headlines
//
//

#import "HLProfileViewController.h"
#import "UIFont+Consended.h"
#import <Parse/Parse.h>

@interface HLProfileViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteContactsBtn;

@end

@implementation HLProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.inviteContactsBtn.layer.cornerRadius = 9.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.logoutButton setTitleColor:[UIColor colorWithRed:1 green:0.44 blue:0.45 alpha:1] forState:UIControlStateNormal];
    
    self.logoutButton.layer.borderWidth = 2;
    self.logoutButton.layer.borderColor = self.logoutButton.titleLabel.textColor.CGColor;
    
    [self.logoutButton.titleLabel setFont:[UIFont mediumConsendedWithSize:20]];
    //[self.logoutButton setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, -3, 0)];
    
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


- (IBAction)inviteFriendsButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"toInviteFriendsScreen" sender:self];
}

- (IBAction)settingsButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"presentSettingsViewControllerSegue" sender:self];
}

@end
