//
//  ContactCell.m
//  Headlines


#import "ContactCell.h"
#import "UIImage+Extentions.h"

@interface ContactCell()

- (IBAction)inviteButtonPressed:(id)sender;

@end

@implementation ContactCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.inviteBtn.hidden = NO;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.inviteBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.55 green:0.78 blue:0.29 alpha:1]] forState:UIControlStateNormal];
    self.inviteBtn.layer.cornerRadius = 9.0f;
    [self.inviteBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f]];
    self.inviteBtn.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    self.inviteBtn.clipsToBounds = YES;
}

#pragma mark - Public

- (void)configureCellWithContact:(NSDictionary *)person
{
    self.contactNameLbl.text = person[@"name"];
    
    if(person[@"email"])
    {
        self.contactEmailLbl.text = person[@"email"];
    }
    else if (person[@"phone"])
    {
        self.contactEmailLbl.text = person[@"phone"];
    }
    
    if([person[@"isRegistered"] intValue] == 1)
    {
        self.inviteBtn.hidden = YES;
    }
}

#pragma mark - IBActions

- (IBAction)inviteButtonPressed:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didTappedInviteBtnForCell:)])
    {
        [self.delegate didTappedInviteBtnForCell:self];
    }
}

@end
