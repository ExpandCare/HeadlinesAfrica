//
//  HLViewController.m
//  Headlines
//
//

#import "HLViewController.h"

@interface HLViewController ()

@end

@implementation HLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)configureBackButtonWhite:(BOOL)isWhite
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    backButton.contentEdgeInsets = UIEdgeInsetsMake(8, 0, 4, 22);
    [backButton setImage:[UIImage imageNamed:(isWhite ? @"ic_back_white" : @"ic_back_black")]
                forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(backButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)backButtonPressed:(UIButton *)sender
{
    [self.navigationController dismissViewControllerAnimated:NO completion:NULL];
}

@end
