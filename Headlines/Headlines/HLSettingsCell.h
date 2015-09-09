//
//  HLSettingsCell.h
//  Headlines


#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, HLSettingsCellTextColor)
{
    HLSettingsCellTextColorBlack = 1,
    HLSettingsCellTextColorBlue  = 2,
    HLSettingsCellTextColorRed   = 3
};

@interface HLSettingsCell : UITableViewCell


- (void)configureWithColor:(HLSettingsCellTextColor)textColor text:(NSString *)text accessoryView:(BOOL)isNeedToShowAccessory;

@end
