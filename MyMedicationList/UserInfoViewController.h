//
//  UserInfoViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "ELCTextfieldCell.h"
#import "PersonDataEnums.h"
#import "AddressViewController.h"
#import "InsuranceViewController.h"
#import "OverlayViewController.h"
#import "MMLCustomImageButton.h"
#import "MMLPersonData.h"
#import "ImportViewController.h"

@class ELCTextFieldCell;

@interface UserInfoViewController : UITableViewController<ELCTextFieldDelegate,AddressInfoDelegate,InsuranceInfoDelegate> {
    NSArray *labels;
    NSArray *placeholders;
    Gender gender;
    
}
@property (nonatomic,retain) IBOutlet MMLCustomImageButton *addPhotoBtn;
@property (nonatomic,retain) IBOutlet UIImageView *selectedMale;
@property (nonatomic,retain) IBOutlet UIImageView *unselectedMale;
@property (nonatomic,retain) IBOutlet UIImageView *selectedFemale;
@property (nonatomic,retain) IBOutlet UIImageView *unselectedFemale;
///////@property (nonatomic,retain) PersonData *personData;
@property (nonatomic,retain) MMLPersonData *personData;
@property (nonatomic,retain)  IBOutlet UIDatePicker *datePicker;
@property (nonatomic,retain)  IBOutlet UIToolbar *toolBar;


-(IBAction) datePickerValueChanged:(id) datePicker;
-(IBAction) resignDatePicker:(id)datePicker;
@end
