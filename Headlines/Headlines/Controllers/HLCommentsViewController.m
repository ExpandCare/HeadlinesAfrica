//
//  HLCommentsViewController.m
//  Headlines
//
//

#import "HLCommentsViewController.h"
#import "CommentCell.h"
#import "NSDate+Extentions.h"
#import "Post+Additions.h"
#import "HLComment.h"
#import "Comment+Additions.h"
#import "Constants.h"
#import <SAMHUDView/SAMHUDView.h>

#define COMMENT_CELL_ID @"COMMENT_CELL_ID"

@interface HLCommentsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *theTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *fieldBackgroundView;

@property (strong, nonatomic) NSArray *comments;

@property (strong, nonatomic) SAMHUDView *hud;

@end

@implementation HLCommentsViewController
{
    NSString *text;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureBackButtonWhite:YES];
    
    self.title = @"Comments";
    
    self.tableView.allowsSelection = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillApear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDissapear)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapOnTable)]];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)doubleTap
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                              inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doubleTap)
                                                 name:kNotificationDoubleTap
                                               object:nil];

    
    self.sendButton.enabled = NO;
    
    self.theTextField.delegate = self;
    
    [self reload];
    [self getComments];
}

- (void)getComments
{
    __weak HLCommentsViewController *controller = self;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Comment" predicate:[NSPredicate predicateWithFormat:@"postId == %@", self.post]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *PF_NULLABLE_S objects, NSError *PF_NULLABLE_S error){
        
        [Comment createOrUpdateCommentsInBackground:objects completion:^(BOOL success, NSError *error) {
            
            [controller reload];
        }];
    }];
}

- (void)setComments:(NSMutableArray *)comments
{
    _comments = comments;
    
    [self.tableView reloadData];
}

- (void)reload
{
    self.comments = [Comment MR_findByAttribute:@"postID" withValue:self.postID andOrderBy:@"createdAt" ascending:YES];
}

- (void)tapOnTable
{
    [self.view endEditing:YES];
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    self.sendButton.enabled = ([result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 ? YES : NO);
    
    return YES;
}

#pragma mark - Keyboard

- (void)keyboardWillApear:(NSNotification *)notification
{
    CGFloat keyboardHeight = CGRectGetHeight([notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]);
    
    self.bottomConstraint.constant = keyboardHeight;
    
    __weak typeof(self) controller = self;
    [UIView animateWithDuration:0.2 animations:^{
        
        [controller.view layoutIfNeeded];
    }];
}

- (void)keyboardWillDissapear
{
    self.bottomConstraint.constant = 0;
    
    __weak typeof(self) controller = self;
    [UIView animateWithDuration:0.2 animations:^{
        
        [controller.view layoutIfNeeded];
    }];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    static CommentCell *sizingCell = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:COMMENT_CELL_ID];
    });
    
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (void)configureBasicCell:(CommentCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = self.comments[indexPath.row];
    
    cell.commentLabel.text = comment.text;// @"There is a very long comment. Or not so long";
    cell.authorLabel.text = comment.username;
    cell.dateLabel.text = [comment.createdAt formattedString];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(CommentCell *)sizingCell
{
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:COMMENT_CELL_ID forIndexPath:indexPath];
    
    [self configureBasicCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 147.f;
}

#pragma mark - Action

- (void)backButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendButtonPressed:(id)sender
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
    
    text = [self.theTextField text];
    self.sendButton.enabled = NO;
    
    if (!text.length)
    {
        return;
    }
    
    self.theTextField.text = nil;
    
    __weak typeof(self) controller = self;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"userId"] = [PFUser currentUser].objectId;
    params[@"postId"] = self.post.objectId;
    params[@"text"] = text;
    params[@"displayName"] = [PFUser currentUser][kPFUserKeyDisplayName];
    
    self.hud = [[SAMHUDView alloc] init];
    [self.hud show];
    
    [PFCloud callFunctionInBackground:@"saveComment"
                       withParameters:params
                                block:^(PF_NULLABLE_S id object, NSError *PF_NULLABLE_S error)
     {
         BOOL status = [object[@"commentStatus"] boolValue];
         
         if (status)
         {
             HLComment *comment = object[@"object"];
             
             [Comment createOrUpdateCommentsInBackground:@[comment] completion:^(BOOL success, NSError *error) {
                 
                 [controller getComments];
             }];

         }
         
         [controller.hud dismissAnimated:YES];
     }];
}

@end
