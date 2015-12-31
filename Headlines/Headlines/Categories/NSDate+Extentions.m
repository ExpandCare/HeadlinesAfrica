//
//  NSDate+Extentions.m
//  Headlines
//
//

#import "NSDate+Extentions.h"

@implementation NSDate (Extentions)

- (NSString *)formattedString
{
    static NSDateFormatter *formatter;
    
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        //formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        formatter.dateFormat = @"dd MMMM yyyy";
    }
    
    return [formatter stringFromDate:self];
}

@end
