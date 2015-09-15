//
//  HLTermsAndPrivacyViewController.h
//  Headlines


#import <UIKit/UIKit.h>
#import "HLViewController.h"

typedef NS_ENUM(NSInteger, HLContentType)
{
    HLContentTypeTerms   = 0,
    HLContentTypePrivacy = 1,
    HLContentTypeAboutUs = 2
};

@interface HLTermsAndPrivacyViewController : HLViewController

@property (nonatomic, assign) HLContentType currentContentType;

@end
