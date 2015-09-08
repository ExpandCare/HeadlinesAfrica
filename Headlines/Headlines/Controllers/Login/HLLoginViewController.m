//
//  HLLoginViewController.m
//  Headlines
//
//

#import "HLLoginViewController.h"
#import "LoginWithFacebookCell.h"
#import "TextFieldCell.h"
#import "ButtonCell.h"
#import "HLNavigationController.h"
#import <Parse/Parse.h>
#import <FacebookSDK.h>
#import <PFFacebookUtils.h>
#import <SAMHUDView/SAMHUDView.h>
#import "AppDelegate.h"
#import "NSString+EmailValidation.h"
#import "UIFont+Consended.h"
#import "ParseTwitterUtils/PF_Twitter.h"

#define CELL_ID_TEXT_FIELD @"textFieldCellID"
#define CELL_ID_FACEBOOK @"facebookCellID"
#define CELL_ID_DONE @"doneCellID"

typedef NS_ENUM(NSUInteger, CellID) {
    CellIDEmail,
    CellIDPassword,
    CellIDDone,
    CellIDFacebook
};

@interface HLLoginViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottonConstraint;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;

@property (strong, nonatomic) SAMHUDView *hud;

@end

@implementation HLLoginViewController
{
    NSString *email;
    NSString *password;
    
    BOOL needToRemovePassword;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Sign in", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDissapear)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.forgotButton.titleLabel setFont:[UIFont consendedWithSize:16]];
    
    self.tableView.scrollEnabled = NO;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkAndSetActiveIfNeeded];
}

#pragma mark - Keyboard

- (void)keyboardWillAppear:(NSNotification *)notification
{
    self.tableView.scrollEnabled = YES;
    
    CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.tableViewBottonConstraint.constant = keyboardHeight;
    
    [self.view layoutIfNeeded];
}

- (void)keyboardWillDissapear
{
    self.tableView.scrollEnabled = NO;
    
    self.tableViewBottonConstraint.constant = 0;
    
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
    
    cell.isActive = (email.length && password.length ? YES : NO);
    
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
//            if (CGRectGetHeight(self.view.bounds) < 568)
//            {
//                return 150;
//            }
            
            return 160;
        }
        case CellIDEmail:
        case CellIDPassword:
        {
            return 55;
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
    NSString *placeholder = nil;
    
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
        case CellIDEmail:
        {
            placeholder = NSLocalizedString(@"Email", nil);
        }
        case CellIDPassword:
        {
            TextFieldCell *theCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TEXT_FIELD forIndexPath:indexPath];
            
            if (!placeholder)
            {
                placeholder = NSLocalizedString(@"Password", nil);
                theCell.theTextField.keyboardType = UIKeyboardTypeAlphabet;
                theCell.theTextField.text = password;
            }
            else
            {
                theCell.theTextField.text = email;
                theCell.theTextField.keyboardType = UIKeyboardTypeEmailAddress;
            }
            
            theCell.theTextField.delegate = self;
            theCell.theTextField.placeholder = placeholder;
            theCell.theTextField.tag = indexPath.row;
            theCell.theTextField.secureTextEntry = (indexPath.row == CellIDPassword ? YES : NO);
            
            return theCell;
        }
        case CellIDDone:
        {
            ButtonCell *theCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_DONE forIndexPath:indexPath];
            
            [theCell.theButton addTarget:self
                                  action:@selector(loginPressed:)
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *result = [[textField.text stringByReplacingCharactersInRange:range
                                                                withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    if (textField.tag == CellIDEmail)
    {
        email = result ;
    }
    else if (textField.tag == CellIDPassword)
    {
        password = needToRemovePassword ? string : result;
        needToRemovePassword = NO;
    }
    
    [self checkAndSetActiveIfNeeded];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    needToRemovePassword = textField.text.length ? YES : NO;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == CellIDEmail)
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
    __weak typeof(self) weakSelf = self;
    
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

- (void)loginPressed:(UIButton *)sender
{
    if (![self checkAndSetActiveIfNeeded])
    {
        return;
    }
    
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
    
    email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
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
    
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:kDefaultsUserKeyPassword];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.hud = [[SAMHUDView alloc] initWithTitle:@""];
    [self.hud show];
    
    __weak HLLoginViewController *controller = self;
    
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
        
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
            [controller performSegueWithIdentifier:@"toNewsController" sender:controller];
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
    
    __weak HLLoginViewController *controller = self;
    
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
    
    __weak typeof(self) controller = self;
    
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


- (IBAction)forgotPasswordPressed:(id)sender
{
    email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
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
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email is incorrect", nil)
                                    message:nil
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil] show];
        return;
    }
    
    NSDictionary *parameters = @{@"email": email};
    
    [PFCloud callFunctionInBackground:@"resetPassword"
                       withParameters:parameters
                                block:^(id object, NSError *error) {
        
                                    if (error)
                                    {
                                        [[[UIAlertView alloc] initWithTitle:@"Failed"
                                                                    message:@"Something went wrong"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil] show];
                                    }
                                    else
                                    {
                                        [[[UIAlertView alloc] initWithTitle:@"Success"
                                                                    message:@"Email with instructions was sent"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil] show];
                                    }
    }];
//    return;
//    
//    if ([PFUser requestPasswordResetForEmail:email])
//    {
//        [[[UIAlertView alloc] initWithTitle:@"Success"
//                                    message:@"Email with instructions was sent"
//                                   delegate:nil
//                          cancelButtonTitle:@"Ok"
//                          otherButtonTitles:nil] show];
//    }
//    else
//    {
//        [[[UIAlertView alloc] initWithTitle:@"Failed"
//                                    message:@"Something went wrong"
//                                   delegate:nil
//                          cancelButtonTitle:@"Ok"
//                          otherButtonTitles:nil] show];
//    }
}

@end
