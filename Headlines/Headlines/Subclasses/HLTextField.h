//
//  HLTextField.h
//  Headlines
//
//

#import <UIKit/UIKit.h>

@protocol HLTextFieldDelegate <NSObject>

- (void)textFieldIsActive;
- (void)textFieldIsInactive;

@end

@interface HLTextField : UITextField

@property (weak, nonatomic) id <HLTextFieldDelegate> HLTextFieldDelegate;

@end
