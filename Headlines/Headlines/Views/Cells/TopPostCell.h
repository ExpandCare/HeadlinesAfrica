//
//  TopPostCell.h
//  Headlines
//
//

#import <UIKit/UIKit.h>

@interface TopPostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIButton *scrollDownButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

- (void)configureForCategoryScreen:(BOOL)isCategoryNews;

@end
