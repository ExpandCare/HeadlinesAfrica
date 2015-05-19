//
//  HLWindow.m
//  Headlines
//
//

#import "HLWindow.h"

@implementation HLWindow

- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    
    for (UITouch *touch in event.allTouches)
    {
        CGPoint locationPoint = [touch locationInView:touch.view.window];
        
        if (touch.phase == UITouchPhaseBegan && locationPoint.y <= CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]))
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDoubleTap object:nil];
            
            break;
        }
    }
}

@end
