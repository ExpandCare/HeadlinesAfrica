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
    
    self.title = @"Invite Friends";
    
    [self configureBackButtonWhite:YES];
    [((HLNavigationController *)self.navigationController) setBlueColor];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

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
        
        CFIndex numberOfEmails = ABMultiValueGetCount(emails);
        
        for(int j = 0; j < numberOfEmails; ++j)
        {
            NSMutableDictionary *contactDict = [NSMutableDictionary dictionary];
            
            NSString *email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, j));
            int recordId = ABRecordGetRecordID(person);
            
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
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
                            @"email"        : email,
                            @"contactId"    : @(recordId),
                            @"isRegistered" : @(0)
                           } mutableCopy];
            
            if(ABMultiValueGetCount(phones))
            {
                [contactDict setObject:CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, 0)) forKey:@"phone"];
            }
            
            [self.contactsDataSource addObject:contactDict];
        }
        
        CFRelease(emails);
    }
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.isLoadingContacts)
    {
        return nil;
    }
    
    if(section == HLInviteFriendTableViewSectionTypeContacts)
    {
        return @"Invite Contacts";
    }
    
    return nil;
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
    
    if(self.invitingContactDict[@"phone"])
    {
        [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invite via email", @"Invite via SMS", nil] showInView:self.view.window];
    }
    else
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
    
    if(buttonIndex == HLInviteContactButtonTypeViaEmail)
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
            [controller setMessageBody:@"I use Headlines. You should try it." isHTML:NO];
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
    else if (buttonIndex == HLInviteContactButtonTypeViaSMS)
    {
        NSLog(@"PHONE = %@", self.invitingContactDict[@"phone"]);
        
        if ([MFMessageComposeViewController canSendText])
        {
            [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.02 green:0.62 blue:0.85 alpha:1]];
            
            MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
            
            UIFont *font = [UIFont mediumConsendedWithSize:16];
            NSDictionary *navbarTitleTextAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]};
            [messageComposer.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
            [messageComposer.navigationBar setTintColor:[UIColor whiteColor]];
            
            NSString *message = @"I use Headlines. You should try it.";
            messageComposer.recipients = [NSArray arrayWithObjects:self.invitingContactDict[@"phone"], nil];
            [messageComposer setBody:message];
            messageComposer.messageComposeDelegate = self;
            
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
