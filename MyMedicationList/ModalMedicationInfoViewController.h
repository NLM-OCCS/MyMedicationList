//
//  ModalMedicationInfoViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>

#import "FreeEntryTextViewController.h"
#import "MMLPersonData.h"
#import "MedDetailInfoViewController.h"

@protocol ModalMedicationSearchDelegate;

@interface ModalMedicationInfoViewController : UITableViewController

@property (nonatomic,copy) NSString *displayName;
@property (retain, nonatomic) MMLPersonData *personData; // Only used to check ingredient for OD
@property (assign) id<ModalMedicationSearchDelegate> delegate;
@property (assign) id<MedDetailInfoDelegate> dataDelegate;
@property (nonatomic,retain) FreeEntryTextViewController *freeTextController;
@property (nonatomic) BOOL approxMatchOn;

@end
