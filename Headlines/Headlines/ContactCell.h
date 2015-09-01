//
//  ContactCell.h
//  Headlines


#import <UIKit/UIKit.h>

@protocol ContactCellDelegate;

@interface ContactCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *contactNameLbl;
@property (nonatomic, weak) IBOutlet UILabel *contactEmailLbl;
@property (nonatomic, weak) IBOutlet UIButton *inviteBtn;

@property (nonatomic, weak) id<ContactCellDelegate> delegate;

- (void)configureCellWithContact:(NSDictionary *)person;

@end

@protocol ContactCellDelegate <NSObject>

- (void)didTappedInviteBtnForCell:(ContactCell *)cell;

@end