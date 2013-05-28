//
//  ModalMedicationSearchViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "MedDetailInfoViewController.h"
#import "MMLPersonData.h"

@protocol ModalMedicationSearchDelegate;

@interface ModalMedicationSearchViewController : UITableViewController

@property (retain,nonatomic) MMLPersonData *personData; // Only passed here to hand off to ModalMedicationInfo controller to check ingredient for OD
@property (assign,nonatomic) id <ModalMedicationSearchDelegate> delegate;
@property (assign,nonatomic) id <MedDetailInfoDelegate> dataDelegate;
@end
