//
//  HLNavigationController.m
//  Headlines
//
//

#import "HLNavigationController.h"
#import "Constants.h"
#import "UIFont+Consended.h"

@interface HLNavigationController ()

@end

@implementation HLNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIFont *font = [UIFont mediumConsendedWithSize:25];
    
    NSDictionary *navbarTitleTextAttributes = @{NSFontAttributeName: font};
    
    [self.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    [self.navigationBar setTitleVerticalPositionAdjustment:2 forBarMetrics:UIBarMetricsDefault];
}

- (void)setBlueColor
{
    UIFont *font = [UIFont mediumConsendedWithSize:24];
    
    NSDictionary *navbarTitleTextAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    self.navigationBar.barTintColor = [UIColor colorWithRed:0.02 green:0.62 blue:0.85 alpha:1];
    [self.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
}

- (void)setWhiteColor
{
    UIFont *font = [UIFont mediumConsendedWithSize:24];
    
    NSDictionary *navbarTitleTextAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor blackColor]};
    
    self.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    [self.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbarIMG"] resizableImageWithCapInsets:UIEdgeInsetsZero]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (void)makeBarTransparent
{
    static UIImage *whiteGradient;
    
    if (!whiteGradient)
    {
        whiteGradient = [UIImage imageNamed:@"img_gradient_top"];
    }
    
    [self.navigationBar setBackgroundImage:[whiteGradient resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, whiteGradient.size.height - 1, 5)]
                            forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationBar.backgroundColor = [UIColor clearColor];
    
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (void)makebarCompletelyTranparent
{
    [self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)setDefault
{
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
}

@end