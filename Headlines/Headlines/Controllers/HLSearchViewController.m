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

static NSString * const kSearchTableViewCellIdentifier = @"searchTableViewCellIdentifier";

@interface HLSearchViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SAMHUDView *hud;
@property (nonatomic, strong) HLPost *selectedPost;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *searchBtn;

@end

@implementation HLSearchViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"search results", nil);
    
    [((HLNavigationController *)self.navigationController) setBlueColor];
    
    [self configureBackButtonWhite:YES];
    
    __weak typeof(self) weakSelf = self;
    
    NSDictionary *params = @{
                              @"keyword" : self.searchString
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
