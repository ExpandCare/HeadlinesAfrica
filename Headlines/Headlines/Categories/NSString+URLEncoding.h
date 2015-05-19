//
//  NSString+URLEncoding.h
//  Headlines
//
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)

- (NSString *)encodedString;
- (NSString *)URLWithoutQueryParameters;

@end
