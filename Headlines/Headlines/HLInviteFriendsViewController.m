//
//  HLInviteFriendsViewController.m
//  Headlines


#import "HLInviteFriendsViewController.h"
#import "HLNavigationController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBook.h>
#import "ContactCell.h"
#import <Parse/Parse.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "UIFont+Consended.h"

typedef NS_ENUM(NSInteger, HLInviteFriendTableViewSectionType)
{
    HLInviteFriendTableViewSectionTypeExistingContactUsers = 0,
    HLInviteFriendTableViewSectionTypeContacts             = 1
};

typedef NS_ENUM(NSInteger, HLInviteContactButtonType)
{
    HLInviteContactButtonTypeViaEmail = 0,
    HLInviteContactButtonTypeViaSMS   = 1
};

@interface HLInviteFriendsViewController ()<UITableViewDataSource, UITableViewDelegate, ContactCellDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *contactsDataSource;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL isLoadingContacts;
@property (nonatomic, strong) NSDictionary *invitingContactDict;

@end

@implementation HLInviteFriendsViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Find people to invite";
    
    [self configureBackButtonWhite:NO];
    [((HLNavigationController *)self.navigationController) setWhiteColor];
    
    __weak typeof(self) weakSelf = self;
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error)
        {
            if (granted)
            {
                [weakSelf generateDataSourceForContactsTableFromContacts:CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBookRef))];
                
                NSDictionary *paramsDict = @{
                                             @"emails" : [weakSelf.contactsDataSource valueForKeyPath:@"email"]
                                             };
                
                weakSelf.isLoadingContacts = YES;
                
                [PFCloud callFunctionInBackground:@"getListOfUsersFromEmailsList" withParameters:paramsDict block:^(id object, NSError *error)
                 {
                     weakSelf.isLoadingContacts = NO;
                     
                     if(!error)
                     {
                         if(((NSArray *)object).count)
                         {
                             [weakSelf checkAlreadyRegisteredContacts:object];
                             [weakSelf.tableView reloadData];
                         }
                     }
                     
                 }];
                
            }
            else
            {
                // User denied access
                SHOW_ALERT_WITH_TITLE_AND_MESSAGE(@"Contacts Access Denied", @"This app requires access to your device's Contacts.\n\nPlease enable Contacts access for this app in Settings / Privacy / Contacts");
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        [weakSelf generateDataSourceForContactsTableFromContacts:CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBookRef))];
        
        NSMutableArray *emailArr = [[weakSelf.contactsDataSource valueForKeyPath:@"email"] mutableCopy];
        [emailArr removeObjectIdenticalTo:[NSNull null]];
        
        NSDictionary *paramsDict = @{
                                     @"emails" : [weakSelf.contactsDataSource valueForKeyPath:@"email"]
                                    };
        
        weakSelf.isLoadingContacts = YES;
        
        [PFCloud callFunctionInBackground:@"getListOfUsersFromEmailsList" withParameters:paramsDict block:^(id object, NSError *error)
         {
             weakSelf.isLoadingContacts = NO;
             
             if(!error)
             {
                [weakSelf checkAlreadyRegisteredContacts:object];
                [weakSelf.tableView reloadData];
             }
            
        }];
    }
    else
    {
        // The user has previously denied access
        SHOW_ALERT_WITH_TITLE_AND_MESSAGE(@"Contacts Access Denied", @"This app requires access to your device's Contacts.\n\nPlease enable Contacts access for this app in Settings / Privacy / Contacts");
    }
        
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doubleTap)
                                                 name:kNotificationDoubleTap
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)doubleTap
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                              inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    
}

- (void)generateDataSourceForContactsTableFromContacts:(NSArray *)contacts
{
    self.contactsDataSource = [NSMutableArray array];
    
    for(int i = 0; i < contacts.count; ++i)
    {
        
        ABRecordRef person = (__bridge ABRecordRef)contacts[i];
        
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
       [NSString stringWithFormat:@"%@ %@", lastName, firstName];
        
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSMutableDictionary *contactDict = [NSMutableDictionary dictionary];
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        int recordId = ABRecordGetRecordID(person);
        NSMutableString *name = [NSMutableString stringWithString:lastName ? lastName : @""];
        
        if(firstName)
        {
            if(name.length)
            {
                [name appendString:@" "];
            }
            
            [name appendFormat:@"%@", firstName];
        }
        
        contactDict = [@{
                         @"name"         : name,
                         @"contactId"    : @(recordId),
                         @"isRegistered" : @(0)
                         } mutableCopy];
        
        BOOL isCanBeInvited = NO;
        
        if(ABMultiValueGetCount(phones))
        {
            isCanBeInvited = YES;
            [contactDict setObject:CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, 0)) forKey:@"phone"];
        }
        
        if(ABMultiValueGetCount(emails))
        {
            isCanBeInvited = YES;
            [contactDict setObject:CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, 0)) forKey:@"email"];
        }
        
        if(isCanBeInvited)
        {
             [self.contactsDataSource addObject:contactDict];
        }
        
        CFRelease(emails);
        CFRelease(phones);
    }
    
    self.contactsDataSource = [[self.contactsDataSource sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]] mutableCopy];
    
}

- (void)checkAlreadyRegisteredContacts:(NSArray *)users
{
    for(PFUser *user in users)
    {
        NSArray *filteredArray = [self.contactsDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"email == %@", user.email]];
        int index = 0;
        
        if(filteredArray.count > 0)
        {
            NSMutableDictionary *dict = [filteredArray[0] mutableCopy];
            index = [self.contactsDataSource indexOfObject:dict];
            dict[@"isRegistered"] = @(1);
            [self.contactsDataSource replaceObjectAtIndex:index withObject:dict];
            
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            
            int i = 0;
            
            for(NSDictionary *contactDict in self.contactsDataSource)
            {
                if([contactDict[@"contactId"] intValue] == [dict[@"contactId"] intValue] && [contactDict[@"isRegistered"] intValue] == 0)
                {
                    [indexSet addIndex:i];
                }
                
                ++i;
            }
            
            [self.contactsDataSource removeObjectsAtIndexes:indexSet];
        }
    }
}

#pragma mark - Actions

- (void)backButtonPressed:(UIButton *)backButton
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isLoadingContacts)
    {
        return 0;
    }
    
    if(section == HLInviteFriendTableViewSectionTypeExistingContactUsers)
    {
        return [self.contactsDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isRegistered == 1"]].count;
    }
    else if (section == HLInviteFriendTableViewSectionTypeContacts)
    {
        return [self.contactsDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isRegistered == 0"]].count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dataSource;
    
    if(indexPath.section == HLInviteFriendTableViewSectionTypeExistingContactUsers)
    {
        dataSource = [self.contactsDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isRegistered == 1"]];
    }
    else if (indexPath.section == HLInviteFriendTableViewSectionTypeContacts)
    {
        dataSource = [self.contactsDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isRegistered == 0"]];
    }
    
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell configureCellWithContact:dataSource[indexPath.row]];
    
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(self.isLoadingContacts)
    {
        return nil;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.9f]];
    
    if (section == HLInviteFriendTableViewSectionTypeContacts)
    {
        UILabel *titleLbl = [[UILabel alloc] init];
        titleLbl.text = @"Invite Contacts";
        [titleLbl setTextColor:[UIColor colorWithRed:0.08 green:0.66 blue:0.93 alpha:1]];
        [titleLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f]];
        titleLbl.frame = CGRectMake(18, 0, 300, 30);
        [headerView addSubview:titleLbl];
    }
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.isLoadingContacts)
    {
        return 0;
    }
    
    if (section == HLInviteFriendTableViewSectionTypeContacts)
    {
        return 30;
    }
    
    return 0;
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
}

#pragma mark - ContactCell delegate methods

- (void)didTappedInviteBtnForCell:(ContactCell *)cell
{
    NSArray *dataSource = [self.contactsDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isRegistered == 0"]];
    self.invitingContactDict = dataSource[[self.tableView indexPathForCell:cell].row];
    
    if(self.invitingContactDict[@"phone"] && self.invitingContactDict[@"email"])
    {
        [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invite via email", @"Invite via SMS", nil] showInView:self.view.window];
    }
    else if(self.invitingContactDict[@"phone"])
    {
        [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invite via SMS", nil] showInView:self.view.window];
    }
    else if (self.invitingContactDict[@"email"])
    {
        [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invite via email", nil] showInView:self.view.window];
    }
    
    
}

#pragma mark - UIActionSheet delegate methods


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    
    if(self.invitingContactDict[@"phone"] && self.invitingContactDict[@"email"])
    {
        if(buttonIndex == HLInviteContactButtonTypeViaEmail)
        {
            [self sendInvitationViaEmail];
        }
        else if (buttonIndex == HLInviteContactButtonTypeViaSMS)
        {
            [self sendInvitationViaSMS];
        }
    }
    else if (self.invitingContactDict[@"phone"])
    {
        [self sendInvitationViaSMS];
    }
    else if (self.invitingContactDict[@"email"])
    {
        [self sendInvitationViaEmail];
    }
    
}

- (void)sendInvitationViaSMS
{
    if ([MFMessageComposeViewController canSendText])
    {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.02 green:0.62 blue:0.85 alpha:1]];
        
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
        
        UIFont *font = [UIFont mediumConsendedWithSize:16];
        NSDictionary *navbarTitleTextAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]};
        [messageComposer.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
        [messageComposer.navigationBar setTintColor:[UIColor whiteColor]];
        
        NSString *message = INVITE_MESSAGE;
        messageComposer.recipients = [NSArray arrayWithObjects:self.invitingContactDict[@"phone"], nil];
        [messageComposer setBody:message];
        messageComposer.messageComposeDelegate = self;
        
        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
        [self presentViewController:messageComposer animated:YES completion:^
         {
             [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
         }];
    }
    else
    {
        SHOW_ALERT_WITH_TITLE_AND_MESSAGE(@"Unable to send text message", @"Please, check your settings");
    }
}

- (void)sendInvitationViaEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.02 green:0.62 blue:0.85 alpha:1]];
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        
        UIFont *font = [UIFont mediumConsendedWithSize:16];
        NSDictionary *navbarTitleTextAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]};
        [controller.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
        [controller.navigationBar setTintColor:[UIColor whiteColor]];
        
        [controller setSubject:@"Join me in Headlines"];
        [controller setMessageBody:INVITE_MESSAGE_HTML isHTML:YES];
        [controller setToRecipients:[NSArray arrayWithObjects:self.invitingContactDict[@"email"], nil]];
        
        [self presentViewController:controller animated:YES completion:^
         {
             [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
         }];
    }
    else
    {
        SHOW_ALERT_WITH_TITLE_AND_MESSAGE(@"Unable to send email", @"Please, check your settings");
    }
}

#pragma mark - MFMailViewController delegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    NSString *message = @"";
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            message = @"Email Cancelled";
            break;
        case MFMailComposeResultSaved:
            message = @"Email Saved";
            break;
        case MFMailComposeResultSent:
            SHOW_ALERT_WITH_TITLE_AND_MESSAGE(@"", @"Email sent");
            break;
        case MFMailComposeResultFailed:
             SHOW_ALERT_WITH_TITLE_AND_MESSAGE(@"", @"Email failed");
            break;
        default:
            message = @"Email Not Sent";
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
}

#pragma mark - MFMessageComposeViewController

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSString *message = @"";
    
    switch (result)
    {
        case MessageComposeResultCancelled:
            message = @"Message Cancelled";
            break;
        case MessageComposeResultSent:
            SHOW_ALERT_WITH_TITLE_AND_MESSAGE(@"", @"Message sent");
            break;
        case MessageComposeResultFailed:
            SHOW_ALERT_WITH_TITLE_AND_MESSAGE(@"", @"Message failed");
            break;
        default:
            message = @"Message Not Sent";
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
