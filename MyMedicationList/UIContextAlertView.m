//
//  UIContextAlertView.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "UIContextAlertView.h"

@interface UIContextAlertView()<UIAlertViewDelegate>
@property (retain,nonatomic) id<UIContextAlertDelegate> localDelegate;

@end

@implementation UIContextAlertView
@synthesize context;
@synthesize localDelegate = _localDelegate;

- (id)initWithTitle:(NSString *)title message:(NSString *)message context:(id)context1 delegate:(id /*<UIContextAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    
    NSLog(@"initWithTitle:context");
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    if(self)
    {
        self.context = context1;
        self.localDelegate = delegate;
        va_list args;
        va_start(args, otherButtonTitles);
        [super addButtonWithTitle:otherButtonTitles];
        NSString * title = nil;
        while((title = va_arg(args,NSString*)) != nil)
            [super addButtonWithTitle:title];
        
        va_end(args);
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc - UIContextAlertView");
    self.context = nil;
    self.localDelegate = nil;
    self.delegate = nil;
    [super dealloc];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alertView:clickedButtonAtIndex:");
    if([_localDelegate respondsToSelector:@selector(contextAlertView:clickedButtonAtIndex:)])
        [_localDelegate contextAlertView:self clickedButtonAtIndex:buttonIndex];
}

@end
