//
//  HLSettingsViewController.m
//  Headlines


#import "HLSettingsViewController.h"
#import "HLNavigationController.h"
#import "HLSettingsCell.h"
#import <PFFacebookUtils.h>
#import "Helpshift.h"
#import "HLTermsAndPrivacyViewController.h"

typedef NS_ENUM(NSInteger, HLSettingsCellType)
{
    HLSettingsCellTypeAbout    = 0,
    HLSettingsCellTypeHelp     = 1,
    HLSettingsCellTypePrivacy  = 2,
    HLSettingsCellTypeTerms    = 3,
    HLSettingsCellTypePassword = 4,
    HLSettingsCellTypeLogout   = 5
};

NSString * const kSettingsCellIdentifier = @"settingsCellIdentifier";

@interface HLSettingsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) HLContentType selectedContentType;

@end

@implementation HLSettingsViewController

#pragma mark - UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:kSettingsCellIdentifier forIndexPath:indexPath];
    
    if(indexPath.row == HLSettingsCellTypeAbout)
    {
        [cell configureWithColor:HLSettingsCellTextColorBlack text:@"About us" accessoryView:YES];
    }
    else if (indexPath.row == HLSettingsCellTypeHelp)
    {
        [cell configureWithColor:HLSettingsCellTextColorBlack text:@"Help & Feedback" accessoryView:YES];
    }
    else if (indexPath.row == HLSettingsCellTypePrivacy)
    {
        [cell configureWithColor:HLSettingsCellTextColorBlack text:@"Privacy Statement" accessoryView:YES];
    }
    else if (indexPath.row == HLSettingsCellTypeTerms)
    {
        [cell configureWithColor:HLSettingsCellTextColorBlack text:@"Terms of Service" accessoryView:YES];
    }
    else if (indexPath.row == HLSettingsCellTypePassword)
    {
        [cell configureWithColor:HLSettingsCellTextColorBlue text:@"Change password" accessoryView:NO];
    }
    else if (indexPath.row == HLSettingsCellTypeLogout)
    {
        [cell configureWithColor:HLSettingsCellTextColorRed text:@"Logout" accessoryView:NO];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == HLSettingsCellTypeLogout)
    {
        [self logoutAction];
    }
    else if (indexPath.row == HLSettingsCellTypePassword)
    {
        [self changePasswordAction];
    }
    else if (indexPath.row == HLSettingsCellTypeHelp)
    {
        [self feedbackAction];
    }
    else if (indexPath.row == HLSettingsCellTypePrivacy)
    {
        self.selectedContentType = HLContentTypePrivacy;
        [self performSegueWithIdentifier:@"pushTermsAndPrivacyViewControllerSegue" sender:self];
    }
    else if (indexPath.row == HLSettingsCellTypeTerms)
    {
        self.selectedContentType = HLContentTypeTerms;
        [self performSegueWithIdentifier:@"pushTermsAndPrivacyViewControllerSegue" sender:self];
    }
    else if (indexPath.row == HLSettingsCellTypeAbout)
    {
        self.selectedContentType = HLContentTypeAboutUs;
        [self performSegueWithIdentifier:@"pushTermsAndPrivacyViewControllerSegue" sender:self];
    }
}

#pragma mark - Private

- (void)logoutAction
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

- (void)changePasswordAction
{
    [self performSegueWithIdentifier:@"toChangePasswordScreen" sender:self];
}

- (void)feedbackAction
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[Helpshift sharedInstance] showFAQs:self withOptions:nil];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"pushTermsAndPrivacyViewControllerSegue"])
    {
        ((HLTermsAndPrivacyViewController *)segue.destinationViewController).currentContentType = self.selectedContentType;
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    [self configureBackButtonWhite:NO];
    [((HLNavigationController *)self.navigationController) setWhiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
