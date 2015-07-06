//
//  SearchCell.m
//  Headlines


#import "SearchCell.h"

@implementation SearchCell

- (void)configureCellWithTitle:(NSString *)title content:(NSString *)content
{
    self.titleLbl.text = title;
    self.contentLbl.text = content;
}

- (CGFloat)calculateHeight
{
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];

    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.titleLbl.text = nil;
    self.contentLbl.text = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentLbl setNeedsLayout];
    [self.contentLbl layoutIfNeeded];
    
    [self.titleLbl setNeedsLayout];
    [self.titleLbl layoutIfNeeded];
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
