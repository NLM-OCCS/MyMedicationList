//
//  RemindersViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "MMLPersonData.h"
#import "MMLMedication.h"
@interface RemindersViewController : UITableViewController

@property (nonatomic,assign) MMLMedication *medication;

@property (nonatomic,assign) BOOL readOnly;
@property(nonatomic,assign) MMLPersonData *person;
+(BOOL) hasReminders:(int) medicationId;
+(UILocalNotification *) retrieveReminder:(int) medicationId;
+(void ) cancelAllReminders:(int)medicationId;
@end
