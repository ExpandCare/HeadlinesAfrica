//
//  HLRegistrationViewController.m
//  Headlines
//
//

#import "HLRegistrationViewController.h"
#import "LoginWithFacebookCell.h"
#import "ButtonCell.h"
#import "TextFieldCell.h"
#import "HLNavigationController.h"
#import <Parse/Parse.h>
#import <FacebookSDK.h>
#import <PFFacebookUtils.h>
#import <SAMHUDView.h>
#import "AppDelegate.h"
#import "NSString+EmailValidation.h"
#import "ParseTwitterUtils/PF_Twitter.h"

#define CELL_ID_TEXT_FIELD @"textFieldCellID"
#define CELL_ID_FACEBOOK @"facebookCellID"
#define CELL_ID_DONE @"doneCellID"

#define TEXT_FIELD_CELL_HEIGHT 55

typedef NS_ENUM(NSUInteger, CellID) {
    CELLIDName,
    CellIDEmail,
    CellIDPassword,
    CellIDDone,
    CellIDFacebook
};

@interface HLRegistrationViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) SAMHUDView *hud;

@end

@implementation HLRegistrationViewController
{
    NSString *email;
    NSString *name;
    NSString *password;
    
    BOOL needToRemovePassword;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Registration", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDissapear)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapOnTable:)]];
    
    [self configureBackButtonWhite:NO];
    [((HLNavigationController *)self.navigationController) setWhiteColor];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keyboard

- (void)keyboardWillAppear:(NSNotification *)notification
{
    CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.tableViewBottomConstraint.constant = keyboardHeight;
    
    [self.view layoutIfNeeded];
}

- (void)keyboardWillDissapear
{
    self.tableViewBottomConstraint.constant = 0;
    
    [self.view layoutIfNeeded];
}

#pragma mark - Recognizer

- (void)tapOnTable:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

#pragma mark - ActiveSignInButton

- (BOOL)checkAndSetActiveIfNeeded
{
    ButtonCell *cell = (ButtonCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CellIDDone inSection:0]];
    
    cell.isActive = (email.length && password.length && name.length ? YES : NO);
    
    return cell.isActive;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return CellIDFacebook + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case CellIDFacebook:
        {
            return 163;
        }
        case CELLIDName:
        case CellIDEmail:
        case CellIDPassword:
        {
            return TEXT_FIELD_CELL_HEIGHT;
        }
        case CellIDDone:
        {
            return 100;
        }
        default:
        {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *placeholder, *content;
    
    switch (indexPath.row)
    {
        case CellIDFacebook:
        {
            LoginWithFacebookCell *theCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_FACEBOOK forIndexPath:indexPath];
            
            [theCell.facebookButton addTarget:self
                                       action:@selector(loginWithFacebookPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
            [theCell.twitterButton addTarget:self
                                      action:@selector(loginWithTwitterPressed:)
                            forControlEvents:UIControlEventTouchUpInside];
            
            return theCell;
        }
        case CELLIDName:
        {
            placeholder = NSLocalizedString(@"Name", nil);
            content = name;
        }
        case CellIDEmail:
        {
            if (!placeholder)
            {
                placeholder = NSLocalizedString(@"Email", nil);
                content = email;
            }
        }
        case CellIDPassword:
        {
            TextFieldCell *theCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TEXT_FIELD forIndexPath:indexPath];
            
            if (!placeholder)
            {
                placeholder = NSLocalizedString(@"Password", nil);
                content = password;
            }
            
            theCell.theTextField.delegate = self;
            theCell.theTextField.placeholder = placeholder;
            theCell.theTextField.text = content;
            theCell.theTextField.tag = indexPath.row;
            theCell.theTextField.secureTextEntry = (indexPath.row == CellIDPassword ? YES : NO);
            theCell.theTextField.keyboardType = (indexPath.row == CellIDEmail ? UIKeyboardTypeEmailAddress : UIKeyboardTypeAlphabet);
            
            return theCell;
        }
        case CellIDDone:
        {
            ButtonCell *theCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_DONE forIndexPath:indexPath];
            
            [theCell.theButton addTarget:self
                                  action:@selector(registerPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
            
            return theCell;
        }
        default:
        {
            return 0;
        }
    }
}

#pragma mark - TextField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    needToRemovePassword = textField.text.length ? YES : NO;
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *result = [[textField.text stringByReplacingCharactersInRange:range
                                                                withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    if (textField.tag == CELLIDName)
    {
        name = result;
    }
    else if (textField.tag == CellIDEmail)
    {
        email = result;
    }
    else if (textField.tag == CellIDPassword)
    {
        password = needToRemovePassword ? string : result;
        needToRemovePassword = NO;
    }
    
    [self checkAndSetActiveIfNeeded];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == CELLIDName)
    {
        TextFieldCell *theCell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CellIDEmail inSection:0]];
        
        if (theCell)
        {
            [theCell.theTextField becomeFirstResponder];
        }
        else
        {
            [self showAndBecomeActiveCellAtRow:CellIDEmail];
        }
    }
    else if (textField.tag == CellIDEmail)
    {
        TextFieldCell *theCell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CellIDPassword inSection:0]];
        
        if (theCell)
        {
            [theCell.theTextField becomeFirstResponder];
        }
        else
        {
            [self showAndBecomeActiveCellAtRow:CellIDPassword];
        }
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)showAndBecomeActiveCellAtRow:(NSInteger)row
{
    __weak HLRegistrationViewController *weakSelf = self;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         
                         [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                     }
                     completion:^(BOOL finished) {
                         
                         TextFieldCell *theCell = (TextFieldCell *)[weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
                         
                         if (theCell)
                         {
                             [theCell.theTextField becomeFirstResponder];
                         }
                     }];
}

#pragma mark - Actions

- (void)registerPressed:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (!IS_INTERNET_CONNECTED)
    {
        [[[UIAlertView alloc] initWithTitle:@"Failed"
                                    message:@"Connect to the Internet"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (!name.length)
    {
        [[[UIAlertView alloc] initWithTitle:@"Name field is empty"
                                    message:@"Please, enter the name"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    if (!email.length)
    {
        [[[UIAlertView alloc] initWithTitle:@"Email field is empty"
                                    message:@"Please, enter the email"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    if (![email emailIsCorrect])
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't sign in", nil)
                                    message:NSLocalizedString(@"Email is incorrect", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil] show];
        return;
    }
    if (password.length < 6)
    {
        [[[UIAlertView alloc] initWithTitle:@"Password is incorrect"
                                    message:@"Password must be at least 6 symbols"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    PFUser *user = [PFUser user];
    user.username = email;
    user.email = email;
    user[kPFUserKeyDisplayName] = name;
    user.password = password;
    
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:kDefaultsUserKeyPassword];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.hud = [[SAMHUDView alloc] initWithTitle:@""];
    [self.hud show];
    
    __weak HLRegistrationViewController *controller = self;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [controller.hud dismissAnimated:YES];
        
        if (error)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.userInfo[@"error"]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];

        }
        else
        {
            [user save];
            
            [controller performSegueWithIdentifier:@"toNewsController" sender:self];
        }
    }];
}

- (void)loginWithFacebookPressed:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (!IS_INTERNET_CONNECTED)
    {
        [[[UIAlertView alloc] initWithTitle:@"Failed"
                                    message:@"Connect to the Internet"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    self.hud = [[SAMHUDView alloc] initWithTitle:@""];
    [self.hud show];
    
    __weak HLRegistrationViewController *controller = self;
    
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email"] block:^(PFUser *user, NSError *error) {
        
        [controller.hud dismissAnimated:YES];
        
        if (!error && user)
        {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kDefaultsUserKeyPassword];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            FBRequest *request = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:@"me/?fields=name,email"];
            
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                
                if (!error)
                {
                    NSDictionary *userData = (NSDictionary *)result;
                    
                    user.username = user.email = userData[@"email"];
                    user[kPFUserKeyDisplayName] = userData[@"name"];
                    
                    [user save];
                    
                    [controller performSegueWithIdentifier:@"toNewsController" sender:controller];
                }
            }];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Something went wrong"
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
    }];
}

- (void)loginWithTwitterPressed:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (!IS_INTERNET_CONNECTED)
    {
        [[[UIAlertView alloc] initWithTitle:@"Failed"
                                    message:@"Connect to the Internet"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    self.hud = [[SAMHUDView alloc] initWithTitle:@""];
    [self.hud show];
    
    __weak HLRegistrationViewController *controller = self;
    
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        
        if (!user)
        {
            [controller.hud dismissAnimated:YES];
            
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Something went wrong"
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kDefaultsUserKeyPassword];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *displayName = [PFTwitterUtils twitter].screenName;
        user[kPFUserKeyDisplayName] = displayName;
        
        [user save];
        
        [controller.hud dismissAnimated:YES];
        [controller performSegueWithIdentifier:@"toNewsController" sender:controller];
    }];
}

@end
