//
//  FreeEntryTextViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "MMLPersonData.h"
#import "MedDetailInfoViewController.h"

@interface FreeEntryTextViewController : UITableViewController
@property (nonatomic,retain) NSString *medName;
@property (nonatomic,assign) MMLPersonData *person;

@property (assign) id<MedDetailInfoDelegate> dataDelegate;
@end
