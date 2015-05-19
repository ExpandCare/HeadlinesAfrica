//
//  NSString+EmailValidation.m
//  Headlines
//
//

#import "NSString+EmailValidation.h"

@implementation NSString (EmailValidation)

- (BOOL)emailIsCorrect
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}

@end
