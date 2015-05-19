//
//  UIFont+Consended.h
//  Headlines
//
//

#import <UIKit/UIKit.h>

@interface UIFont (Consended)

+ (UIFont *)consendedWithSize:(CGFloat)size;
+ (UIFont *)mediumConsendedWithSize:(CGFloat)size;
+ (UIFont *)lightConsendedWithSize:(CGFloat)size;
+ (NSString *)consendedName;
+ (NSString *)mediumConsendedName;

@end
