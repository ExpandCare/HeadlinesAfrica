//
//  UIFont+Consended.m
//  Headlines
//
//

#import "UIFont+Consended.h"

@implementation UIFont (Consended)

+ (UIFont *)consendedWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
    return [UIFont fontWithName:@"HelveticaNeueLTW1G-Cn" size:size];
}

+ (UIFont *)mediumConsendedWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
    return [UIFont fontWithName:@"HelveticaNeueLTW1G-MdCn" size:size];
}

+ (NSString *)consendedName
{
    return @"HelveticaNeue";
}

+ (NSString *)mediumConsendedName
{
    return @"HelveticaNeue-Bold";
}

+ (UIFont *)lightConsendedWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Thin" size:size];
    return [UIFont fontWithName:@"HelveticaNeueLTW1G-LtCn" size:size];
}

@end
