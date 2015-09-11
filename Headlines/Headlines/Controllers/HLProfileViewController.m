//
//  HLProfileViewController.m
//  Headlines
//
//

#import "HLProfileViewController.h"
#import "UIFont+Consended.h"
#import <Parse/Parse.h>

@interface HLProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteContactsBtn;

@end

@implementation HLProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.inviteContactsBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f]];
    self.inviteContactsBtn.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    self.inviteContactsBtn.layer.cornerRadius = 9.0f;
    
    [self.emailLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f]];
}

- (void)viewWillAppear:(BOOL)animated
{
        
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
    
  //  self.changePasswordButton.hidden = (BOOL)![[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsUserKeyPassword] length];
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
