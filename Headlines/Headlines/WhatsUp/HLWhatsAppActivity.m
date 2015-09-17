//
//  HLWhatsUpActivity.m
//  Headlines
//
//

#import "HLWhatsAppActivity.h"
#import "NSString+URLEncoding.h"

@interface HLWhatsAppActivity ()

@property (copy, nonatomic) NSArray *items;

@end

@implementation HLWhatsAppActivity

- (NSString *)activityType
{
    return @"WhatsApp";
}

- (NSString *)activityTitle
{
    return @"WhatsApp";
}

-(UIImage *)activityImage
{
    return [UIImage imageNamed:@"ic_whatsapp"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    self.items = activityItems;
    
    if (!self.items.count)
    {
        return NO;
    }
    
    NSURL *whatsappURL = [NSURL URLWithString:@"whatsapp://send?text=Hello%2C%20World!"];
    
    return [[UIApplication sharedApplication] canOpenURL:whatsappURL];
}


- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }

- (void)performActivity
{
    NSMutableString *text = nil;
    NSURL *link = nil;
    
    for (id item in self.items)
    {
        if ([item isKindOfClass:[NSString class]])
        {
            text = [[NSMutableString alloc] initWithString:item];
        }
        if ([item isKindOfClass:[NSURL class]])
        {
            link = item;
        }
    }
    
    if (!text.length)
    {
        text = [NSMutableString new];
    }
    
    if (link)
    {
        [text appendString:[NSString stringWithFormat:@"\n%@", [link absoluteString]]];
    }
    
    NSString *message = [NSString stringWithFormat:@"whatsapp://send?text=%@", [text encodedString]];
    
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    
    NSURL *whatsappURL = [NSURL URLWithString:message];
   
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL])
    {
        [[UIApplication sharedApplication] openURL: whatsappURL];
        
        [self activityDidFinish:YES];
    }
    else
    {
        [self activityDidFinish:NO];
    }
}

@end
