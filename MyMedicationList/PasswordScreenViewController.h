//
//  PasswordScreenViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol PasswordScreenDelegate;

@interface PasswordScreenViewController : UIViewController

@property (assign,nonatomic) id<PasswordScreenDelegate> delegate;

@end


@protocol PasswordScreenDelegate 

@required
- (void)passwordScreenViewControllerDidEnterCorrectPassword:(PasswordScreenViewController *)passwordScreenViewController;

@end
