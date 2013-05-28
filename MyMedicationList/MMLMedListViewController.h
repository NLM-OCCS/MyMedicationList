//
//  MMLMedListViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "MMLPersonData.h"
#import "MMLCustomMedTableViewCell.h"
#import "CoreDataManager.h"

@interface MMLMedListViewController : UITableViewController
@property (nonatomic,retain) MMLPersonData *personData;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *actionBarItem;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *medListChoiceBarItem;
@property (nonatomic,retain) IBOutlet UISegmentedControl *medListChoice;
@property (nonatomic, retain) IBOutlet MMLCustomMedTableViewCell *detailedCell;
@property (nonatomic,retain) IBOutlet UIView *actionsView;
@property (nonatomic,retain) IBOutlet UIButton *btActionBtn;
@property (nonatomic,retain) IBOutlet UIButton *printActionBtn;
@property (nonatomic,retain) IBOutlet UIButton *mailActionBtn;
@property (nonatomic,retain) IBOutlet UIButton *prescriptionActionBtn;
@property (nonatomic,retain) NSString *personArchiveName;

- (IBAction) chooseMedList:(id)sender;
-(IBAction) showActionSheet:(id)sender withIndexPath:(NSIndexPath *)indexPath;
- (IBAction) showActions:(id)sender;
-(IBAction) cancelActions:(id)sender;
- (IBAction) exportAction:(id)sender;
@end
