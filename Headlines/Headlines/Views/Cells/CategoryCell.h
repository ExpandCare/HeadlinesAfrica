//
//  CategoryCell.h
//  Headlines
//
//

#import <UIKit/UIKit.h>
#import "SBTickerView.h"

@interface CategoryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet SBTickerView *theImageView;
@property (weak, nonatomic) IBOutlet UILabel *theTitleLabel;

@end
