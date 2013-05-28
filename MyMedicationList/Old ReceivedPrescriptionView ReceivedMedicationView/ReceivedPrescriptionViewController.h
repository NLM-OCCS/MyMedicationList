//
//  ReceivedPrescriptionViewController.h
//  MyMedList
//
//  Created by Andrew on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersonData, MedicationList;
@protocol ReceivedPrescriptionDelegate;

@interface ReceivedPrescriptionViewController : UITableViewController

@property (nonatomic, assign) id<ReceivedPrescriptionDelegate> delegate;
//@property (nonatomic, assign) BOOL isFromMainMedList;
@property (nonatomic, assign) BOOL isFromImport;
@property (nonatomic, copy) NSString *receivedMedicationListName;
@property (nonatomic, retain) PersonData *personData;
@property (nonatomic, retain) NSMutableArray *currentMedications;
@property (nonatomic, retain) NSMutableArray *discontinuedMedications;
@property (nonatomic, retain) NSMutableArray *prescribedMedications;

@end

@protocol ReceivedPrescriptionDelegate <NSObject>

@required
- (void)receivedPrescriptionViewControllerDidDismiss:(ReceivedPrescriptionViewController *)receivedPrescriptionViewController;

@end
