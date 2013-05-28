//
//  UIContextAlertView.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol UIContextAlertDelegate;

@interface UIContextAlertView : UIAlertView
@property (retain,nonatomic) id context;

- (id)initWithTitle:(NSString *)title message:(NSString *)message context:(id)context delegate:(id /*<UIContextAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end

@protocol UIContextAlertDelegate <NSObject>

- (void)contextAlertView:(UIContextAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
