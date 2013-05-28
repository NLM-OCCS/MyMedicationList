//
// MedDetailInfoViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MedDetailInfoViewController.h"
#import "MMLAddUserCustomTableViewCell.h"
#import "UIImage+Resize.h"
#import "MedicationAmount.h"
#import "MMLCustomSubTitleTableViewCell.h"
#import "MedSigViewController.h"
#import "DefinedMedicationInstruction.h"
#import "DailyMedViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "OverlayViewController.h"
#import "RemindersViewController.h"
#import "CoreDataManager.h"
#import "MedicationFrequency.h"
#import "Date.h"
#import "PictureViewerViewController.h"

@interface MedDetailInfoViewController ()<UIActionSheetDelegate,OverlayViewControllerDelegate,PictureViewerDelegate>  {
    UITextField *tmpTextField;
    UIView *_blankView;
    int selectedAmountNumber;
    int selectedAmountString;
}
@property (nonatomic,retain) UIImage *image;
@property (nonatomic, retain) NSMutableDictionary *medDataDict;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) NSArray *placeholders;
@property (nonatomic, retain) OverlayViewController *pictureController;
- (void) enableDoneBtn;
-( void) cancelMedication:(id)sender;
- (void) saveMedication:(id)sender;
-(void) openDailyMed;
@end

@implementation MedDetailInfoViewController
@synthesize labels;
@synthesize placeholders;
@synthesize medication;
@synthesize datePicker;
@synthesize toolBar;

@synthesize image;
@synthesize addPhotoBtn;
@synthesize amountPicker;
@synthesize medDataDict;
@synthesize dailyMedButton;
@synthesize delegate;
@synthesize pictureController,discontinuedMedication,type;
@synthesize person;


- (void) dealloc {
    self.image = nil;
    self.medDataDict = nil;
    self.labels = nil;
    self.placeholders =nil;
    self.pictureController = nil;
    self.medication = nil;  // The medication whose data we may modify
    self.type = nil;
    self.datePicker = nil;
   self.toolBar = nil;
    self.amountPicker = nil;
  self.addPhotoBtn = nil;
    self.dailyMedButton = nil;
    [_blankView release];
    NSLog(@"MedDetailInfoViewController dealloc");
      [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *leftbarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelMedication:)] autorelease];
    UIBarButtonItem *rightbarButton = [[[UIBarButtonItem alloc]  initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveMedication:)] autorelease];
    rightbarButton.title = @"Save";
    self.navigationItem.leftBarButtonItem = leftbarButton;
    self.navigationItem.rightBarButtonItem = rightbarButton;
    selectedAmountString = 0;
    selectedAmountNumber = 0;
    self.image = nil;
    self.labels = [NSArray arrayWithObjects:@"Start Date",
                   @"Stop Date",
                   @"Amount",
                   @"Frequency",
                   nil];
	
	self.placeholders = [NSArray arrayWithObjects:@"Enter Start Date",
                         @"Enter Stop Date",
                         @"Enter Amount",
                         @"Enter Frequency",
                         nil];
    _blankView = [[UIView alloc] initWithFrame:CGRectZero];
    _blankView.backgroundColor = [UIColor clearColor];
    [addPhotoBtn addDashedBorderLayer:@"Custom Dashed Layer" withDashDistance:4];
    
    UIImage *tmpImage = [UIImage imageNamed:@"DefalutButton.png"];
    UIImage *newImage = [tmpImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[dailyMedButton setBackgroundImage:newImage forState:UIControlStateNormal];
    [dailyMedButton addTarget:self action:@selector(openDailyMed) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:dailyMedButton];

    [self.tableView addSubview:addPhotoBtn];
    [addPhotoBtn addTextLayer:@"Custom Text Layer" withText:@"add medicine photo"];
    self.medDataDict = [[[NSMutableDictionary alloc]init] autorelease];
    if (medication != nil) {
        if (medication.name !=nil) {
            [self.medDataDict setValue:medication.name forKey:@"name"];
        }
        if (medication.startDate != nil) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateStyle = NSDateFormatterMediumStyle;
            [self.medDataDict setValue:[df stringFromDate:medication.startDate]forKey:@"Start Date"];
            [df release];
        } else {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateStyle = NSDateFormatterMediumStyle;
            [self.medDataDict setValue:[df stringFromDate:[NSDate date]]forKey:@"Start Date"];
            [df release];
        }
        if (medication.stopDate != nil) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateStyle = NSDateFormatterMediumStyle;
            [self.medDataDict setValue:[df stringFromDate:medication.stopDate]forKey:@"Stop Date"];
            [df release];
        }
        if (medication.medicationAmount != nil) {
            //[self.medDataDict setValue:[medication amount] forKey:@"Amount"];
            MMLMedicationAmount *amount = medication.medicationAmount;
            MedicationAmount *mAmount = [[[MedicationAmount alloc]initWithAmountType:[[amount valueForKey:@"amountType"] intValue] Quantity:[[amount valueForKey:@"quantity"] intValue]] autorelease];
            [self.medDataDict setValue:mAmount forKey:@"Amount"];
            selectedAmountString =  [mAmount amountType] ; ///[amount valueForKey:@"amountType"];
           ///// selectedAmountNumber = [[medication amount] quantity];
            selectedAmountNumber =    [[amount valueForKey:@"quantity"] intValue];
        }
        if (medication.medicationFrequency != nil) {
            MMLMedicationFrequency *mmlFrequency = medication.medicationFrequency;
            MedicationFrequency *frequency = [[[MedicationFrequency alloc]initWithFrequency:[[mmlFrequency valueForKey:@"frequency"] intValue]] autorelease];
            [self.medDataDict setValue:frequency forKey:@"Frequency"];
        }
        if (medication.medicationInstruction != nil) {
            MMLMedicationInstruction *mmlInstruction = medication.medicationInstruction;
            MedicationInstruction *instruction = [[[MedicationInstruction alloc] initWithInstruction:[mmlInstruction valueForKey:@"instruction"]] autorelease];
            [self.medDataDict setValue:instruction forKey:@"Instructions"];
        }
        if (medication.image != nil) {
            UIImage *image2 = [[[UIImage imageWithData:medication.image] resizedImage:CGSizeMake(80,80) interpolationQuality:kCGInterpolationHigh ] thumbnailImage:80 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
            [addPhotoBtn removeLayer:@"Custom Text Layer"];
            [addPhotoBtn addImageLayer:@"Custom User Image Layer" withImage:image2];
            [addPhotoBtn addBottomTextLayer:@"Custom Edit Text Layer" withText:@"Edit"];
        } else {
            [addPhotoBtn addTextLayer:@"Custom Text Layer" withText:@"add medicine photo"];
        }
    }
    if (discontinuedMedication) {
        // self.tableView.userInteractionEnabled = NO;
        self.navigationItem.rightBarButtonItem = nil;
        addPhotoBtn.userInteractionEnabled = NO;
    }
    
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Details";
    [self.tableView reloadData];
    self.navigationController.toolbarHidden = YES;
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.type && [self.type isEqualToString:@"EDIT"]) {
        return 5;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 4;
    } else {
        return 1;
    }
}
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == 0 && [indexPath section] == 1){
        CGRect frame = cell.frame;
        addPhotoBtn.frame = CGRectMake(frame.origin.x-75, frame.origin.y+25, addPhotoBtn.frame.size.width,addPhotoBtn.frame.size.height);
        if (self.image != nil) {
            [addPhotoBtn removeLayer:@"Custom User Image Layer"];
            [addPhotoBtn removeLayer:@"Custom Edit Text"];
            [addPhotoBtn removeLayer:@"Custom Text Layer"];
            UIImage *image2 = [[self.image resizedImage:CGSizeMake(80,80) interpolationQuality:kCGInterpolationHigh ] thumbnailImage:80 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
            [addPhotoBtn addImageLayer:@"Custom User Image Layer" withImage:image2];
            [addPhotoBtn addBottomTextLayer:@"Custom Edit Text Layer" withText:@"Edit"];
            
        }
        dailyMedButton.frame = CGRectMake(frame.origin.x-75, addPhotoBtn.frame.origin.y + 90, addPhotoBtn.frame.size.width,40);
    }
    if (indexPath.section == 4) {
        UIView *btn = [cell.contentView viewWithTag:50000];
        btn.frame = CGRectMake (0,0,cell.contentView.frame.size.width,cell.contentView.frame.size.height);;
        
    }

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MedCell";   
    if (indexPath.section == 0) {
        UITableViewCell *cell1 = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MedCell1"];
        if (cell1 == nil) {
            cell1 = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MEdCell1"] autorelease];
        }
        if (discontinuedMedication) {
            cell1.textLabel.text = [NSString stringWithFormat:@"%@\n%@", @"Discontinued",[medication name]];
        } else
            cell1.textLabel.text = [medication name];
        cell1.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        cell1.textLabel.numberOfLines = 0;
        cell1.textLabel.backgroundColor = [UIColor clearColor];
        cell1.textLabel.textAlignment = NSTextAlignmentCenter;
        cell1.backgroundView = _blankView;
        return cell1;
    }
    else if (indexPath.section == 1) {
        MMLAddUserCustomTableViewCell *cell;
        
        if (indexPath.row == 0 || indexPath.row == 1) {
            cell = (MMLAddUserCustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"MedDateCell"];
            if (cell == nil) {
                cell = [[[MMLAddUserCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MEdDateCell"] autorelease];
            }
            if (discontinuedMedication) {
                cell.rightTextField.userInteractionEnabled = NO;
            }
        } else {
            if (indexPath.row == 2) {
                MMLAddUserCustomTableViewCell *cell1 = (MMLAddUserCustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell1 == nil) {
                    cell1 = [[[MMLAddUserCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                }
                cell1.rightTextField.placeholder = [self.placeholders objectAtIndex:indexPath.row];
                cell1.indexPath = indexPath;
                cell1.delegate = self;
                //Disables UITableViewCell from accidentally becoming selected.
                cell1.selectionStyle = UITableViewCellSelectionStyleNone;
                cell1.rightTextField.inputView = amountPicker;
                cell1.rightTextField.inputAccessoryView = toolBar;
                
                UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 15)] autorelease];
                cell1.rightTextField.inset = UIEdgeInsetsMake(20, 0, 0, 0);
                cell1.rightTextField.leftViewInset = UIEdgeInsetsMake(0, 0, 20, 0);
                label.text = [self.labels objectAtIndex:indexPath.row];
                label.textColor = [UIColor lightGrayColor];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:17];
                cell1.rightTextField.leftViewMode = UITextFieldViewModeAlways;
                cell1.rightTextField.leftView = label;
                if (discontinuedMedication) {
                    cell1.rightTextField.userInteractionEnabled = NO;
                }
                amountPicker.tag = indexPath.row;
                if ([[medDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]] isKindOfClass:[MedicationAmount class]]) {
                    cell1.rightTextField.text = [[medDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]] printAmount] ;
                    MedicationAmount *amount = [medDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]];
                    selectedAmountNumber =  [amount quantity];
                    selectedAmountString = [amount amountType];
                    [amountPicker selectRow:selectedAmountNumber-1 inComponent:0 animated:YES];
                    [amountPicker selectRow:selectedAmountString inComponent:1 animated:YES];
                }
                return cell1;

            } else {
               MMLCustomSubTitleTableViewCell * cell = (MMLCustomSubTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MedOtherCellIdentifier1"];
               if (cell == nil) {
                 cell = [[[MMLCustomSubTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MedOtherCellIdentifier1"] autorelease];
               }
               if (indexPath.row == 3) {
                  cell.textLabel.text = @"Frequency";
                   cell.textLabel.font = [UIFont systemFontOfSize:17];
                   cell.textLabel.textColor = [UIColor lightGrayColor];

                  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                  if (medDataDict != nil && [medDataDict valueForKey:@"Frequency"] != nil) {
                      MedicationFrequency *frequency = [medDataDict valueForKey:@"Frequency"];
                       cell.detailTextLabel.text = [frequency printFrequency] ;
                      cell.detailTextLabel.textColor = [UIColor blackColor];
                      cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
                   }
               }
               cell.selectionStyle = UITableViewCellSelectionStyleNone;
               return cell;
            }
        }
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    } else {
        if (indexPath.section == 4) {
            UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"deleteMedButon"];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deleteMedButon"] autorelease];
            }
            UIView *btn1 = [cell.contentView viewWithTag:50000];
            [btn1 removeFromSuperview];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"Delete Medication" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(deleteMedication:) forControlEvents:UIControlEventTouchUpInside];
            [btn setBackgroundImage:[[UIImage imageNamed:@"iphone_delete_button.png"]
                                     stretchableImageWithLeftCapWidth:8.0f
                                     topCapHeight:0.0f] forState:UIControlStateNormal];
            btn.tag = 50000;
            [cell.contentView addSubview:btn];
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
            [cell setBackgroundColor:[UIColor clearColor]];
            return cell;

        }
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MedOtherCellIdentifier"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MedOtherCellIdentifier"] autorelease];
        }
        if (indexPath.section == 2 ) {
            cell.textLabel.text = @"Notes";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (medDataDict != nil && [medDataDict valueForKey:@"Instructions"] != nil) {
                MedicationInstruction *instruction = [medDataDict valueForKey:@"Instructions"];
                cell.detailTextLabel.text = [instruction displayInstruction] ;
                cell.detailTextLabel.textColor = [UIColor blackColor];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            }
        }
        
        if (indexPath.section == 3) {
            cell.textLabel.text = @"Reminders";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if ([RemindersViewController hasReminders:[medication.creationID  unsignedIntValue]]){
                UILocalNotification *notification = [RemindersViewController retrieveReminder:[medication.creationID unsignedIntValue]];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"EEEE MMMM d, YYYY  HH:mm zzz"];
                
                NSString *dateString = [dateFormat stringFromDate:[notification fireDate]];
                [dateFormat release];
                cell.detailTextLabel.text = dateString;
                cell.detailTextLabel.textColor = [UIColor blackColor];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            } else {
                cell.detailTextLabel.text = @"";
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        // Caluclate the row height
        NSString *name;
        if (discontinuedMedication) {
            name = [NSString stringWithFormat:@"%@\n%@", @"Discontinued",[medication name]];
        } else
            name = [[medication name] uppercaseString];
         
        CGSize size = [name  sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]
                        constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
        return size.height;
    }
    if (indexPath.section == 4)
        return 44.0f;
    return 55.0f;
    
}
#pragma mark -
#pragma mark Table view data source

- (void)configureCell:(MMLAddUserCustomTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	//cell.leftLabel.text = [self.labels objectAtIndex:indexPath.row];
	cell.rightTextField.placeholder = [self.placeholders objectAtIndex:indexPath.row];
	cell.indexPath = indexPath;
	cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)] autorelease];
    cell.rightTextField.inset = UIEdgeInsetsMake(20, 0, 0, 0);
    cell.rightTextField.leftViewInset = UIEdgeInsetsMake(0, 0, 20, 0);
    label.text = [self.labels objectAtIndex:indexPath.row];
    label.textColor = [UIColor lightGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17];
    cell.rightTextField.leftViewMode = UITextFieldViewModeAlways;
    cell.rightTextField.leftView = label;

    if (indexPath.row == 0 || indexPath.row == 1) {
        cell.rightTextField.inputView  = datePicker;
        cell.rightTextField.inputAccessoryView = toolBar;

        if (medDataDict != nil && [medDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]]
            && ![[medDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]] isEqualToString:@""]) {
            cell.rightTextField.text = [medDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]] ;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateStyle:NSDateFormatterMediumStyle];
            datePicker.date = [dateFormat dateFromString:[self.medDataDict valueForKey:@"Start Date"]];
            [dateFormat release];
        }
    }else if (indexPath.row == 2) {
         amountPicker.tag = indexPath.row;
        
    }
    if (discontinuedMedication) {
        cell.rightTextField.userInteractionEnabled = NO;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 3) {
        // Frequency
        MedSigViewController *freqController = [[MedSigViewController alloc] initWithNibName:@"MedSigViewController" bundle:nil];
        freqController.readOnly = discontinuedMedication;
        freqController.delegate = self;
        freqController.type = @"Frequency";
        if ([medDataDict valueForKey:@"Frequency"]) {
            freqController.selectedIndex = [(MedicationFrequency *)[medDataDict valueForKey:@"Frequency"] frequency];
        } else {
            freqController.selectedIndex = -1;
        }
        freqController.selectedValue = @"";
        [[self navigationController] pushViewController:freqController animated:YES];
        [freqController release];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        MedSigViewController *freqController = [[MedSigViewController alloc] initWithNibName:@"MedSigViewController" bundle:nil];
        freqController.readOnly = discontinuedMedication;

        freqController.delegate = self;
        freqController.type = @"Instructions";
        if ([medDataDict valueForKey:@"Instructions"]) {
            if ([(MedicationInstruction *)[medDataDict valueForKey:@"Instructions"] isDefinedInstruction]) {
               freqController.selectedIndex =   [MedicationInstruction definedInstructionForString:[(MedicationInstruction *)[medDataDict valueForKey:@"Instructions"] printInstruction ]];
               freqController.selectedValue = @"";
            } else {
                freqController.selectedIndex = 5000;
                freqController.selectedValue = [NSString stringWithFormat:@"%@",[(MedicationInstruction *)[medDataDict valueForKey:@"Instructions"] origInstruction]];
                NSLog(@"selectedValue is %@", freqController.selectedValue);
            }
        } else {
            freqController.selectedIndex = -1;
            freqController.selectedValue = @"";
        }
        
        [[self navigationController] pushViewController:freqController animated:YES];
        [freqController release];
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        RemindersViewController *reminderController = [[RemindersViewController alloc] initWithNibName:@"RemindersViewController" bundle:nil];
        reminderController.readOnly = self.discontinuedMedication;
        reminderController.medication = medication;
        reminderController.person = self.person;
        [[self navigationController] pushViewController:reminderController animated:YES];
        [reminderController release];
    }
}

#pragma mark ELCTextFieldCellDelegate Methods

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if (tmpTextField == nil) {
        return YES;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview];
    [self enableDoneBtn];
	if(indexPath != nil && indexPath.row < 1) {
        NSLog(@" textcellindex path Row is %d",indexPath.row);
		//NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        
		//[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
       // [[(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:path] rightTextField] becomeFirstResponder];
        return YES;
        
	}
	else {
        NSLog(@"texcell after index path Row is %d",indexPath.row);
		[[(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] rightTextField] resignFirstResponder];
	}
    
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.inputView != nil) {
        [textField.inputView resignFirstResponder];
    }
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self enableDoneBtn];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview];
    NSLog(@"texcellBegin index path Row is %d",indexPath.row);
    tmpTextField = textField;
   
       if ((indexPath.row == 0 || indexPath.row == 1) && medDataDict != nil && [medDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]]
        && ![[medDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]] isEqualToString:@""]) {
       
           NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
           [dateFormat setDateStyle:NSDateFormatterMediumStyle];
           datePicker.date = [dateFormat dateFromString:[self.medDataDict valueForKey:@"Start Date"]];
           [dateFormat release];
           
        }
    datePicker.tag = indexPath.row;
    if (indexPath.row == 2) {
        amountPicker.tag = indexPath.row;
//        
//        if (selectedAmountString != -1) {
//            [amountPicker selectRow:selectedAmountString inComponent:1 animated:NO];
//        }
//        if (selectedAmountNumber != -1) {
//            [amountPicker selectRow:selectedAmountNumber-1 inComponent:0 animated:NO];
//
//        }
    }
    return YES;
}



- (void) enableDoneBtn {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}
- (void)datePickerValueChanged:(id) datePicker2 {
    UIDatePicker *dp = (UIDatePicker *)datePicker2;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    NSLog(@"Date Picker Log is %d",dp.tag);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:dp.tag inSection:1];
    if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
        [(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField].text =
        [NSString stringWithFormat:@"%@",[df stringFromDate:dp.date]];
        [medDataDict setValue:[df stringFromDate:dp.date] forKey:[self.labels objectAtIndex:indexPath.row] ];

        
    }
    [df release];
}


#pragma mark -
#pragma mark PickerView Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    

    if (component == 0)
    {
        selectedAmountNumber = row+1;
        if (selectedAmountString != -1) {
            if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
                [(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField].text =
                [NSString stringWithFormat:@"%d %@",selectedAmountNumber,[MedicationAmount amountTypeStringForAmountType:(MedicationAmountType)selectedAmountString]];
                [medDataDict setValue:[[[MedicationAmount alloc] initWithAmountType:(MedicationAmountType)selectedAmountString Quantity:selectedAmountNumber ] autorelease] forKey:@"Amount"];
            }
        }
    } else {
        selectedAmountString = row;
        if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
            [(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField].text =
            [NSString stringWithFormat:@"%d %@",selectedAmountNumber,[MedicationAmount amountTypeStringForAmountType:(MedicationAmountType)selectedAmountString]];
            [medDataDict setValue:[[[MedicationAmount alloc] initWithAmountType:(MedicationAmountType)selectedAmountString Quantity:selectedAmountNumber ] autorelease] forKey:@"Amount"];
            
        }
    }
    
}
#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (component == 0) {
        return 99;
    }
    return NumberOfAmountTypes;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (component == 1) {
        return [MedicationAmount amountTypeStringForAmountType:row];
    }
    return [NSString stringWithFormat:@"%d",++row];
}
-(void)resignDatePicker:(id)datePicker {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
        [[(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField] resignFirstResponder];
    }
    indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
        [[(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField] resignFirstResponder];
        int comp1 = [amountPicker selectedRowInComponent:0];
        int comp2 = [amountPicker selectedRowInComponent:1];
        [(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField].text =
        [NSString stringWithFormat:@"%d %@",comp1+1,[MedicationAmount amountTypeStringForAmountType:(MedicationAmountType)comp2]];
        [medDataDict setValue:[[[MedicationAmount alloc] initWithAmountType:(MedicationAmountType)comp2 Quantity:comp1+1 ] autorelease] forKey:@"Amount"];
    }
    indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
        [[(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField] resignFirstResponder];
    }
}

- (void) cancelMedication:(id)sender {
    [tmpTextField resignFirstResponder];
    tmpTextField = nil;
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void) saveMedication:(id)sender {
    [tmpTextField resignFirstResponder];
    tmpTextField = nil;
    [self enableDoneBtn];
    if ([self.medDataDict valueForKey:@"Start Date"] != nil && ![[self.medDataDict valueForKey:@"Start Date"] isEqualToString:@""]) {
    //    medication.startDate =  [Date getNSDate:[self.medDataDict valueForKey:@"Start Date"] ];// [[[Date alloc]initWithString:[self.medDataDict valueForKey:@"Start Date"] ] autorelease];
    
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
         medication.startDate = [dateFormat dateFromString:[self.medDataDict valueForKey:@"Start Date"]];
        [dateFormat release];
    }
    if ([self.medDataDict valueForKey:@"Stop Date"] != nil && ![[self.medDataDict valueForKey:@"Stop Date"] isEqualToString:@""]) {
      //  medication.stopDate = [Date getNSDate:[self.medDataDict valueForKey:@"Stop Date"] ];//[[[Date alloc]initWithString:[self.medDataDict valueForKey:@"Stop Date"]] autorelease];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        medication.stopDate = [dateFormat dateFromString:[self.medDataDict valueForKey:@"Stop Date"]];
        [dateFormat release];
    }
    if ([self.medDataDict valueForKey:@"Frequency"] != nil && [[self.medDataDict valueForKey:@"Frequency"] isKindOfClass:[MedicationFrequency class]]) {
        if (medication.medicationFrequency == nil) {
            medication.medicationFrequency = [[CoreDataManager coreDataManager] newFrequency];
        }
        MedicationFrequency *frequency =[self.medDataDict valueForKey:@"Frequency"];
        NSLog(@"Frequency is %@  %d", [frequency printFrequency], frequency.frequency);
        medication.medicationFrequency.frequency =  [NSNumber numberWithInt:(int)frequency.frequency];
       // medication.frequency = [self.medDataDict valueForKey:@"Frequency"];
    }
    if ([self.medDataDict valueForKey:@"Amount"] != nil && [[self.medDataDict valueForKey:@"Amount"] isKindOfClass:[MedicationAmount class]]) {
        if (medication.medicationAmount == nil) {
            medication.medicationAmount = [[CoreDataManager coreDataManager] newamount];
        }
        MedicationAmount *amount = [self.medDataDict valueForKey:@"Amount"];
        medication.medicationAmount.quantity = [NSNumber numberWithInt:[amount quantity]];
        medication.medicationAmount.amountType =  [NSNumber numberWithInt:[amount amountType]];
    }
    if ([self.medDataDict valueForKey:@"Instructions"] != nil && [[self.medDataDict valueForKey:@"Instructions"] isKindOfClass:[MedicationInstruction class]]) {
        MedicationInstruction *instruction = [self.medDataDict valueForKey:@"Instructions"];
        if (medication.medicationInstruction == nil) {
            medication.medicationInstruction = [[CoreDataManager coreDataManager] newInstruction];
        }
        medication.medicationInstruction.instruction = [instruction origInstruction];
       // medication.instruction = [self.medDataDict valueForKey:@"Instructions"];
    }
    if (self.image != nil) {
        medication.image = UIImagePNGRepresentation(self.image);
    }
    NSDate *startDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    startDate = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:startDate]];
    if (medication.stopDate != nil && [medication.stopDate compare:medication.startDate] == NSOrderedAscending) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Medication Start Date is less than Medication Stop date" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView show];
        [alertView release];
    } else {
       

//    [[CoreDataManager coreDataManager] printMedication:medication];
    if ([self.delegate respondsToSelector:@selector(MedDetailInfoViewController:didSelectMedication:exists:)]) {
        if (self.type && [self.type isEqualToString:@"EDIT"]) {
            [self.delegate MedDetailInfoViewController:self didSelectMedication:medication exists:YES];
        } else {
             [self.delegate MedDetailInfoViewController:self didSelectMedication:medication exists:NO];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    } else if(buttonIndex ==1) {
        if ([self.delegate respondsToSelector:@selector(MedDetailInfoViewController:didSelectMedication:exists:)]) {
            if (self.type && [self.type isEqualToString:@"EDIT"]) {
                [self.delegate MedDetailInfoViewController:self didSelectMedication:medication exists:YES];
            } else {
                [self.delegate MedDetailInfoViewController:self didSelectMedication:medication exists:NO];
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }

    }
}


// The user will pick what to do with when the medication image is touched
- (void)displayEditPhotoActionSheet:(id)sender
{
    NSLog(@"displayEditPhotoActionSheet");
    UIActionSheet *editPhotoQuery;
    if (medication.image != nil) {
        editPhotoQuery = [[UIActionSheet alloc] initWithTitle:@"Options to add or change the medicine photo"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"View Photo",@"Choose Photo",@"Take Photo",@"Delete Photo",nil];
        editPhotoQuery.tag = [sender tag]+1000;
    } else {
        editPhotoQuery   = [[UIActionSheet alloc] initWithTitle:@"Options to add or change the medicine photo"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Choose Photo",@"Take Photo",@"Delete Photo",nil];
        editPhotoQuery.tag = [sender tag];
        
	}
	[editPhotoQuery showInView:self.navigationController.view];
    
	[editPhotoQuery release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag== 400000 )
	{
        NSString *message = nil;
        if (buttonIndex == 0)
		{
            [person.discontinuedMedicationList removeMedicationListObject:medication];
            message = @"Deleted the discontinued medication";
            //[discontinuedMedications removeObjectAtIndex:row];
            
		} else if (buttonIndex == 1) {
            MMLMedication *newMed = [self createNewMedication:medication];
            
            // Medication *newMed = [disMed mutableCopy];
            // [discontinuedMedications removeObjectAtIndex:row];
            
            [person.currentMedicationList addMedicationListObject:newMed];
            message = @"Copied the discontinued medication to current medication list";
            
            //[currentMedications addObject:medContainer];
        } else {
            // do nothing;
            return;
        }
        
        [[CoreDataManager coreDataManager] saveContext];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        [self.navigationController popViewControllerAnimated:YES];
	} else if(actionSheet.tag == 500000)
	{
        NSString *message = nil;
        if (buttonIndex == 1) {
            //    ((MedicationContainer *)[currentMedications objectAtIndex:row]).medication.stopDate = [Date today];
            //[ReminderTextViewController cancelAllReminfers:((MedicationContainer *)[_currentMedications objectAtIndex:[self adjustedIndexpathRow:indexPath.row]]).medication.creationID];
            // Add the deleted medication to the discontinued medications list temporarily
            [RemindersViewController cancelAllReminders:[((MMLMedication *)medication).creationID unsignedIntValue]];
            [person.currentMedicationList removeMedicationListObject:medication];
            // Medication *newMed = [disMed mutableCopy];
            // [discontinuedMedications removeObjectAtIndex:row];
            NSDate *startDate = [NSDate date];
            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
            startDate = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:startDate]];
            if (medication.stopDate != nil && [startDate compare:medication.stopDate] == NSOrderedAscending)
                medication.stopDate = [[[NSDate alloc]init] autorelease];
            if (person.discontinuedMedicationList == nil) {
                MMLMedicationList *disContList = [[CoreDataManager coreDataManager] newMedicationList];
                person.discontinuedMedicationList = disContList;
            }
            [person.discontinuedMedicationList addMedicationListObject:medication];
            // [discontinuedMedications addObject:[currentMedications objectAtIndex:row]];
            // [currentMedications removeObjectAtIndex:row];
            message = @"Moved the current medication to discontinued medication list";
            
        }
		else if (buttonIndex == 0)
		{
            [person.currentMedicationList removeMedicationListObject:medication];
            message = @"Deleted the current medication";
            
		}
        else {
            return;
        }
        [[CoreDataManager coreDataManager] saveContext];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        [self.navigationController popViewControllerAnimated:YES];
	} else	if (actionSheet.tag >= 1000) {
        if (buttonIndex == 0) {
            PictureViewerViewController *pictureViewerViewController = [[PictureViewerViewController alloc] initWithNibName:@"PictureViewerViewController" bundle:nil];
            pictureViewerViewController.cardImage = [UIImage imageWithData:medication.image];
            pictureViewerViewController.delegate = self;
            [self presentModalViewController:pictureViewerViewController animated:YES];
            [pictureViewerViewController release];
        }
        else if(buttonIndex == 1)
        {
            self.pictureController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
            pictureController.delegate = self;
            pictureController.imageSize = self.addPhotoBtn.frame.size;
            
            [pictureController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            [self presentModalViewController:pictureController.imagePickerController animated:YES];
            pictureController.view.tag = actionSheet.tag - 1000;
        }
        else if(buttonIndex == 2)
        {
            self.pictureController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
            pictureController.delegate = self;
            pictureController.imageSize = self.addPhotoBtn.frame.size;
            
            //Take a photograph with the camera.
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                [pictureController setupImagePicker:UIImagePickerControllerSourceTypeCamera];
            else
                [pictureController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];;
            
            pictureController.view.tag = actionSheet.tag - 1000;
            [self presentModalViewController:pictureController.imagePickerController animated:YES];
        }
        else if(buttonIndex == 3)
        {
            self.image = nil;
            [addPhotoBtn removeLayer:@"Custom Text Layer"];
            [addPhotoBtn removeLayer:@"Custom User Image Layer"];
            [addPhotoBtn removeLayer:@"Custom Edit Text Layer"];
            [addPhotoBtn addTextLayer:@"Custom Text Layer" withText:@"add medicine photo"];
            
        }
        else if(buttonIndex == 4)
        {
            ;
        }
    } else {
    if(buttonIndex == 0)
    {
        self.pictureController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
        pictureController.delegate = self;
        pictureController.imageSize = self.addPhotoBtn.frame.size;

        [pictureController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        [self presentModalViewController:pictureController.imagePickerController animated:YES];
        pictureController.view.tag = actionSheet.tag;
    }
    else if(buttonIndex == 1)
    {
        self.pictureController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
        pictureController.delegate = self;
        pictureController.imageSize = self.addPhotoBtn.frame.size;

        //Take a photograph with the camera.
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            [pictureController setupImagePicker:UIImagePickerControllerSourceTypeCamera];
        else
            [pictureController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];;
        
        pictureController.view.tag = actionSheet.tag;
        [self presentModalViewController:pictureController.imagePickerController animated:YES];
    }
    else if(buttonIndex == 2)
    {
        self.image = nil;
        [addPhotoBtn removeLayer:@"Custom Text Layer"];
        [addPhotoBtn removeLayer:@"Custom User Image Layer"];
        [addPhotoBtn removeLayer:@"Custom Edit Text Layer"];
        [addPhotoBtn addTextLayer:@"Custom Text Layer" withText:@"add medicine photo"];
    }
    else if(buttonIndex == 3)
    {
        ;
    }
    }
}
- (void)didFinishWithCamera
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)didTakePicture:(NSDictionary *)dictionary
{
    UIImage *picture = [dictionary valueForKey:UIImagePickerControllerOriginalImage];
   	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    UIImage *image2;
    if (picture.size.width < 70 && picture.size.height < 70) {
        image2 = picture;
        self.image = picture;
    } else {
        image2 = [[picture resizedImage:CGSizeMake(80,80) interpolationQuality:kCGInterpolationHigh ] thumbnailImage:80 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
        self.image = picture;
    }
    
    [addPhotoBtn removeLayer:@"Custom Text Layer"];
    [addPhotoBtn removeLayer:@"Custom User Image Layer"];
    [addPhotoBtn removeLayer:@"Custom Edit Text Layer"];
    
    [addPhotoBtn addImageLayer:@"Custom User Image Layer" withImage:image2];
    [addPhotoBtn addBottomTextLayer:@"Custom Edit Text Layer" withText:@"Edit"];
    medication.image = UIImagePNGRepresentation(image2);
    
}

- (void) medSigResponse:(MedSigViewController *)inView withFrequency:(MedicationFrequency *)medFrequency {
    [medDataDict setValue:medFrequency forKey:@"Frequency"];
    [[self tableView] reloadData];
}
- (void) medSigResponse:(MedSigViewController *)inView withInstruction:(MedicationInstruction *)medInstr {
    [medDataDict removeObjectForKey:@"Instructions"];
    [medDataDict setValue:medInstr forKey:@"Instructions"];
    [[self tableView] reloadData];
}
- (void)openDailyMed
{
	if(medication == nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Medication Information"
														message:@"There is not enough information about this medication to open DailyMed"
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
		if (medication.conceptProperty.rxcui == nil) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Medication Information"
															message:@"There is not enough data for this medication to open DailyMed"
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		else {
			DailyMedViewController *dailyMedViewController = [[DailyMedViewController alloc] initWithNibName:nil bundle:nil];
			dailyMedViewController.rxcuiString = medication.conceptProperty.rxcui;
			[self.navigationController pushViewController:dailyMedViewController animated:YES];
			[dailyMedViewController release];
		}
	}
}
- (void)pictureViewerDidDismiss:(PictureViewerViewController *)pictureViewerViewController
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)deleteMedication:(id) sender {
	
    if(!self.discontinuedMedication)
	{
		UIActionSheet *currentMedListQuery = [[UIActionSheet alloc] initWithTitle:@"What would you like to do with the medication?"
                                                                         delegate:self
                                                                cancelButtonTitle:@"Cancel"
                                                           destructiveButtonTitle:@"Remove Permanently"
                                                                otherButtonTitles:@"Move to Discontinued List",nil];
		
		currentMedListQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        currentMedListQuery.tag = 500000;
		[currentMedListQuery showInView:self.navigationController.view];
		[currentMedListQuery release];
	}
	else
	{
		UIActionSheet *discMedListQuery = [[UIActionSheet alloc] initWithTitle:@"What would you like to do with the medication?"
                                                                      delegate:self
                                                             cancelButtonTitle:@"Cancel"
                                                        destructiveButtonTitle:@"Remove permanently"
                                                             otherButtonTitles:@"Restart medication",nil];
		
		discMedListQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        discMedListQuery.tag = 400000;
		[discMedListQuery showInView:self.navigationController.view];
		[discMedListQuery release];
	}

}

- (MMLMedication *) createNewMedication:(MMLMedication *)oldMed {
    MMLMedication *newMed = [[CoreDataManager coreDataManager] newMedication];
    newMed.startDate = [NSDate date];
    MMLMedicationAmount *newAmount = [[CoreDataManager coreDataManager] newamount];
    MMLMedicationFrequency *newFrequent = [[CoreDataManager coreDataManager] newFrequency];
    MMLMedicationInstruction *newInstruc = [[CoreDataManager coreDataManager] newInstruction];
    MMLConceptProperty *conceptProperty = [[CoreDataManager coreDataManager] newConceptProperty];
    MMLCCDInfo *ccdInfo = [[CoreDataManager coreDataManager] newCCDInfo];
    newMed.name = oldMed.name;
    
    newAmount.quantity = oldMed.medicationAmount.quantity;
    newAmount.amountType = oldMed.medicationAmount.amountType;
    newMed.medicationAmount = newAmount;
    
    newFrequent.frequency = oldMed.medicationFrequency.frequency;
    newMed.medicationFrequency = newFrequent;
    
    newInstruc.instruction = oldMed.medicationInstruction.instruction;
    newMed.medicationInstruction = newInstruc;
    
    
    
    if (oldMed.ingredientsArray !=nil && [oldMed.ingredientsArray count] > 0 ) {
        for (MMLIngredients *oldIngredient in oldMed.ingredientsArray) {
            MMLIngredients *newIngredient = [[CoreDataManager coreDataManager] newIngredients];
            newIngredient.ingredient = oldIngredient.ingredient;
            [newMed addIngredientsArrayObject:newIngredient];
        }
    }
    newMed.image = oldMed.image;
    
    conceptProperty.rxcui = [oldMed.conceptProperty rxcui];
    conceptProperty.name = [oldMed.conceptProperty name];
    conceptProperty.synonym = [oldMed.conceptProperty synonym];
    conceptProperty.termtype = [oldMed.conceptProperty termtype];
    conceptProperty.language = [oldMed.conceptProperty language];
    conceptProperty.suppressflag = [oldMed.conceptProperty suppressflag];
    conceptProperty.umlsCUI = [oldMed.conceptProperty umlsCUI];
    newMed.conceptProperty = conceptProperty;
    
    ccdInfo.isClinicalDrug =[oldMed.ccdInfo isClinicalDrug];
    ccdInfo.codeDisplayName = [oldMed.ccdInfo codeDisplayName];
    ccdInfo.codeDisplayNameRxCUI = [oldMed.ccdInfo codeDisplayNameRxCUI];
    ccdInfo.translationDisplayName = [oldMed.ccdInfo translationDisplayName];
    ccdInfo.ingredientName = [oldMed.ccdInfo ingredientName];
    ccdInfo.translationDisplayNameRxCUI = [oldMed.ccdInfo translationDisplayNameRxCUI];
    ccdInfo.brandName = [oldMed.ccdInfo brandName];
    newMed.ccdInfo = ccdInfo;
    unsigned int creationID = [[NSDate date] timeIntervalSince1970];
    
    newMed.creationID = [NSNumber numberWithUnsignedInt:creationID];
    return newMed;
}
@end
