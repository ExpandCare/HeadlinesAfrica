//
//  NSString+HTMLAdditions.m
//  Headlines
//
//

#import "NSString+HTMLAdditions.h"
#import "UIFont+Consended.h"
#import "NSString+URLEncoding.h"
#import <MWFeedParser/NSString+HTML.h>
#import <SDWebImage/SDWebImageManager.h>

@implementation NSString (HTMLAdditions)

- (NSString *)htmlStringWithTitle:(NSString *)title
                           author:(NSString *)author
                           source:(NSString *)source
                          country:(NSString *)country
                             date:(NSString *)dateString
                         imageURL:(NSString *)imageURL
{
    if ([author isEqualToString:source])
    {
        author = @"";
    }
    
    NSString *result;
    
    NSString *template = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"template"
                                                                                            ofType:@"html"]
                                                   encoding:NSUTF8StringEncoding error:nil];
    
    //NSString *strWithoutAMP = [self stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    NSMutableString *changedContent = [[self stringByDecodingHTMLEntities] mutableCopy];
    
    NSData *data      = [[self stringByDecodingHTMLEntities] dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *doc       = [[TFHpple alloc] initWithHTMLData:data];
    
    NSString *firstIMGTag = nil, *firstTag = nil;
    BOOL ftFounded = NO, fiFounded = NO;
    
    
    for (NSString *tag in @[@"//img", @"//span", @"//p", @"//div", @"//a"])
    {
        NSArray *elements  = [doc searchWithXPathQuery:tag]; //@"//a[@class='sponsor']"
        
        for (TFHppleElement *e in elements)
        {
            for (NSString *key in [e.attributes allKeys])
            {
                if ([tag isEqualToString:@"//img"])
                {
                    if (!firstIMGTag)
                    {
                        firstIMGTag = [e raw];
                    }
                    
                    if ([key isEqualToString:@"src"])
                    {
                        NSString *attr = e.attributes[key];
                        
                        [changedContent replaceOccurrencesOfString:attr withString:[attr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] options:NSCaseInsensitiveSearch range:NSMakeRange(0, changedContent.length)];
                    }
                    if ([key isEqualToString:@"width"] || [key isEqualToString:@"height"])
                    {
                        NSString *attr = e.attributes[key];
                        
                        [changedContent replaceOccurrencesOfString:[NSString stringWithFormat:@"=\"%@\"", attr] withString:@"=\"\"" options:NSCaseInsensitiveSearch range:[changedContent rangeOfString:changedContent]];
                        
                        if (!fiFounded && firstIMGTag.length)
                        {
                            firstIMGTag = [firstIMGTag stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"=\"%@\"", attr] withString:@"=\"\""];
                        }
                    }
                }
                else
                {
                    if (!firstTag)
                    {
                        firstTag = [e raw];
                    }
                    
                    if ([key isEqualToString:@"style"])
                    {
                        NSString *attr = e.attributes[key];
                        
                        [changedContent replaceOccurrencesOfString:attr withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, changedContent.length)];
                        
                        if (!ftFounded && firstTag.length)
                        {
                            firstTag = [firstTag stringByReplacingOccurrencesOfString:attr withString:@""];
                        }
                    }
                }
            }
            
            if (firstIMGTag.length)
            {
                fiFounded = YES;
            }
            if (firstTag.length)
            {
                ftFounded = YES;
            }
        }
    }
    
    NSString *emptyTag = [NSString stringWithFormat:@"<div id=\"slsElement\"; style=\"min-height: %fpx;\"></div>", (float)(BANNER_HEIGHT + 20)];
    
    NSString *titleImageCatalog = [[imageURL componentsSeparatedByString:@"/"] lastObject];
    titleImageCatalog = [imageURL stringByReplacingOccurrencesOfString:titleImageCatalog withString:@""];
    
    if (titleImageCatalog.length && ![source isEqualToString:@"Vibeghana"] && [changedContent rangeOfString:titleImageCatalog].location == NSNotFound && imageURL.length)
    {
        if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:imageURL]])
        {
            NSLog(@"");
        }
        
        NSString *imgTag= [NSString stringWithFormat:@"<img src=\"%@\"/>", imageURL.URLWithoutQueryParameters];
        emptyTag = [NSString stringWithFormat:@"%@%@", emptyTag, imgTag];
    }
    
    [changedContent insertString:emptyTag atIndex:0];
    
    result = [NSString stringWithFormat:template, source, title, author, dateString, country, changedContent];
    
    return result;
}

- (NSString *)stringByRemovingURLShit
{
    NSString *result = [self copy];
    
    result = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                   (__bridge CFStringRef)result,
                                                                                                   CFSTR(""),
                                                                                                   CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return result;
}

- (NSString *)stringWithURLShit
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                    (CFStringRef)self,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8 ));
    
    return encodedString;
}


@end
