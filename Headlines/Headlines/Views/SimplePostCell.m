//
//  SimplePostCell.m
//  Headlines
//
//

#import "SimplePostCell.h"
#import "Constants.h"
#import "UIFont+Consended.h"

#define IMAGE_BOTTOM_CONSTRAINT 6
#define TITLE_BOTTOM_CONSTRAINT 10

@implementation SimplePostCell

- (void)awakeFromNib
{
    [self.authorLabel setFont:[UIFont consendedWithSize:14]];
    [self.dateLabel setFont:[UIFont consendedWithSize:14]];
    [self.titleLabel setFont:[UIFont mediumConsendedWithSize:18]];
    
    //self.titleLabel.minimumScaleFactor = 0.5;
    //self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.postImageView.clipsToBounds = YES;
    
    [self loadBanners];
}

- (void)removeBanner
{
    [self.bannerView removeFromSuperview];
    self.bannerView = nil;
    
    self.imageBottomConstraint.constant = IMAGE_BOTTOM_CONSTRAINT;
    self.textBottomConstraint.constant = TITLE_BOTTOM_CONSTRAINT;
    
    [self layoutIfNeeded];
}

- (void)loadBanners
{
    if (self.smallBanner)
    {        
        self.smallBanner.adUnitID = @"ca-app-pub-7204105635035592/3354045064";
        self.smallBanner.rootViewController = [[UIApplication sharedApplication].delegate window].rootViewController;
        [self.smallBanner loadRequest:[GADRequest request]];
        self.smallBanner.autoloadEnabled = NO;
    }
    
    if (self.bigBanner)
    {
        self.bigBanner.adUnitID = @"ca-app-pub-7204105635035592/3354045064";
        self.bigBanner.rootViewController = [[UIApplication sharedApplication].delegate window].rootViewController;
        [self.bigBanner loadRequest:[GADRequest request]];
        self.bigBanner.autoloadEnabled = NO;
    }
}

- (void)addBanner:(GADBannerView *)banner big:(BOOL)isBig
{
    banner.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.imageBottomConstraint.constant = IMAGE_BOTTOM_CONSTRAINT + (isBig ? BIG_BANNER_HEIGHT : BANNER_HEIGHT);
    self.textBottomConstraint.constant = TITLE_BOTTOM_CONSTRAINT + (isBig ? BIG_BANNER_HEIGHT : BANNER_HEIGHT);
    
    [self addSubview:banner];
    
    [banner addConstraint:[NSLayoutConstraint constraintWithItem:banner
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1
                                                        constant:(isBig ? BIG_BANNER_HEIGHT : BANNER_HEIGHT)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:banner
                                                       attribute:NSLayoutAttributeRight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self
                                                       attribute:NSLayoutAttributeRight
                                                      multiplier:1
                                                        constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:banner
                                                       attribute:NSLayoutAttributeLeft
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self
                                                       attribute:NSLayoutAttributeLeft
                                                      multiplier:1
                                                        constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:banner
                                                       attribute:NSLayoutAttributeBottom
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self
                                                       attribute:NSLayoutAttributeBottom
                                                      multiplier:1
                                                        constant:0]];
    
    [self layoutIfNeeded];
}

@end
