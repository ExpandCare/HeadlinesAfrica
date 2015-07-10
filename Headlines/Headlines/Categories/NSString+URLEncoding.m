//
//  NSString+URLEncoding.m
//  Headlines
//
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

- (NSString *)encodedString
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)self,
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8 ));
    
    return encodedString;
}

- (NSString *)URLWithoutQueryParameters
{
    NSRange urlLocation = [self rangeOfString:@"?"];
    
    if ([self rangeOfString:@"vibeghana"].location != NSNotFound)
    {
        return self;
    }
    
    if (urlLocation.location == NSNotFound)
    {
        return self;
    }
    
    return [self substringToIndex:urlLocation.location];
}

@end
