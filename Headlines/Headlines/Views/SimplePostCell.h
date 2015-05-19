//
//  SimplePostCell.h
//  Headlines
//
//

#import <UIKit/UIKit.h>

@interface SimplePostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottomConstraint;
@property (weak, nonatomic) IBOutlet GADBannerView *smallBanner;
@property (weak, nonatomic) IBOutlet GADBannerView *bigBanner;

@property (strong, nonatomic) GADBannerView *bannerView;

- (void)addBanner:(GADBannerView *)banner big:(BOOL)isBig;
- (void)removeBanner;

@end
