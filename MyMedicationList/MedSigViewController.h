//
//  MedSigViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "MedicationAmount.h"
#import "MedicationInstruction.h"
#import "MedicationFrequency.h"


@class MedSigViewController;

@protocol MedSigProtocol <NSObject>

@optional
- (void) medSigResponse:(MedSigViewController *)inView withFrequency:(MedicationFrequency *)medAmount;
- (void) medSigResponse:(MedSigViewController *)inView withInstruction:(MedicationInstruction *)medAmount;
- (void) medSigResponse:(MedSigViewController *)inView withRepeatInterval:(NSString *)interval;



@end
@interface MedSigViewController : UITableViewController

@property (nonatomic,retain) NSString *type;
@property (nonatomic,assign) int selectedIndex;
@property (nonatomic,retain) NSString *selectedValue;
@property (nonatomic,assign) BOOL readOnly;
@property (nonatomic,assign) id<MedSigProtocol> delegate;
@end
