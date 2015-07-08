//
//  NSString+HTMLAdditions.h
//  Headlines
//
//

#import <Foundation/Foundation.h>
#import <hpple/TFHpple.h>

@interface NSString (HTMLAdditions)

- (NSString *)htmlStringWithTitle:(NSString *)title
                           author:(NSString *)author
                           source:(NSString *)source
                          country:(NSString *)country
                             date:(NSString *)dateString
                         imageURL:(NSString *)imageURL;

@end
