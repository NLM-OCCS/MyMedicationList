//
//  ReceivedMedicationViewController.h
//  MyMedList
//
//  Created by Andrew on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonData.h"
#import "DetailedMedicationCell.h"
#import "ShortMedicationCell.h"
#import "MedicationList.h"

@protocol ReceivedMedicationDelegate;

@interface ReceivedMedicationViewController : UITableViewController

@property (nonatomic, copy) NSString *receivedMedicationListName;
@property (nonatomic, retain) MedicationList *currentMedications;
@property (nonatomic, retain) MedicationList *discontinuedMedications;
@property (nonatomic, retain) MedicationList *prescribedMedications;
@property (nonatomic, assign) id<ReceivedMedicationDelegate> delegate;

//- (void)updateCurrentMedications;

@end

@protocol ReceivedMedicationDelegate <NSObject>

@required
- (void)receivedMedicationViewControllerDidDismiss:(ReceivedMedicationViewController *)receivedMedicationViewController;

@end

