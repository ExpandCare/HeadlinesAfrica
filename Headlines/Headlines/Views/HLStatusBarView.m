//
//  HLStatusBarView.m
//  Headlines
//
//

#import "HLStatusBarView.h"
#import "AppDelegate.h"
#import "HLWindow.h"

@interface HLStatusBarView ()

@property (strong, nonatomic) UIWindow *theWindow;
@property (strong, nonatomic) HLWindow *tapWindow;

@end

@implementation HLStatusBarView

- (void)present
{
    static UIImage *statusBarImage;
    
    if (!statusBarImage)
    {
        statusBarImage = [[UIImage imageNamed:@"status_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    
    self.theWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), statusBarImage.size.height)];
    self.theWindow.windowLevel = UIWindowLevelNormal;
    
    self.tapWindow = [[HLWindow alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), statusBarImage.size.height)];
    self.tapWindow.windowLevel = UIWindowLevelStatusBar;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:statusBarImage];
    imgView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), statusBarImage.size.height);
    self.theWindow.userInteractionEnabled = NO;
    
    [self.theWindow makeKeyAndVisible];
    [self.tapWindow makeKeyAndVisible];
    
    [self.theWindow addSubview:imgView];
    
    ((AppDelegate *)[UIApplication sharedApplication].delegate).statusBarWindow = self.theWindow;
    
    [self.theWindow addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    
    self.theWindow.userInteractionEnabled = YES;
    imgView.userInteractionEnabled = YES;
    self.userInteractionEnabled = YES;
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    
}

@end
