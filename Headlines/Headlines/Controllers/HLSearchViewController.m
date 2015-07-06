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

static NSString * const kSearchTableViewCellIdentifier = @"searchTableViewCellIdentifier";

@interface HLSearchViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation HLSearchViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [((HLNavigationController *)self.navigationController) setBlueColor];
    
    [self configureBackButtonWhite:YES];
    
    __weak typeof(self) weakSelf = self;
    
    NSDictionary *params = @{
                              @"keyword" : self.searchString
                            };
    
    [PFCloud callFunctionInBackground:@"searchPost"
                       withParameters:params
                                block:^(PF_NULLABLE_S id object, NSError *PF_NULLABLE_S error)
    {
        if(!error)
        {
            weakSelf.searchResults = [NSArray arrayWithArray:object[@"posts"]];
            [weakSelf.tableView reloadData];
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

@end
