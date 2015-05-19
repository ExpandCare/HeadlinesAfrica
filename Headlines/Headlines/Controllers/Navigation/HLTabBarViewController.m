//
//  HLTabBarViewController.m
//  Headlines
//
//

#import "HLTabBarViewController.h"
#import "Constants.h"

#define IMAGE_INSET 5

@interface HLTabBarViewController ()

@end

@implementation HLTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tabBar setSelectedImageTintColor:HEADLINES_BLUE];
    
    for (UITabBarItem *item in self.tabBar.items)
    {
        item.imageInsets = UIEdgeInsetsMake(IMAGE_INSET, 0, -IMAGE_INSET, 0);
    }
    
    [self.tabBar setBackgroundImage:[[UIImage imageNamed:@"navbarIMG2"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [self configureTabBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureTabBar];
}

-(void)configureTabBar
{
    UITabBar *tabBar = self.tabBar;
    
    for (UITabBarItem *tab in tabBar.items)
    {
        tab.image = [tab.image imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    }
}

@end
