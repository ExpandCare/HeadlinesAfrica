//
//  ButtonCell.h
//  Headlines
//
//

#import <UIKit/UIKit.h>

@interface ButtonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *theButton;

@property (assign, nonatomic) BOOL isActive;

@end
