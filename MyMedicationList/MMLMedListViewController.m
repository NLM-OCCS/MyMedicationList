//
//  MMLMedListViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MMLMedListViewController.h"

#import "MedicationOrderAdapterArray.h"
#import "MedicationContainer.h"
#import "MedDetailInfoViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ModalMedicationSearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"
#import "MMLCustomImageButton.h"
#import "OverlayViewController.h"
#import "RemindersViewController.h"
#import "CCDGenerator.h"
#import "PictureViewerViewController.h"

@interface MMLMedListViewController ()<UIActionSheetDelegate,UIPrintInteractionControllerDelegate,MFMailComposeViewControllerDelegate,MedDetailInfoDelegate,OverlayViewControllerDelegate,PictureViewerDelegate>
@property (retain,nonatomic) NSMutableArray *currentMedications;
@property (retain,nonatomic) NSMutableArray *discontinuedMedications;
@property (retain,nonatomic) NSIndexPath *selectedIndexPath;
@property (retain,nonatomic) IBOutlet UIView *bluetoothActionView;
@property (retain,nonatomic) IBOutlet UIBarButtonItem *helpBarItem;

@property (retain,nonatomic) OverlayViewController *pictureViewController;
- (void) configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
-  (IBAction) printMedicationList:(id)sender;
- (IBAction) sendMailMedList:(id)sender;

@end

@implementation MMLMedListViewController

@synthesize medListChoice;
@synthesize actionBarItem;
@synthesize personData;
@synthesize currentMedications;
@synthesize discontinuedMedications;
@synthesize selectedIndexPath;
@synthesize medListChoiceBarItem;
@synthesize detailedCell;
@synthesize actionsView;
@synthesize btActionBtn;
@synthesize printActionBtn;
@synthesize mailActionBtn;
@synthesize prescriptionActionBtn;
@synthesize bluetoothActionView;
@synthesize pictureViewController;
@synthesize helpBarItem;
@synthesize personArchiveName;

- (void)dealloc {
    self.currentMedications = nil;
    self.discontinuedMedications = nil;
    self.medListChoice = nil;
    self.actionBarItem = nil;
    self.selectedIndexPath = nil;
    self.bluetoothActionView = nil;
    self.helpBarItem = nil;
    self.actionBarItem = nil;
    self.medListChoiceBarItem = nil;
    self.medListChoice = nil;
    self.detailedCell = nil;
    self.actionsView = nil;
   self.btActionBtn = nil;
    self.printActionBtn = nil;
    self.mailActionBtn = nil;
    self.prescriptionActionBtn = nil;
    self.personData = nil;
    self.personArchiveName = nil;
    self.toolbarItems = nil;
    self.pictureViewController = nil;

    NSLog(@"Dealloc MMLMedListViewController");
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *message = [[CoreDataManager coreDataManager] getExpiredMedicationNames:personData];
    if (message !=nil && ![message isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Medication Stop Date Expired" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }


    if (personData.currentMedicationList != nil) {
        self.currentMedications = [NSMutableArray arrayWithArray:[personData.currentMedicationList.medicationList allObjects]] ;
    } else {
        self.currentMedications = nil;
    }
    if (personData.discontinuedMedicationList != nil) {
        self.discontinuedMedications = [NSMutableArray arrayWithArray:[personData.discontinuedMedicationList.medicationList allObjects]] ;
    } else {
        self.discontinuedMedications = nil;
    }
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.hidesBackButton = NO;
    self.toolbarItems = [NSArray arrayWithObjects:medListChoiceBarItem,helpBarItem, actionBarItem,nil];
    self.selectedIndexPath = nil;
    self.navigationController.toolbarHidden = NO;
    btActionBtn.titleLabel.textAlignment = UITextAlignmentCenter;
    mailActionBtn.titleLabel.textAlignment = UITextAlignmentCenter;
    printActionBtn.titleLabel.textAlignment = UITextAlignmentCenter;
    prescriptionActionBtn.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.detailedCell.medButton addTarget:self action:@selector(displayEditPhotoActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailedCell.medButton addDashedBorderLayer:@"Custom Dashed Layer" withDashDistance:4];
    NSString *name = [NSString stringWithFormat:@"%@ %@", personData.firstName, personData.lastName];
    self.title = name;
    [self.medListChoice setWidth:84 forSegmentAtIndex:0];
    [self.medListChoice setWidth:120 forSegmentAtIndex:1];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (personData.currentMedicationList != nil) {
        self.currentMedications = [NSMutableArray arrayWithArray:[personData.currentMedicationList.medicationList allObjects]];
    } else {
        self.currentMedications = nil;
    }
    if (personData.discontinuedMedicationList != nil) {
        self.discontinuedMedications = [NSMutableArray arrayWithArray:[personData.discontinuedMedicationList.medicationList allObjects]];
    } else {
        self.discontinuedMedications = nil;
    }
    [self.tableView reloadData];
    self.navigationController.toolbarHidden = NO;
    [[CoreDataManager coreDataManager] printPersonData:personData];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;  // first one to Add // second one to display Medication results
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in each section.
    if (section == 0)
      return 1;
    else {
        if(medListChoice.selectedSegmentIndex == 0 ) {
            if (currentMedications != nil)
                return [currentMedications count];
            return 0;
        } else {
            if (discontinuedMedications != nil)
                return [discontinuedMedications count];
            return 0;
        }
    }
        
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60;
    } else if (selectedIndexPath != nil && (selectedIndexPath.row == indexPath.row && selectedIndexPath.section == indexPath.section))  {
        return 250;
    } else
        return 80;
}
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"";
    } else {
        if (medListChoice.selectedSegmentIndex == 0)
          return @"Current Medications";
        else
        return @"Discontinued Medications";
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    if ( indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self configureCell:cell forIndexPath:indexPath];
    }
    else if (selectedIndexPath == nil || !(selectedIndexPath.row == indexPath.row && selectedIndexPath.section == indexPath.section) ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell2"] autorelease];
        }
        [self configureCell:cell forIndexPath:indexPath];

    } else {
        NSLog(@"selected indexpath is %d",selectedIndexPath.row);
        self.detailedCell.medButton.tag = indexPath.row +5000;
        UIButton *btn = (UIButton *)self.detailedCell.accessoryView;
        if (btn.tag != 5000) {
            UIImage *image = [UIImage imageNamed:@"BtnDone.png"];
            UIImage *imagePressed = [UIImage imageNamed:@"BtnPressed.png"];
            UIImage *back = [image
                             stretchableImageWithLeftCapWidth:5.0
                             topCapHeight:0.0];
            UIImage *pressed = [imagePressed
                                stretchableImageWithLeftCapWidth:5.0
                                topCapHeight:0.0];
                         [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            
            [btn setBackgroundImage:back forState:UIControlStateNormal];
            [btn setBackgroundImage:pressed forState:UIControlStateSelected];
            [btn setBackgroundImage:pressed forState:UIControlStateHighlighted];
            [btn addTarget: self
                    action: @selector(accessoryButtonTapped:withEvent:)
          forControlEvents: UIControlEventTouchUpInside];
            btn.tag = 5000;
            self.detailedCell.accessoryView = btn;
        }
        if(medListChoice.selectedSegmentIndex == 0) {
            [btn setTitle:@"Edit" forState:UIControlStateNormal];
            [btn setTitle:@"Edit" forState:UIControlStateHighlighted];
            [btn setTitle:@"Edit" forState:UIControlStateSelected];
        } else {
            [btn setTitle:@"View" forState:UIControlStateNormal];
            [btn setTitle:@"View" forState:UIControlStateHighlighted];
            [btn setTitle:@"View" forState:UIControlStateSelected];
        }

        MMLMedication *medication;
        if(medListChoice.selectedSegmentIndex == 0) {
            // current Medications
            medication = ((MMLMedication *)[currentMedications objectAtIndex:indexPath.row]);
            self.detailedCell.type = @"CURRENT";
            [self.detailedCell setMedicationData:medication];
        } else {
            // discontinued Medications
            medication = ((MMLMedication *)[discontinuedMedications objectAtIndex:indexPath.row]);
            self.detailedCell.type = @"DISCONTINUED";
            [self.detailedCell setMedicationData:medication];
            
        }
        [self.detailedCell.medButton removeLayer:@"Custom User Image Layer"];
        [self.detailedCell.medButton removeLayer:@"Custom Edit Text Layer"];

         if(medication && medication.image != nil) {
             UIImage *image2 = [[[UIImage imageWithData:medication.image ] resizedImage:CGSizeMake(70,70) interpolationQuality:kCGInterpolationHigh ] thumbnailImage:70 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
            [self.detailedCell.medButton addImageLayer:@"Custom User Image Layer" withImage:image2];
            [self.detailedCell.medButton addBottomTextLayer:@"Custom Edit Text Layer" withText:@"Edit"];
        }else {
            [self.detailedCell.medButton addTextLayer:@"Custom Text Layer" withText:@"add medicine photo"];
        }
        
        
        return self.detailedCell;
    }
    return cell;
}
- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}
- (void) configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == 0) {
        cell.imageView.image = nil;
        cell.imageView.frame = CGRectMake(0,0,60,60);
        UIGraphicsBeginImageContext(cell.imageView.bounds.size);
        [cell.imageView.image drawInRect:cell.imageView.bounds];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.textLabel.text = @"Add current medication";
        UIImage *image = [UIImage imageNamed: @"MedListIcon.png"];
        cell.imageView.image = [image thumbnailImage:60 transparentBorder:2 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
        //cell.imageView.image = [UIImage imageNamed:@"MedListIcon.png"];

    }else {
         //cell.imageView.image = [UIImage imageNamed:@"addMedicine.png"];
        MMLCustomImageButton *btn = [[[MMLCustomImageButton alloc] initWithFrame:CGRectZero] autorelease];
        NSArray *subViewsArray = [cell.imageView subviews];
        for (int i=0; i < [subViewsArray count];i++) {
            if ([subViewsArray[i] isKindOfClass:[MMLCustomImageButton class]]) {
                MMLCustomImageButton *btn1 = (MMLCustomImageButton *)subViewsArray[i];
                [btn1 removeFromSuperview];
                break;
            }
        }
        cell.imageView.image = nil;
        cell.imageView.frame = CGRectMake(0,0,80,80);
        UIGraphicsBeginImageContext(cell.imageView.bounds.size);
        [cell.imageView.image drawInRect:cell.imageView.bounds];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.imageView.userInteractionEnabled = YES;

        cell.textLabel.numberOfLines = 2;
        btn.frame = CGRectMake(5,5,70,70);
        [btn addTarget:self action:@selector(displayEditPhotoActionSheet:) forControlEvents:UIControlEventTouchUpInside];
        [btn addDashedBorderLayer:@"Custom Dashed Layer" withDashDistance:4];
        cell.accessoryType = UITableViewCellAccessoryNone;

        if(medListChoice.selectedSegmentIndex == 0) {
            // current Medications
            MMLMedication *medication = ((MMLMedication *)[currentMedications objectAtIndex:indexPath.row]);
            cell.textLabel.text = [medication name];
            if(medication.image != nil) {
                UIImage *image2 = [[[UIImage imageWithData:medication.image] resizedImage:CGSizeMake(70,70) interpolationQuality:kCGInterpolationHigh ] thumbnailImage:70 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
                [btn addImageLayer:@"Custom User Image Layer" withImage:image2];
                [btn addBottomTextLayer:@"Custom Edit Text Layer" withText:@"Edit"];
            }else {
                [btn addTextLayer:@"Custom Text Layer" withText:@"add medicine photo"];
            }

            // if the user clicks on the selected index than close the previous one
        } else {
            // discontinued Medications
            MMLMedication *medication = ((MMLMedication *)[discontinuedMedications objectAtIndex:indexPath.row]);
            cell.textLabel.text = [medication name];
            if(medication.image != nil) {
                UIImage *image2 = [[[UIImage imageWithData:medication.image] resizedImage:CGSizeMake(70,70) interpolationQuality:kCGInterpolationHigh ] thumbnailImage:70 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
                [btn addImageLayer:@"Custom User Image Layer" withImage:image2];
                [btn addBottomTextLayer:@"Custom Edit Text Layer" withText:@"Edit"];
            }else {
                [btn addTextLayer:@"Custom Text Layer" withText:@"add medicine photo"];
            }
        }
        btn.tag = indexPath.row + 5000;
        [cell.imageView addSubview:btn];
        [btn addTarget:self action:@selector(displayEditPhotoActionSheet:) forControlEvents:UIControlEventTouchUpInside];

       // [cell.imageView addGestureRecognizer:tapGesture1];
       // tapGesture1.view.tag = indexPath.row;
        cell.imageView.userInteractionEnabled = YES;
    }
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Step 3 in setting up Add-cell-on-Edit
    if(tableView.editing) {
        if (indexPath.section == 0) {
        return UITableViewCellEditingStyleNone;
        } else {
        return UITableViewCellEditingStyleDelete;
       }
    }
    return UITableViewCellEditingStyleNone;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if(medListChoice.selectedSegmentIndex == 0)
        {
            NSLog(@"We are stopping the medication...");
            [self showActionSheet:self withIndexPath:indexPath];
        }
        else
        {
                    [self showActionSheet:self withIndexPath:indexPath];
        }
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }   
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	MedDetailInfoViewController *medicationDataViewController = [[MedDetailInfoViewController alloc] initWithNibName:@"MedDetailInfoViewController" bundle:nil];
    medicationDataViewController.delegate = self;
    medicationDataViewController.person = personData;
    if(medListChoice.selectedSegmentIndex == 0 )
		medicationDataViewController.medication = ((MMLMedication *)[currentMedications objectAtIndex:indexPath.row]);
	else if (medListChoice.selectedSegmentIndex == 1)
    {
		medicationDataViewController.medication = ((MMLMedication *)[discontinuedMedications objectAtIndex:indexPath.row]);
        medicationDataViewController.discontinuedMedication = YES;
    }
    medicationDataViewController.type = @"EDIT";
    self.navigationItem.backBarButtonItem.title = @"Cancel";
    [self.navigationController pushViewController:medicationDataViewController animated:YES];
    [medicationDataViewController release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray* toReload ;
    NSArray* toReload1;
    if (indexPath.section == 0) {
        self.selectedIndexPath = nil;
        [[self tableView] reloadData];
        [self addMedication];
    }else {
        if (selectedIndexPath == nil ) {
            self.selectedIndexPath = indexPath;
            toReload = [NSArray arrayWithObjects: indexPath,  nil];
        } else if (selectedIndexPath.row == indexPath.row && selectedIndexPath.section == indexPath.section) {
            self.selectedIndexPath = nil;
            toReload = [NSArray arrayWithObjects: indexPath,  nil];
        }else {
            toReload = [NSArray arrayWithObjects: indexPath,  nil];
            toReload1 = [NSArray arrayWithObjects: selectedIndexPath,  nil];
            self.selectedIndexPath = nil;
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:toReload1 withRowAnimation: UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            self.selectedIndexPath = indexPath;
        }
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:toReload withRowAnimation: UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewRowAnimationTop animated:YES];

    }
    
}

- (void)chooseMedList:(id)sender
{
	self.selectedIndexPath = nil;
    self.editing = NO;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]  withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) showActions:(id) sender {
    CGRect oldViewFrame = CGRectMake(self.view.superview.superview.frame.origin.x,
                                     self.view.superview.superview.frame.origin.y+self.view.superview.superview.frame.size.height+10,
                                     self.view.superview.frame.size.width,
                                     self.view.superview.superview.frame.size.height);
    CGRect newFrame = CGRectMake(self.view.superview.superview.frame.origin.x,
                                 self.view.superview.superview.frame.origin.y,
                                 self.view.superview.superview.frame.size.width,
                                 self.view.superview.superview.frame.size.height);
    self.actionsView.frame = oldViewFrame;
    [self.navigationController.view addSubview:actionsView];
    [UIView animateWithDuration:0.300 delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.actionsView.frame = newFrame;
                     } completion:^(BOOL finished) {
                     }];

    
}

- (void) cancelActions:(id) sender {
    CGRect newViewFrame = CGRectMake(actionsView.frame.origin.x,
                                     actionsView.frame.origin.y+actionsView.frame.size.height+10,
                                     actionsView.frame.size.width,
                                     actionsView.frame.size.height);
    [UIView animateWithDuration:0.300 delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.actionsView.frame = newViewFrame;
                     } completion:^(BOOL finished) {
                         [self.actionsView removeFromSuperview];
                     }];
}
- (void)MedDetailInfoViewController:(UIViewController *)medSearchController didSelectMedication:(MMLMedication *)medication exists:(BOOL)exists
{
    if (!exists) {
        //Medication *med = [[medication mutableCopy] autorelease];
       // MedicationContainer *medContainer = [[[MedicationContainer alloc] initWithMedication:[medication retain]] autorelease];
        if (personData.currentMedicationList == nil) {
            personData.currentMedicationList = [[CoreDataManager coreDataManager] newMedicationList];
        }
        [personData.currentMedicationList addMedicationListObject:medication];
    }
    [[CoreDataManager coreDataManager] saveContext];
    [self.navigationController popToViewController:self animated:YES];
 }

- (void)modalSearchViewControllerDidCancel:(UIViewController *)medSearchController
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)sendMML {
}
- (IBAction) exportAction:(id)sender {
    [self cancelActions:sender];
    if ([sender tag] == 3) {
        //[self printMedicationList];
    } else if ([sender tag] == 2) {
      //  [self sendMailMedList];
    }else if ([sender tag] == 4) {
        
    }else if ([sender tag] == 1) {
        [self sendMML];
    }
    
}
- (void) sendMailMedList:(id)sender {
    if([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
		mailViewController.mailComposeDelegate = self;
		[mailViewController setToRecipients:[NSArray arrayWithObjects:@"",nil]];
		[mailViewController setSubject:@"Patient Continuity of Care Document"];
		[mailViewController setMessageBody:[NSMutableString stringWithFormat:@"The Continuity of Care Document (CCD) is included in this email as an attachment. The following is a visual representation of the document:<br><br>%@", [CCDGenerator CCDTableForPerson:personData ]]
									isHTML:YES];
        if([personData insurance] != nil && [[personData insurance] frontCardImage] != nil)
            [mailViewController addAttachmentData:[[personData insurance] frontCardImage] mimeType:@"image/png" fileName:[NSString stringWithFormat:@"insuranceCardFront_%@.png",[personData firstName]]];
        if([personData insurance] != nil && [[personData insurance] backCardImage] != nil)
            [mailViewController addAttachmentData:[[personData insurance] backCardImage] mimeType:@"image/png" fileName:[NSString stringWithFormat:@"insuranceCardBack_%@.png",[personData firstName]]];
        if([personData secondaryInsurance] != nil && [[personData secondaryInsurance] frontCardImage] != nil)
            [mailViewController addAttachmentData:[[personData secondaryInsurance] frontCardImage] mimeType:@"image/png" fileName:[NSString stringWithFormat:@"secondaryCardFront_%@.png",[personData firstName]]];
        if([personData secondaryInsurance] != nil && [[personData secondaryInsurance] backCardImage] != nil)
            [mailViewController addAttachmentData:[[personData secondaryInsurance] backCardImage] mimeType:@"image/png" fileName:[NSString stringWithFormat:@"secondaryCardBack_%@.png",[personData firstName]]];
        
        
		[mailViewController addAttachmentData:[[CCDGenerator CCDStringForPerson:personData] dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/xml" fileName:[NSString stringWithFormat:@"medications_%@.xml",[personData firstName]]];
		
		[self presentModalViewController:mailViewController animated:YES];
		[mailViewController release];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Message"
														message:@"This device is not currently setup to send email"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}


}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	
	if(result == MFMailComposeResultCancelled)
		NSLog(@"The mail was cancelled.");
	else if(result == MFMailComposeResultSent)
		NSLog(@"The mail was sent");
	
	if(error != nil)
		NSLog(@"%@",[error description]);
    [self dismissModalViewControllerAnimated:YES];
}
- (void)printMedicationList:(id)sender
{
    if (![UIPrintInteractionController isPrintingAvailable]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Printer Availability Error"
                                                             message:@"Printer not available for printing"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    
    if(!pic) {
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    pic.delegate = self;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = [NSString stringWithFormat:@"%@MedicationList",[personData lastName]];
    pic.printInfo = printInfo;
    
    NSString *htmlString = [CCDGenerator CCDTableForPerson:personData];
    UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:htmlString];
    htmlFormatter.startPage = 0;
    htmlFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1-inch margins on all sides
    htmlFormatter.maximumContentWidth = 6 * 72.0;   // printed content should be 6-inches wide within those margins
    pic.printFormatter = htmlFormatter;
    [htmlFormatter release];
    
    pic.showsPageRange = YES;
    
    [pic presentAnimated:YES completionHandler:^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed && error) {
            NSLog(@"Printing could not complete because of error: %@", [error localizedDescription]);
        } }];
}

- (void)printInteractionControllerDidPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
    NSLog(@"printInteractionControllerDidPresentPrinterOptions:");
}

- (void)printInteractionControllerWillStartJob:(UIPrintInteractionController *)printInteractionController
{
    NSLog(@"printInteractionControllerWillStartJob:");
}

- (void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController
{
    NSLog(@"printInteractionControllerDidFinishJob:");
}


- (void)addMedication
{
    
    // Setup the navigation heirarchy for search medications
    UINavigationController *modalsearchNavController = [[UINavigationController alloc] init];
    
    ModalMedicationSearchViewController *medSearch = [[ModalMedicationSearchViewController alloc] initWithStyle:UITableViewStylePlain];
    medSearch.personData = self.personData;
    medSearch.dataDelegate = self;
    [self.navigationController pushViewController:medSearch animated:YES];
    [medSearch release];
    [modalsearchNavController release];
    
}


- (void)MedDetailInfoViewController:(UITableViewController *)medDataController didChangeData:(BOOL)isChanged withNewDiscontinuedMedication:(MMLMedication *)discontinuedMedication{
    if(discontinuedMedication != nil)
	{
      //  [discontinuedMedication printMedication];
       // MMLMedication *medication = [[[MedicationContainer alloc] initWithMedication:discontinuedMedication] autorelease];
		//[discontinuedMedications addObject:medContainer];
        [personData.discontinuedMedicationList addMedicationListObject:discontinuedMedication];
	}
    [[CoreDataManager coreDataManager] saveContext];
    [self.tableView reloadData];


}


-(void)showActionSheet:(id)sender withIndexPath:(NSIndexPath *)indexPath {
	
	if(medListChoice.selectedSegmentIndex == 0)
	{
		UIActionSheet *currentMedListQuery = [[UIActionSheet alloc] initWithTitle:@"What would you like to do with the medication?"
                                                                         delegate:self
                                                                cancelButtonTitle:@"Cancel"
                                                           destructiveButtonTitle:@"Remove Permanently"
                                                                otherButtonTitles:@"Move to Discontinued List",nil];
		
		currentMedListQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		currentMedListQuery.tag = 500000 + indexPath.row;
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
		discMedListQuery.tag = 400000 + indexPath.row;
		[discMedListQuery showInView:self.navigationController.view];
		[discMedListQuery release];
	}
	
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag >= 400000 && actionSheet.tag < 500000)
	{
        int row = actionSheet.tag - 400000;
        NSString *message = nil;
        if (buttonIndex == 0)
		{
			if ([discontinuedMedications count] != 0) {
                MMLMedication *med = [discontinuedMedications objectAtIndex:row];
                [personData.discontinuedMedicationList removeMedicationListObject:med];
                message = @"Deleted the discontinued medication";
				//[discontinuedMedications removeObjectAtIndex:row];
            }
		} else if (buttonIndex == 1) {
           MMLMedication *med = [discontinuedMedications objectAtIndex:row];
            MMLMedication *newMed = [self createNewMedication:med];

            // Medication *newMed = [disMed mutableCopy];
           // [discontinuedMedications removeObjectAtIndex:row];

            [personData.currentMedicationList addMedicationListObject:newMed];
            message = @"Copied the discontinued medication to current medication list";

            //[currentMedications addObject:medContainer];
        } else {
            // do nothing;
            return;
        }

        [[CoreDataManager coreDataManager] saveContext];
        if (personData.currentMedicationList != nil) {
            self.currentMedications = [NSMutableArray arrayWithArray:[personData.currentMedicationList.medicationList allObjects]];
        } else {
            self.currentMedications = nil;
        }
        if (personData.discontinuedMedicationList != nil) {
            self.discontinuedMedications = [NSMutableArray arrayWithArray:[personData.discontinuedMedicationList.medicationList allObjects]] ;
        } else {
            self.discontinuedMedications = nil;
        }
        self.tableView.editing = NO;
        [self.tableView reloadData];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
	} else if(actionSheet.tag >= 500000)
	{
        int row = actionSheet.tag - 500000;
        NSString *message = nil;
        if (buttonIndex == 1) {
        //    ((MedicationContainer *)[currentMedications objectAtIndex:row]).medication.stopDate = [Date today];
            //[ReminderTextViewController cancelAllReminfers:((MedicationContainer *)[_currentMedications objectAtIndex:[self adjustedIndexpathRow:indexPath.row]]).medication.creationID];
            // Add the deleted medication to the discontinued medications list temporarily
            [RemindersViewController cancelAllReminders:[((MMLMedication *)[currentMedications objectAtIndex:row]).creationID unsignedIntValue]];
            MMLMedication *med = [currentMedications objectAtIndex:row];
            [personData.currentMedicationList removeMedicationListObject:med];
            // Medication *newMed = [disMed mutableCopy];
            // [discontinuedMedications removeObjectAtIndex:row];
            NSDate *startDate = [NSDate date];
            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
            startDate = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:startDate]];
            if (med.stopDate != nil && [startDate compare:med.stopDate] == NSOrderedAscending)
                med.stopDate = [[[NSDate alloc]init] autorelease];
            if (personData.discontinuedMedicationList == nil) {
                MMLMedicationList *disContList = [[CoreDataManager coreDataManager] newMedicationList];
                personData.discontinuedMedicationList = disContList;
            }
            [personData.discontinuedMedicationList addMedicationListObject:med];
           // [discontinuedMedications addObject:[currentMedications objectAtIndex:row]];
           // [currentMedications removeObjectAtIndex:row];
            message = @"Moved the current medication to discontinued medication list";

        }
		else if (buttonIndex == 0)
		{
            MMLMedication *med = [currentMedications objectAtIndex:row];
            [personData.currentMedicationList removeMedicationListObject:med];
            message = @"Deleted the current medication";

		}
        else {
            return;
        }
        [[CoreDataManager coreDataManager] saveContext];
        if (personData.currentMedicationList != nil) {
            self.currentMedications = [NSMutableArray arrayWithArray:[personData.currentMedicationList.medicationList allObjects]] ;
        } else {
            self.currentMedications = nil;
        }
        if (personData.discontinuedMedicationList != nil) {
            self.discontinuedMedications = [NSMutableArray arrayWithArray:[personData.discontinuedMedicationList.medicationList allObjects]] ;
        } else {
            self.discontinuedMedications = nil;
        }
        self.tableView.editing = NO;
        [self.tableView reloadData];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
	}
	else if(actionSheet.tag >= 6000){
        if (buttonIndex == 0) {
            MMLMedication *med;
            if(medListChoice.selectedSegmentIndex == 0 ) {
                med = ((MMLMedication *)[currentMedications objectAtIndex:actionSheet.tag - 6000]);
            } else
            {
                med = ((MMLMedication *)[discontinuedMedications objectAtIndex:actionSheet.tag- 6000]);
            }

			PictureViewerViewController *pictureViewerViewController = [[PictureViewerViewController alloc] initWithNibName:@"PictureViewerViewController" bundle:nil];
            pictureViewerViewController.cardImage = [UIImage imageWithData:med.image];
            pictureViewerViewController.delegate = self;
            [self presentModalViewController:pictureViewerViewController animated:YES];
            [pictureViewerViewController release];
        } else if(buttonIndex == 1)
        {
            
            self.pictureViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureViewController.delegate = self;
            pictureViewController.imageSize = self.detailedCell.medButton.frame.size;
            
			[pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            [self presentModalViewController:pictureViewController.imagePickerController animated:YES];
            pictureViewController.imagePickerController.view.tag = actionSheet.tag-1000;
            
            
        }
        else if(buttonIndex == 2)
        {
            self.pictureViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureViewController.delegate = self;
            pictureViewController.imageSize = self.detailedCell.medButton.frame.size;
            
			//Take a photograph with the camera.
			if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                [pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeCamera];
			else
				[pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];;
			
            pictureViewController.imagePickerController.view.tag = actionSheet.tag - 1000;
			[self presentModalViewController:pictureViewController.imagePickerController animated:YES];
            
            
        }
        else if(buttonIndex == 3)
        {
            MMLMedication *med;
            if(medListChoice.selectedSegmentIndex == 0 ) {
                med = ((MMLMedication *)[currentMedications objectAtIndex:actionSheet.tag - 6000]);
                med.image = nil;
            } else
            {
                med = ((MMLMedication *)[discontinuedMedications objectAtIndex:actionSheet.tag- 6000]);
                med.image = nil;
            }
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:actionSheet.tag-6000 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        }
        else if(buttonIndex ==4)
        {
            ;
        }
    } else {
        if(buttonIndex == 0)
        {
            
            self.pictureViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureViewController.delegate = self;
            pictureViewController.imageSize = self.detailedCell.medButton.frame.size;

			[pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            [self presentModalViewController:pictureViewController.imagePickerController animated:YES];
            pictureViewController.imagePickerController.view.tag = actionSheet.tag;
            
            
        }
        else if(buttonIndex == 1)
        {
            self.pictureViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureViewController.delegate = self;
            pictureViewController.imageSize = self.detailedCell.medButton.frame.size;

			//Take a photograph with the camera.
			if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                [pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeCamera];
			else
				[pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];;
			
            pictureViewController.imagePickerController.view.tag = actionSheet.tag;
			[self presentModalViewController:pictureViewController.imagePickerController animated:YES];
            
            
        }
        else if(buttonIndex == 2)
        {           
           MMLMedication *med;
            if(medListChoice.selectedSegmentIndex == 0 ) {
                med = ((MMLMedication *)[currentMedications objectAtIndex:actionSheet.tag - 5000]);
                med.image = nil;
            } else
            {
                med = ((MMLMedication *)[discontinuedMedications objectAtIndex:actionSheet.tag- 5000]);
                med.image = nil;
            }

            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:actionSheet.tag-5000 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        }
        else if(buttonIndex == 3)
        {
            ;
        }

    }
	
}
- (void)displayEditPhotoActionSheet:(id)sender
{
	UIActionSheet *editPhotoQuery = nil;
    MMLMedication *med;
    if(medListChoice.selectedSegmentIndex == 0 ) {
        med = ((MMLMedication *)[currentMedications objectAtIndex:[sender tag] - 5000]);
    } else
    {
        med = ((MMLMedication *)[discontinuedMedications objectAtIndex:[sender tag]- 5000]);
    }
    if (med.image != nil) {
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

- (void)didFinishWithCamera
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)didTakePicture:(NSDictionary *)dictionary
{
    UIImage *picture = [dictionary valueForKey:UIImagePickerControllerOriginalImage];
    int tag = [[dictionary valueForKey:@"tag"] intValue];;
    
    MMLMedication *med;
    if(medListChoice.selectedSegmentIndex == 0 ) {
		med = ((MMLMedication *)[currentMedications objectAtIndex:tag - 5000]);
         med.image = UIImagePNGRepresentation(picture);
	}else if (medListChoice.selectedSegmentIndex == 1)
    {
		med = ((MMLMedication *)[discontinuedMedications objectAtIndex:tag- 5000]);
         med.image =  UIImagePNGRepresentation(picture);;
    }

    [[CoreDataManager coreDataManager] saveContext];
   	//[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:tag-5000 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    
}

-(BOOL) shouldAutorotate {
    return NO;
}
- (void)pictureViewerDidDismiss:(PictureViewerViewController *)pictureViewerViewController
{
    [self dismissModalViewControllerAnimated:YES];
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
- (void) checkMedicationLists {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"lastCheckedDate"] !=nil ) {
        NSNumber *number = [defaults valueForKey:@"lastCheckedDate"];
        unsigned int lastCheckedTime = [number unsignedIntegerValue];
        unsigned int currentTime = [[NSDate date] timeIntervalSince1970];
        if ((currentTime - lastCheckedTime )>= 86400) {
            // time to check the discontinued medications
            
            // Get all the current medication where medication stop date is null. Check whether stop date greater than the start date.
            // if yes create a discontinued medication or set the
            NSCalendar *gregorian = [[NSCalendar alloc]
                                     initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comp = [gregorian components:  (NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate: [NSDate date]];
            NSDate *myNewDate = [gregorian dateFromComponents:comp];
            [comp release];
            [gregorian release];
            [defaults setInteger:[myNewDate timeIntervalSince1970] forKey:@"lastCheckedDate"];
        } else {
            return;
        }
        
    }
}
@end
