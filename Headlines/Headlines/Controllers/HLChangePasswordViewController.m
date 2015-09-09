//
//  HLChangePasswordViewController.m
//  Headlines
//
//

#import "HLChangePasswordViewController.h"
#import "HLNavigationController.h"
#import "TextFieldCell.h"
#import "ButtonCell.h"
#import <Parse/Parse.h>
#import <SAMHUDView/SAMHUDView.h>

#define CELL_ID_TEXT @"textFieldCellID"
#define CELL_ID_BUTTON @"doneCellID"

typedef NS_ENUM(NSUInteger, CellID) {
    CellIDOldPassword,
    CellIDNewPassword,
    CellIDRepeatPassword,
    CellIDDone
};

@interface HLChangePasswordViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

@property (strong, nonatomic) SAMHUDView *hud;

@end

@implementation HLChangePasswordViewController
{
    NSString *oldPassword;
    NSString *newPassword;
    NSString *repeatPassword;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Change password";
    
    [self configureBackButtonWhite:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDissapear)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    self.tableView.tableHeaderView = header;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapOnTable:)]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)tapOnTable:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
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

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == CellIDDone)
    {
        return 100;
    }
    else
    {
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *content = nil, *placeholder = nil;
    
    switch (indexPath.row)
    {
        case CellIDOldPassword:
        {
            content = oldPassword;
            placeholder = @"old password";
        }
        case CellIDNewPassword:
        {
            if (!placeholder)
            {
                content = newPassword;
                placeholder = @"new password";
            }
        }
        case CellIDRepeatPassword:
        {
            if (!placeholder)
            {
                content = repeatPassword;
                placeholder = @"repeat password";
            }
            
            TextFieldCell *textCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TEXT forIndexPath:indexPath];
            
            textCell.theTextField.placeholder = placeholder;
            textCell.theTextField.text = content;
            textCell.theTextField.secureTextEntry = YES;
            textCell.theTextField.delegate = self;
            textCell.theTextField.tag = indexPath.row;
            
            return textCell;
        }
        case CellIDDone:
        {
            ButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_BUTTON forIndexPath:indexPath];
            
            [buttonCell.theButton setTitle:@"Done" forState:UIControlStateNormal];
            [buttonCell.theButton addTarget:self
                                     action:@selector(donePressed:)
                           forControlEvents:UIControlEventTouchUpInside];
            
            return buttonCell;
        }
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return CellIDDone + 1;
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    switch (textField.tag)
    {
        case CellIDOldPassword:
        {
            oldPassword = result;
            
            break;
        }
        case CellIDNewPassword:
        {
            newPassword = result;
            
            break;
        }
        case CellIDRepeatPassword:
        {
            repeatPassword = result;
            
            break;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == CellIDOldPassword)
    {
        TextFieldCell *theCell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CellIDNewPassword inSection:0]];
        
        if (theCell)
        {
            [theCell.theTextField becomeFirstResponder];
        }
        else
        {
            [self showAndBecomeActiveCellAtRow:CellIDNewPassword];
        }
    }
    else if (textField.tag == CellIDNewPassword)
    {
        TextFieldCell *theCell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CellIDRepeatPassword inSection:0]];
        
        if (theCell)
        {
            [theCell.theTextField becomeFirstResponder];
        }
        else
        {
            [self showAndBecomeActiveCellAtRow:CellIDRepeatPassword];
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


- (void)donePressed:(UIButton *)sender
{
    if (!IS_INTERNET_CONNECTED)
    {
        [[[UIAlertView alloc] initWithTitle:@"Failed"
                                    message:@"Connect to the Internet"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    PFUser *user = [PFUser currentUser];
    
    oldPassword = [oldPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    newPassword = [newPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    repeatPassword = [repeatPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (oldPassword.length < 6)
    {
        [[[UIAlertView alloc] initWithTitle:@"Old password is incorrect"
                                    message:@"Old password must be at least 6 symbols"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:kDefaultsUserKeyPassword];
    
    if (![oldPassword isEqualToString:password])
    {
        [[[UIAlertView alloc] initWithTitle:@"Old password is incorrect"
                                    message:@"Enter your's password"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }

    if (newPassword.length < 6)
    {
        [[[UIAlertView alloc] initWithTitle:@"New password is incorrect"
                                    message:@"New password must be at least 6 symbols"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    if (repeatPassword.length < 6)
    {
        [[[UIAlertView alloc] initWithTitle:@"Repeat password is incorrect"
                                    message:@"Repeat password must be at least 6 symbols"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    if (![repeatPassword isEqualToString:newPassword])
    {
        [[[UIAlertView alloc] initWithTitle:@"Repeat password is incorrect"
                                    message:@"Repeat password must be the same as \"new password\""
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    self.hud = [[SAMHUDView alloc] initWithTitle:@""];
    [self.hud show];
    
    __weak typeof(self) controller = self;
    
    user.password = newPassword;
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
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
            [[NSUserDefaults standardUserDefaults] setObject:newPassword forKey:kDefaultsUserKeyPassword];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[[UIAlertView alloc] initWithTitle:@"Success"
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            
            [controller backButtonPressed:nil];
        }
    }];
}

- (void)backButtonPressed:(UIButton *)backButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
