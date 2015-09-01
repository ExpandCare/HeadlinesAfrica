//
//  ContactCell.m
//  Headlines


#import "ContactCell.h"

@interface ContactCell()

- (IBAction)inviteButtonPressed:(id)sender;

@end

@implementation ContactCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.inviteBtn.hidden = NO;
}

#pragma mark - Public

- (void)configureCellWithContact:(NSDictionary *)person
{
    self.contactNameLbl.text = person[@"name"];
    self.contactEmailLbl.text = person[@"email"];
    
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
