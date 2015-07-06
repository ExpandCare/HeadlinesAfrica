//
//  HLSearchViewController.m
//  Headlines
//
//  Created by Алексей Поляков on 06.07.15.
//  Copyright (c) 2015 Cleveroad. All rights reserved.
//

#import "HLSearchViewController.h"
#import "HLNavigationController.h"

@interface HLSearchViewController ()

@end

@implementation HLSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [((HLNavigationController *)self.navigationController) setBlueColor];
    
    [self configureBackButtonWhite:YES];
}

#pragma mark - Actions

- (void)backButtonPressed:(UIButton *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
