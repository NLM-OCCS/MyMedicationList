//
//  ModalMedicationSearchDelegate.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "Medication.h"

//@class ModalMedicationSearchViewController;

@protocol ModalMedicationSearchDelegate <NSObject>

@required 
- (void)modalSearchViewController:(UIViewController *)medSearchController didSelectMedication:(Medication *)medication;
- (void)modalSearchViewControllerDidCancel:(UIViewController *)medSearchController;

@end
