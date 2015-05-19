
#import "NSObject+Celullar.h"
#import <ifaddrs.h>

@implementation NSObject (Celullar)

+ (bool)hasCellular
{
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    bool found = false;
    if (getifaddrs(&addrs) == 0)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
            if ([name isEqualToString:@"pdp_ip0"]) {
                found = true;
                break;
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return found;
}

@end