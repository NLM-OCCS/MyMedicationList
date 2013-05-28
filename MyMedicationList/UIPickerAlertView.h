//
//  UIPickerAlertView.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>

@class Date;
@protocol UIPickerAlertDelegate;

@interface UIPickerAlertView : UIAlertView

- (id)initWithDelegate:(id <UIPickerAlertDelegate>)delegate;

@end

@protocol UIPickerAlertDelegate <NSObject>

@optional
- (void)pickerAlertViewDidDismiss:(UIPickerAlertView *)pickerAlertView withDate:(Date *)selectedDate;

@end

