//
//  UITapRectGestureRecognizer.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "UITapRectGestureRecognizer.h"

@interface UITapRectGestureRecognizer () <UIGestureRecognizerDelegate> {
    
    CGFloat X1; // left boundary x
    CGFloat X2; // right boundary x
    CGFloat Y1; // upper boundary y
    CGFloat Y2; // lower boundary y
}

@end

@implementation UITapRectGestureRecognizer
@synthesize touchRect=_touchRect;

- (id)initWithTarget:(id)target action:(SEL)action rect:(CGRect)touchRect
{
    self = [super initWithTarget:target action:action];
    if(self)
    {
        self.touchRect = touchRect;
        self.numberOfTapsRequired = 1;
        self.numberOfTouchesRequired = 1;
        
        self.delegate = self;
    }
    
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action
{
    return [self initWithTarget:target action:action rect:CGRectNull];
}


// We require there only be one touch on the view during tap
- (void)setNumberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired
{
    [super setNumberOfTouchesRequired:1];
}

- (void)setTouchRect:(CGRect)touchRect
{
    _touchRect = touchRect;
    X1 = touchRect.origin.x;
    X2 = touchRect.origin.x + touchRect.size.width;
    Y1 = touchRect.origin.y;
    Y2 = touchRect.origin.y + touchRect.size.height;
}

// Determines whether the touch occured in within the touchRect
- (BOOL)isInRect:(UITouch *)touch
{
    if(CGRectIsNull(self.touchRect))
        return NO;
    
    CGPoint touchLocation = [touch locationInView:self.view];
    CGFloat touchX = touchLocation.x;
    CGFloat touchY = touchLocation.y;
    
    if(((touchX >= X1)&&(touchX <= X2))&&
       ((touchY >= Y1)&&(touchY <= Y2)))  
        return YES;
    else
        
        return NO;
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
 
    if([self isInRect:touch])
        return YES;
    else
        return NO;
}

@end
