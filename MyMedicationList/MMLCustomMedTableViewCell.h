//
//  MMLCustomMedTableViewCell.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "MMLMedication.h"
#import "MMLCustomImageButton.h"

@interface MMLCustomMedTableViewCell : UITableViewCell
@property (nonatomic,retain) IBOutlet UILabel *medNameLabel;
@property (nonatomic,retain) IBOutlet UILabel *frequencyLabel;
@property (nonatomic,retain) IBOutlet UILabel *amountLabel;
@property (nonatomic,retain) IBOutlet UILabel *instructionLabel;
@property (nonatomic,retain) IBOutlet UILabel *startDate;
@property (nonatomic,retain) IBOutlet UILabel *stopDate;
@property (nonatomic,retain) IBOutlet UILabel *reminder;

@property (nonatomic,retain) IBOutlet MMLCustomImageButton *medButton;

@property (nonatomic,retain) NSString *type;
- (void) setMedicationData:(MMLMedication *)med;
@end
