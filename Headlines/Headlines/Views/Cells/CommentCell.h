//
//  CommentCell.h
//  Headlines
//
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
