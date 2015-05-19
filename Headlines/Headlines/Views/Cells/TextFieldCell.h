//
//  TextFieldCell.h
//  Headlines
//
//

#import <UIKit/UIKit.h>
#import "HLTextField.h"

@interface TextFieldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HLTextField *theTextField;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
