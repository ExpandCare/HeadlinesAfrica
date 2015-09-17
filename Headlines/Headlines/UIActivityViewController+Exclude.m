//
//  UIActivityViewController+Exclude.m
//  Headlines
//


#import "UIActivityViewController+Exclude.h"
#include <objc/runtime.h>
#include <objc/message.h>

@implementation UIActivityViewController (Exclude)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        SEL originalSelector = @selector(_availableActivitiesForItems:);
        SEL swizzledSelector = @selector(editedItems:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

#pragma mark - Method Swizzling

- (id)editedItems:(id)items
{
    id activities = [self editedItems:items];
    
    NSMutableArray *newActivities = [NSMutableArray new];
    
    for (UIActivity *act in activities)
    {
        
        NSLog(@"%@", act.activityType);
        
        
        if (![act.activityType isEqualToString:@"net.whatsapp.WhatsApp.ShareExtension"])
        {
            [newActivities addObject:act];
        }
    }
    
    NSLog(@"items: %@", items);
    
    return newActivities;
}


@end
