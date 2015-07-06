//
//  SearchCell.h
//  Headlines


#import <UIKit/UIKit.h>

@interface SearchCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLbl;
@property (nonatomic, weak) IBOutlet UILabel *contentLbl;

- (void)configureCellWithTitle:(NSString *)title content:(NSString *)content;
- (CGFloat)calculateHeight;

@end
