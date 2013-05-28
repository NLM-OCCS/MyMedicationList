//
//  UIPickerAlertView.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <QuartzCore/QuartzCore.h>
#import "MMLPickerView.h"
#import "UIPickerAlertView.h"
#import "Date.h"
#import "ButtonFactory.h"

@interface UIPickerAlertView () <UIAlertViewDelegate>
@property (retain,nonatomic) id <UIPickerAlertDelegate> delegatePickerAlert;
@property (retain,nonatomic) MMLPickerView *datePickerView;
@end

@implementation UIPickerAlertView
@synthesize delegatePickerAlert = _delegatePickerAlert;
@synthesize datePickerView = _datePickerView;

#define ALERTWIDTH      320
#define ALERTHEIGHT     350

- (id)initWithDelegate:(id <UIPickerAlertDelegate>)delegate
{
    NSLog(@"initWithDelegate: - UIPickerAlertView");
    self = [super initWithTitle:nil//@"This user needs a birthdate, please enter it below" 
                        message:nil 
                       delegate:self 
              cancelButtonTitle:nil 
              otherButtonTitles:nil];
    if(self)
    {
        
        self.delegatePickerAlert = delegate;
        
        self.datePickerView = [[[MMLPickerView alloc] initWithPickerType:DatePicker] autorelease];
        _datePickerView.showsSelectionIndicator = YES;
        _datePickerView.frame = CGRectMake(17, 70, 286, _datePickerView.frame.size.height);//216
        _datePickerView.layer.masksToBounds = YES;
        _datePickerView.layer.cornerRadius = 10.0;
        // Sets the starting year to 2000
        [_datePickerView selectRow:100 inComponent:2 animated:NO];
        
        [self addSubview:_datePickerView];
         
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.textAlignment = UITextAlignmentCenter;
        messageLabel.numberOfLines = 2;
        messageLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:22.0f];//[UIFont systemFontOfSize:20];
        messageLabel.text = @"This user needs a birthdate, please enter it below";
        messageLabel.bounds = CGRectMake(0, 0, ALERTWIDTH-60, 50);
        messageLabel.center = CGPointMake(ALERTWIDTH/2, 36);
        
        [self addSubview:messageLabel];
        [messageLabel autorelease];
        
        UIButton *dismiss = [[ButtonFactory newButtonWithTitle:@"Save" size:CGSizeMake(80, 40)] autorelease];
        [dismiss addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        dismiss.center = CGPointMake(160, 312);
        [self addSubview:dismiss];

    }
    
    return self;
}


- (void)dismiss
{
    NSLog(@"dismiss - UIPickerAlertView");
    [self dismissWithClickedButtonIndex:0 animated:YES];
    
    NSLog(@"self.frame.origin.x = %f",self.frame.origin.x);
    NSLog(@"self.frame.origin.y = %f",self.frame.origin.y);
    NSLog(@"self.frame.size.width = %f",self.frame.size.width);
    NSLog(@"self.frame.size.height = %f",self.frame.size.height);    
    
    if([_delegatePickerAlert respondsToSelector:@selector(pickerAlertViewDidDismiss:withDate:)])
        [_delegatePickerAlert pickerAlertViewDidDismiss:self withDate:[_datePickerView selectedDate]];
}

/*
- (id)initWithFrame:(CGRect)frame {
    NSLog(@"initWithFrame: - UIPickerAlertView");
	if (self = [super initWithFrame:frame]) {
        
	}
    NSLog(@"End of initWithFrame");
	return self;
}
 */

/*
- (void)setFrame:(CGRect)rect {
    NSLog(@"setFrame: - UIPickerAlertView");
	[super setFrame:CGRectMake(0, 0, 320, 350)];
	self.center = CGPointMake(320/2, 280);
}
 */

- (void)willPresentAlertView:(UIAlertView *)alertView {
    //alertView.frame = CGRectMake(5.f, 1.f, 100.f, 200.f);
    NSLog(@"willPresentAlertView");
//    CGPoint alertViewCenter = alertView.center;
//    alertView.frame = CGRectMake(0, 0, 320, 350);
    alertView.bounds = CGRectMake(0, 0, ALERTWIDTH, ALERTHEIGHT);
    //alertView.center = CGPointMake(320/2, 280);
//    alertView.center = alertViewCenter;
}

@end
