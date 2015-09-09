//
//  HLSettingsCell.m
//  Headlines


#import "HLSettingsCell.h"

@interface HLSettingsCell()

@property (nonatomic, weak) IBOutlet UIImageView *customAccessoryImgView;
@property (nonatomic, weak) IBOutlet UILabel *titleLbl;

@end

@implementation HLSettingsCell

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureWithColor:(HLSettingsCellTextColor)textColor text:(NSString *)text accessoryView:(BOOL)isNeedToShowAccessory
{
    if(textColor == HLSettingsCellTextColorBlack)
    {
        [self.titleLbl setTextColor:[UIColor blackColor]];
    }
    else if (textColor == HLSettingsCellTextColorBlue)
    {
         [self.titleLbl setTextColor:[UIColor colorWithRed:0.09 green:0.6 blue:0.84 alpha:1]];
    }
    else if (textColor == HLSettingsCellTextColorRed)
    {
        [self.titleLbl setTextColor:[UIColor colorWithRed:0.93 green:0.15 blue:0.2 alpha:1]];
    }
    
    if(isNeedToShowAccessory)
    {
        self.customAccessoryImgView.hidden = NO;
    }
    else
    {
        self.customAccessoryImgView.hidden = YES;
    }
    
    self.titleLbl.text = text;
    
}

@end
