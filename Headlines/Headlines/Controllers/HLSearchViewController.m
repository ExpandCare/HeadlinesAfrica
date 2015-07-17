//
//  HLSearchViewController.m
//  Headlines
//
//  Created by Алексей Поляков on 06.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import "HLSearchViewController.h"
#import "HLNavigationController.h"
#import "SearchCell.h"
#import "HLPost.h"
#import "NSString+HTML.h"
#import <SAMHUDView/SAMHUDView.h>
#import "HLPostDetailViewController.h"
#import "HLSearchTextField.h"
#import "DAKeyboardControl.h"
#import "AppDelegate.h"

#define CELL_NO_RESULTS @"CELL_NO_RESULTS"

static NSString * const kSearchTableViewCellIdentifier = @"searchTableViewCellIdentifier";

@interface HLSearchViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SAMHUDView *hud;
@property (nonatomic, strong) HLPost *selectedPost;
@property (nonatomic, strong) IBOutlet UIView *searchView;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewBottomSpacingConstraint;
@property (nonatomic, weak) IBOutlet UILabel *noResultsLbl;

@end

@implementation HLSearchViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self.searchTextField valueForKey:@"textInputTraits"] setValue:[UIColor whiteColor] forKey:@"insertionPointColor"];
    
    [self cancelSearchAction];
    
    self.title = NSLocalizedString(@"search results", nil);
    
    [((HLNavigationController *)self.navigationController) setBlueColor];
    
    [self configureBackButtonWhite:YES];
    
    [self makeSearchWithText:self.searchString];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    
    [self.view addKeyboardPanningWithFrameBasedActionHandler:nil
                                constraintBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing)
     {
         static CGFloat y;
         
         if (opening || y == 0)
         {
             y = keyboardFrameInView.origin.y + keyboardFrameInView.size.height;
         }
         
         if (closing)
         {
             weakSelf.tableViewBottomSpacingConstraint.constant = 0;
         }
         else
         {
             weakSelf.tableViewBottomSpacingConstraint.constant = y - keyboardFrameInView.origin.y;
         }
         
     }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view removeKeyboardControl];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
     self.tableView.userInteractionEnabled = YES;
}


#pragma mark - Private

- (void)hideShowNoResultsLbl
{
    if(self.searchResults.count > 0)
    {
        self.noResultsLbl.hidden = YES;
    }
    else
    {
        self.noResultsLbl.hidden = NO;
    }
}

- (void)cancelSearchAction
{
    self.title = NSLocalizedString(@"search results", nil);
    self.navigationItem.titleView = nil;
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonAction:)];
    [searchItem setTintColor:[UIColor whiteColor]];
    [searchItem setBackgroundVerticalPositionAdjustment:1.5 forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = searchItem;
    self.searchTextField.text = nil;
}

- (void)searchButtonAction:(id)sender
{
    self.title = nil;
    self.navigationItem.titleView = self.searchView;
    UIBarButtonItem *stopItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelSearchAction)];
    [stopItem setTintColor:[UIColor whiteColor]];
    [stopItem setBackgroundVerticalPositionAdjustment:1.5 forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = stopItem;
    
    [self.searchTextField becomeFirstResponder];
    
}

- (void)makeSearchWithText:(NSString *)searchText
{
    __weak typeof(self) weakSelf = self;
    
    NSDictionary *params = @{
                             @"keyword" : searchText,
                             @"limit"   : @(50)
                             };
    
    self.hud = [[SAMHUDView alloc] initWithTitle:NSLocalizedString(@"Searching", nil)];
    [self.hud show];
    
    [PFCloud callFunctionInBackground:@"searchPost"
                       withParameters:params
                                block:^(PF_NULLABLE_S id object, NSError *PF_NULLABLE_S error)
     {
         if(!error)
         {
             weakSelf.searchResults = [NSArray arrayWithArray:object[@"posts"]];
             [weakSelf.tableView reloadData];
             [weakSelf hideShowNoResultsLbl];
             [weakSelf.hud completeAndDismissWithTitle:NSLocalizedString(@"Success", nil)];
         }
         else
         {
             [weakSelf.hud failAndDismissWithTitle:NSLocalizedString(@"Failed", nil)];
         }
         
     }];

}

#pragma mark - Actions

- (void)backButtonPressed:(UIButton *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view hideKeyboard];
    
    if(!textField.text.length)
    {
        SHOW_ALERT_WITH_TITLE_AND_MESSAGE(@"", NSLocalizedString(@"Please, enter search phrase", nil));
        return NO;
    }
    
    if(!IS_INTERNET_CONNECTED)
    {
        SHOW_INTERNET_FAILED_ALERT;
        return NO;
    }
    
    [self makeSearchWithText:textField.text];
    
    return NO;
}

#pragma mark - UITableView datasource and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchTableViewCellIdentifier];
    [cell configureCellWithTitle:((HLPost *)self.searchResults[indexPath.row]).title content:[((HLPost *)self.searchResults[indexPath.row]).content stringByConvertingHTMLToPlainText]];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.searchResults.count == 0)
    {
        return 200.0f;
    }
    
    static SearchCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [tableView dequeueReusableCellWithIdentifier:kSearchTableViewCellIdentifier];
    });
    
    [sizingCell configureCellWithTitle:((HLPost *)self.searchResults[indexPath.row]).title content:[((HLPost *)self.searchResults[indexPath.row]).content stringByConvertingHTMLToPlainText]];
    return [sizingCell calculateHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedPost = self.searchResults[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    
    tableView.userInteractionEnabled = NO;
    
    [Post createOrUpdatePostsInBackground:@[self.selectedPost] completion:^(BOOL success, NSError *error)
    {
       if(!error)
       {
           [weakSelf performSegueWithIdentifier:@"toPostDetailController" sender:weakSelf];
       }
    }];
    
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toPostDetailController"])
    {
        ((HLPostDetailViewController *)segue.destinationViewController).isSearchPost = YES;
        ((HLPostDetailViewController *)segue.destinationViewController).postID = self.selectedPost.objectId;
    }
}

@end
