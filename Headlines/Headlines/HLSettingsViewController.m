//
//  HLSettingsViewController.m
//  Headlines


#import "HLSettingsViewController.h"
#import "HLNavigationController.h"
#import "HLSettingsCell.h"
#import <PFFacebookUtils.h>

typedef NS_ENUM(NSInteger, HLSettingsCellType)
{
    HLSettingsCellTypeAbout    = 0,
    HLSettingsCellTypeHelp     = 1,
    HLSettingsCellTypePassword = 2,
    HLSettingsCellTypeLogout   = 3
};

NSString * const kSettingsCellIdentifier = @"settingsCellIdentifier";

@interface HLSettingsViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation HLSettingsViewController

#pragma mark - UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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
