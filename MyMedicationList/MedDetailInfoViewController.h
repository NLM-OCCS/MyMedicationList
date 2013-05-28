//  UserInfoViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
////

#import <UIKit/UIKit.h>
#import "ELCTextfieldCell.h"
#import "MedSigViewController.h"
#import "MMLMedication.h"
#import "MMLCustomImageButton.h"
#import "MMLPersonData.h"
@protocol MedDetailInfoDelegate;
@interface MedDetailInfoViewController : UITableViewController<ELCTextFieldDelegate,MedSigProtocol> {

}


@property (retain,nonatomic) MMLMedication *medication;  // The medication whose data we may modify
@property (nonatomic, retain) NSString *type;

@property (nonatomic,retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic,retain) IBOutlet UIPickerView *amountPicker;
@property (nonatomic,retain) IBOutlet MMLCustomImageButton *addPhotoBtn;
@property (nonatomic,retain) IBOutlet UIButton *dailyMedButton;
@property (nonatomic,assign) id<MedDetailInfoDelegate> delegate;
@property (nonatomic,assign) BOOL discontinuedMedication;
@property (nonatomic,assign) MMLPersonData *person;


-(IBAction) datePickerValueChanged:(id) datePicker;

-(IBAction) resignDatePicker:(id)datePicker;
-(IBAction) displayEditPhotoActionSheet:(id)sender;

@end
@protocol MedDetailInfoDelegate <NSObject>

@required
- (void)MedDetailInfoViewController:(UITableViewController *)medDataController didChangeData:(BOOL)isChanged withNewDiscontinuedMedication:(MMLMedication *)discontinuedMedication;
- (void)MedDetailInfoViewController:(UIViewController *)medSearchController didSelectMedication:(MMLMedication *)medication exists:(BOOL) exists;

// TODO: Make the ModalMedicationSearchViewController a uitableviewcontroller so that both the search view and info view can cancel
// Note: You should also change the above method to ModalMedicationInfoViewController since this will be the only controller that
// will allow the user to select a medication
//- (void)modalSearchViewControllerDidCancel:(ModalMedicationSearchViewController *)medSearchController;


@end
