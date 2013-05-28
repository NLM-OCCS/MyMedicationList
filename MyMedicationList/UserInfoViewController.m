 //
//  UserInfoViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "UserInfoViewController.h"
#import "MMLAddUserCustomTableViewCell.h"
#import "UIImage+Resize.h"
#import "MMLCustomSubTitleTableViewCell.h"
#import "CoreDataManager.h"
#import "Date.h"
#import "PictureViewerViewController.h"
#import "RemindersViewController.h"
@interface UserInfoViewController ()<UIActionSheetDelegate,OverlayViewControllerDelegate,PictureViewerDelegate>  {
    BOOL femaleSelected;
    BOOL maleSelected;
    UITextField *tmpTextField;
}
@property (nonatomic,retain) UIImage *image;

@property (nonatomic, retain) OverlayViewController *pictureController;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) NSArray *placeholders;
@property (nonatomic, retain) NSMutableDictionary *personDataDict;
@property (nonatomic, retain) NSMutableDictionary *addressDataDict;
@property (nonatomic, retain) NSMutableDictionary *primaryInsDataDict;
@property (nonatomic, retain) NSMutableDictionary *secondaryInsDataDict;
@property (nonatomic,retain) UIImage *selectedGenderImage;
@property (nonatomic,retain) UIImage *unSelectedGenderImage;


- (void) enableDoneBtn;
-( void) cancel:(id)sender;
- (void) saveUser:(id)sender;
@end

@implementation UserInfoViewController
@synthesize labels;
@synthesize placeholders;
@synthesize personDataDict;
@synthesize addressDataDict;
@synthesize primaryInsDataDict;
@synthesize secondaryInsDataDict;
@synthesize personData;  // assign
@synthesize datePicker;
@synthesize toolBar;
@synthesize image;
@synthesize addPhotoBtn;
@synthesize pictureController;
@synthesize selectedMale;
@synthesize unselectedFemale;

@synthesize selectedFemale;
@synthesize unselectedMale;
@synthesize selectedGenderImage;
@synthesize unSelectedGenderImage;


-(id) initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}
- (void) dealloc {
    self.labels = nil;
    self.placeholders = nil;
    self.personDataDict = nil;
    self.addressDataDict = nil;
    self.primaryInsDataDict = nil;
    self.secondaryInsDataDict = nil;
    self.datePicker = nil;
    self.toolBar = nil;
    self.image = nil;
    self.addPhotoBtn = nil;
    self.pictureController = nil;
    self.selectedFemale = nil;
    self.unselectedFemale = nil;
    self.selectedMale = nil;
    self.unselectedMale = nil;
    self.personData = nil;
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *leftbarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    UIBarButtonItem *rightbarButton = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveUser:)] autorelease];

    self.navigationItem.leftBarButtonItem = leftbarButton;
    self.navigationItem.rightBarButtonItem = rightbarButton;

    femaleSelected = NO;
    maleSelected = NO;
    self.image = nil;
    self.labels = [NSArray arrayWithObjects:@"First Name*",
                   @"Last Name*",
                   @"Date of Birth*",
                   @"Phone Number",
                   nil];
	
	self.placeholders = [NSArray arrayWithObjects:@"Enter First Name",
                         @"Enter Last Name",
                         @"Enter Date of Birth",
                         @"Phone: xxx xxx xxxx",
                         nil];
    self.personDataDict = [[[NSMutableDictionary alloc]init] autorelease];
    if (personData != nil) {
        [personDataDict setValue:personData.firstName forKey:@"First Name*"];
        [personDataDict setValue:personData.lastName forKey:@"Last Name*"];
    ////////    [personDataDict setValue:[personData.dateOfBirth printDate] forKey:@"Date of Birth*"];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterMediumStyle;
        [personDataDict setValue:[df stringFromDate:personData.dateOfBirth] forKey:@"Date of Birth*"];
        [personDataDict setValue:personData.phoneNumer forKey:@"Phone Number"];
        if ([personData.gender boolValue]) {
            maleSelected = NO;
            femaleSelected = YES;
        } else {
            maleSelected = YES;
            femaleSelected = NO;
        }
        ////[personData printPerson];
    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    addPhotoBtn.frame = CGRectMake(10,50,70,70);
    [addPhotoBtn addTarget:self action:@selector(displayEditPhotoActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    [addPhotoBtn addDashedBorderLayer:@"Custom Dashed Layer" withDashDistance:4];
   
    if (personData != nil && personData.personImage != nil) {
      ///////////  UIImage *image2 = [[personData.personImage resizedImage:CGSizeMake(70,70) interpolationQuality:kCGInterpolationHigh ] thumbnailImage:70 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
         UIImage *image2 = [[[UIImage imageWithData:personData.personImage] resizedImage:CGSizeMake(70,70) interpolationQuality:kCGInterpolationHigh ] thumbnailImage:70 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
        [addPhotoBtn addImageLayer:@"Custom User Image Layer" withImage:image2];
        [addPhotoBtn addBottomTextLayer:@"Custom Edit Text Layer" withText:@"Edit"];
    } else {
        [addPhotoBtn addTextLayer:@"Custom Text Layer" withText:@"add user photo"];
    }
    self.selectedGenderImage = [UIImage imageNamed:@"OptionChecked.png"];
    self.unSelectedGenderImage = [UIImage imageNamed:@"OptionUnchecked.png"];
    [self.tableView addSubview:addPhotoBtn];

    NSLog(@"End Date is %@",[NSDate date]);
    
}
- (void) viewDidUnload {
    self.datePicker = nil;
    self.toolBar = nil;
    self.addPhotoBtn = nil;
    self.selectedFemale = nil;
    self.unselectedMale = nil;
    self.unselectedFemale = nil;
    self.selectedMale = nil;
    [super viewDidUnload];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (personData == nil) {
        self.title = @"Add User";
        //[self enableDoneBtn];
    } else {
        self.title = @"Edit User";
    }

    [self.tableView reloadData];
    
}
- (void) viewWillDisappear:(BOOL)animated {
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (personData != nil)
        return 6;
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    } else if (section == 1) {
    return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    if (indexPath.section == 0) {
        MMLAddUserCustomTableViewCell *cell;
        if (indexPath.row == 2) {
          //  cell = (MMLAddUserCustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"DateCell"];
          //  if (cell == nil) {
         //       cell = [[[MMLAddUserCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DateCell"] autorelease];
        //    }
            MMLCustomSubTitleTableViewCell * cell = (MMLCustomSubTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MedOtherCellIdentifier1"];
            if (cell == nil) {
                cell = [[[MMLCustomSubTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MedOtherCellIdentifier1"] autorelease];
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = @"Date*";
                cell.textLabel.font = [UIFont systemFontOfSize:17];
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.detailTextLabel.text = @"Enter Date of Birth";
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (personDataDict != nil && [personDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]] != nil) {
                cell.detailTextLabel.text = [personDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]];
                cell.detailTextLabel.textColor = [UIColor blackColor];
            }
            return cell;
        } else {
            cell = (MMLAddUserCustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[MMLAddUserCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
        }
	   [self configureCell:cell atIndexPath:indexPath];
        return cell;
    } else {
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GenderCellIdentifier"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GenderCellIdentifier"] autorelease];
        }
        if (indexPath.section == 1 && indexPath.row == 0) {
            cell.textLabel.text = @"Male";
         //   cell.accessoryType = UITableViewCellAccessoryNone;
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:self.unSelectedGenderImage] autorelease];
            cell.accessoryView = imageView;
            
            if (maleSelected ) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                UIImageView *imageView = [[[UIImageView alloc] initWithImage:self.selectedGenderImage] autorelease];
                cell.accessoryView = imageView;
                femaleSelected = NO;
                cell.textLabel.text = @"Male*";
            }
            if (femaleSelected) {
                cell.textLabel.text = @"Male";
            }
        }
        if (indexPath.section == 1 && indexPath.row == 1) {
            cell.textLabel.text = @"Female";
           // cell.accessoryType = UITableViewCellAccessoryNone;
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:self.unSelectedGenderImage] autorelease];
            cell.accessoryView = imageView;

            if (femaleSelected ) {
                //cell.accessoryType = UITableViewCellAccessoryCheckmark;
                UIImageView *imageView = [[[UIImageView alloc] initWithImage:self.selectedGenderImage] autorelease];
                cell.accessoryView = imageView;
                cell.textLabel.text = @"Female*";
                maleSelected = NO;
            }
            if (maleSelected) {
                cell.textLabel.text = @"Female";
            }
            
        }
        if (indexPath.section == 2 ) {
            cell.textLabel.text = @"Home Address";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = nil;
        }
        
        if (indexPath.section == 3) {
            cell.textLabel.text = @"Primary Insurance";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = nil;
        }
        
        if (indexPath.section == 4 ) {
            cell.textLabel.text = @"Secondary Insurance";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = nil;
        }
        if (indexPath.section == 5) {
            UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"deleteMedButon"];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deleteMedButon"] autorelease];
            }
            UIView *btn1 = [cell.contentView viewWithTag:500000];
            [btn1 removeFromSuperview];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"Delete User Profile" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(deleteUser:) forControlEvents:UIControlEventTouchUpInside];
            [btn setBackgroundImage:[[UIImage imageNamed:@"iphone_delete_button.png"]
                                     stretchableImageWithLeftCapWidth:8.0f
                                     topCapHeight:0.0f] forState:UIControlStateNormal];
            btn.tag = 500000;
            [cell.contentView addSubview:btn];
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
            [cell setBackgroundColor:[UIColor clearColor]];
            return cell;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
}
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 5) {
        UIView *btn = [cell.contentView viewWithTag:500000];
        btn.frame = CGRectMake (0,0,cell.contentView.frame.size.width,cell.contentView.frame.size.height);;
        
    }
    
}
#pragma mark -
#pragma mark Table view data source

- (void)configureCell:(MMLAddUserCustomTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	cell.rightTextField.inputView = nil;
    cell.rightTextField.inputAccessoryView = nil;
	//cell.leftLabel.text = [self.labels objectAtIndex:indexPath.row];
	cell.rightTextField.placeholder = [self.placeholders objectAtIndex:indexPath.row];
	cell.indexPath = indexPath;
	cell.delegate = self;
    
    //Disables UITableViewCell from accidentally becoming selected.
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 15)] autorelease];
    cell.rightTextField.inset = UIEdgeInsetsMake(20, 0, 0, 0);
    cell.rightTextField.leftViewInset = UIEdgeInsetsMake(0, 0, 20, 0);
    label.text = [self.labels objectAtIndex:indexPath.row];
    label.textColor = [UIColor lightGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:13];
    cell.rightTextField.leftViewMode = UITextFieldViewModeAlways;
    cell.rightTextField.leftView = label;
    cell.rightTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;

	if(indexPath.row == 3) {
		[cell.rightTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
	} 
    if (indexPath.row == 2) {
        cell.rightTextField.inputView  = datePicker;
        
        NSLog(@"DatePicker is %d",[cell.rightTextField.inputView retainCount]);
        cell.rightTextField.inputAccessoryView = toolBar;
        cell.rightTextField.tag = 2;
        if (personData.dateOfBirth != nil) {
     ///////       Date *date = [personData dateOfBirth];
            NSDate *date = [personData dateOfBirth];
        ////  //  NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
       //////  ///   NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
      ////      [components setYear:date.year];
      /////      [components setMonth:date.month];
       /////     [components setDay:date.day];
      /////      datePicker.date = [calendar dateFromComponents:components];
            datePicker.date = date;
        }
    }
    if (personDataDict != nil && [personDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]] != nil) {
        cell.rightTextField.text = [personDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]];
        NSLog(@"KEy is %@ %@ %d",[self.labels objectAtIndex:indexPath.row] , cell.rightTextField.text,indexPath.row);

    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2) {
        [self displayDatePicker:indexPath];

    }
    if (indexPath.section == 1) {
        for (int i=0; i < [self.labels count]; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            if (i== 2) {
                continue;
            }
            if ((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:path] != nil) {
                [[(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:path] rightTextField] resignFirstResponder];
            }
        }
        if (indexPath.row == 0) {
            maleSelected = YES;
            femaleSelected = NO;
            gender = 0;
        } else {
            maleSelected = NO;
            femaleSelected = YES;
            gender = 1;
        }
        NSIndexSet *set = [[NSIndexSet alloc]initWithIndex:1];
        [tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self enableDoneBtn];
        [set release];
    }
    if (indexPath.section == 2) {
        AddressViewController *addressViewController =  [[[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil] autorelease];
        addressViewController._delegate = self;
        if (self.addressDataDict == nil)
            self.addressDataDict = [[[NSMutableDictionary alloc] init] autorelease];
        if (personData != nil && [addressDataDict count] == 0) {
            // Create address data dictionary
                [addressDataDict setValue:personData.streetAddress1 forKey:@"Street Addr"];
                [addressDataDict setValue:personData.streetAddress2 forKey:@"Street Addr2"];
                [addressDataDict setValue:personData.state forKey:@"State"];
                [addressDataDict setValue:personData.city forKey:@"City"];
                [addressDataDict setValue:personData.zip forKey:@"Zip"];
        }
        addressViewController.addressDataDict = addressDataDict;
        [self.navigationController pushViewController:addressViewController animated:YES];
    }
    if (indexPath.section == 3) {
        InsuranceViewController *insuranceViewController =  [[[InsuranceViewController alloc] initWithNibName:@"InsuranceViewController" bundle:nil] autorelease];
        insuranceViewController._delegate = self;
        insuranceViewController.isPrimary = YES;
        if (self.primaryInsDataDict == nil)
            self.primaryInsDataDict = [[[NSMutableDictionary alloc] init] autorelease];
        if (personData != nil && [primaryInsDataDict count] == 0) {
            // Create address data dictionary
            MMLInsurance *insurance;
            insurance = (MMLInsurance *)personData.insurance;
            [primaryInsDataDict setValue:[insurance valueForKey:@"memberNumber" ] forKey:@"Member ID"];
            [primaryInsDataDict setValue:[insurance valueForKey:@"carrier" ] forKey:@"Carrier"];
            [primaryInsDataDict setValue:[insurance valueForKey:@"rxIN" ] forKey:@"RxIN"];
            [primaryInsDataDict setValue:[insurance valueForKey:@"rxPCN" ] forKey:@"RxPCN"];
            [primaryInsDataDict setValue:[insurance valueForKey:@"rxGroup" ] forKey:@"RxGroup"];
            NSData *frontImage = [insurance valueForKey:@"frontCardImage"];
            if (frontImage != nil) {
                [primaryInsDataDict setObject:[UIImage imageWithData:frontImage] forKey:@"FrontSide"];
            }
            NSData *backImage = [insurance valueForKey:@"backCardImage"];
            if (backImage != nil) {
                [primaryInsDataDict setObject:[UIImage imageWithData:backImage] forKey:@"BackSide"];
            }
            
            ///////[primaryInsDataDict setValue:insurance.memberNumber forKey:@"Member ID"];
/////            [primaryInsDataDict setValue:personData.carrier forKey:@"Carrier"];
/////            [primaryInsDataDict setValue:personData.groupNumber forKey:@"Group Number"];
///////////[primaryInsDataDict setValue:personData.rxIN forKey:@"RxIN"];
////////            [primaryInsDataDict setValue:personData.rxPCN forKey:@"RxPCN"];
/////////            [primaryInsDataDict setValue:personData.rxGroup forKey:@"RxGroup"];
//////            if (personData.backCardImage != nil)
//////                [primaryInsDataDict setObject:personData.backCardImage forKey:@"BackSide"];
//////            if (personData.cardImage != nil)
//////                [primaryInsDataDict setObject:personData.cardImage forKey:@"FrontSide"];

        }
        insuranceViewController.insuranceDataDict = primaryInsDataDict;
        [self.navigationController pushViewController:insuranceViewController animated:YES];
    }
    if (indexPath.section == 4) {
        InsuranceViewController *insuranceViewController =  [[[InsuranceViewController alloc] initWithNibName:@"InsuranceViewController" bundle:nil] autorelease];
        insuranceViewController._delegate = self;
        insuranceViewController.isPrimary = NO;
        if (self.secondaryInsDataDict == nil)
            self.secondaryInsDataDict = [[[NSMutableDictionary alloc] init] autorelease];
        if (personData != nil && [secondaryInsDataDict count] == 0) {
            // Create address data dictionary
            
            MMLInsurance *insurance;
            insurance = (MMLInsurance *)personData.secondaryInsurance;
            [secondaryInsDataDict setValue:[insurance valueForKey:@"memberNumber" ] forKey:@"Member ID"];
            [secondaryInsDataDict setValue:[insurance valueForKey:@"carrier" ] forKey:@"Carrier"];
            [secondaryInsDataDict setValue:[insurance valueForKey:@"rxIN" ] forKey:@"RxIN"];
            [secondaryInsDataDict setValue:[insurance valueForKey:@"rxPCN" ] forKey:@"RxPCN"];
            [secondaryInsDataDict setValue:[insurance valueForKey:@"rxGroup" ] forKey:@"RxGroup"];
            NSData *frontImage = [insurance valueForKey:@"frontCardImage"];
            if (frontImage != nil) {
                [secondaryInsDataDict setObject:[UIImage imageWithData:frontImage] forKey:@"FrontSide"];
            }
            NSData *backImage = [insurance valueForKey:@"backCardImage"];
            if (backImage != nil) {
                [secondaryInsDataDict setObject:[UIImage imageWithData:backImage] forKey:@"BackSide"];
            }

//            [secondaryInsDataDict setValue:personData.memberNumber2 forKey:@"Member ID"];
//            [secondaryInsDataDict setValue:personData.carrier2 forKey:@"Carrier"];
//            [secondaryInsDataDict setValue:personData.groupNumber2 forKey:@"Group Number"];
//            [secondaryInsDataDict setValue:personData.rxIN forKey:@"RxIN"];
//            [secondaryInsDataDict setValue:personData.rxPCN2 forKey:@"RxPCN"];
//            [secondaryInsDataDict setValue:personData.rxGroup2 forKey:@"RxGroup"];
//            if (personData.backCardImage2 != nil)
//                [secondaryInsDataDict setObject:personData.backCardImage2 forKey:@"BackSide"];
//            if (personData.cardImage2 != nil)
//                [secondaryInsDataDict setObject:personData.cardImage2 forKey:@"FrontSide"];
        }
        insuranceViewController.insuranceDataDict = secondaryInsDataDict;
        [self.navigationController pushViewController:insuranceViewController animated:YES];
    }
}

#pragma mark ELCTextFieldCellDelegate Methods

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if (tmpTextField == nil) {
        return YES;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview];
    [personDataDict setValue:textField.text forKey:[self.labels objectAtIndex:indexPath.row] ];
    NSLog(@"KEy is %@ %@ %d",[self.labels objectAtIndex:indexPath.row] , textField.text,indexPath.row);
   // [self enableDoneBtn];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
   // [self enableDoneBtn];
    tmpTextField = textField;
//    if (textField.tag == 2) {
//        ELCTextFieldCell *cell;
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
//        if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
//            cell = (ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] ;
//            cell.rightTextField.inputView  = datePicker;
//            cell.rightTextField.inputAccessoryView = toolBar;
//        }
//    }
    if  (textField.tag == 2) {
       // return NO;
    }
    [self doneAction:nil];
    return YES;
}

- (void) enableDoneBtn {
    int mandantoryFields = 0;
    for (NSString* key in personDataDict) {
        if ([key isEqualToString:@"First Name*"] || [key isEqualToString:@"Last Name*"] || [key isEqualToString:@"Date of Birth*"]) {
            if ([personDataDict valueForKey:key] != nil && ![[personDataDict valueForKey:key] isEqualToString:@""])
                mandantoryFields++;
        }
    }
    if (maleSelected || femaleSelected) {
        mandantoryFields++;
    }
    if (mandantoryFields == 4) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)datePickerValueChanged:(id) datePicker2 {
    UIDatePicker *dp = (UIDatePicker *)datePicker2;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
        [(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField].text =
        [NSString stringWithFormat:@"%@",[df stringFromDate:dp.date]];

    }
      [df release];
}

-(void)resignDatePicker:(id)dp1 {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [df stringFromDate:datePicker.date];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    [self doneAction:dp1];
     [personDataDict setValue:[df stringFromDate:datePicker.date] forKey:[self.labels objectAtIndex:indexPath.row] ];
    [df release];  
}

- (void) cancel:(id) sender {
    [tmpTextField resignFirstResponder];
    tmpTextField = nil;
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

-(void) saveUser:(id)sender {
    [tmpTextField resignFirstResponder];
    tmpTextField = nil;
   // [self enableDoneBtn];
    int mandantoryFields = 0;

    for (NSString* key in personDataDict) {
        if ([key isEqualToString:@"First Name*"] || [key isEqualToString:@"Last Name*"] || [key isEqualToString:@"Date of Birth*"]) {
            if ([personDataDict valueForKey:key] != nil && ![[personDataDict valueForKey:key] isEqualToString:@""])
                mandantoryFields++;
        }
    }
    if (maleSelected || femaleSelected) {
        mandantoryFields++;
    }
    if (mandantoryFields != 4) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"First Name, Last Name, Gender and Birth Date are mandatory fields"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    if (personData == nil) {
        self.personData = [[CoreDataManager coreDataManager] newPersonData];
    }
    self.personData.firstName = [personDataDict  valueForKey:@"First Name*"];
    self.personData.lastName =[personDataDict  valueForKey:@"Last Name*"];
    if (femaleSelected)
        self.personData.gender = [NSNumber numberWithInt:1];
    else
        self.personData.gender = [NSNumber numberWithInt:0];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    self.personData.dateOfBirth = [dateFormat dateFromString:[self.personDataDict valueForKey:@"Date of Birth*"]];
    [dateFormat release];
    if (personData.dateOfBirth == nil)
        personData.userId = [NSString stringWithFormat:@"%@%@%@",personData.lastName,personData.firstName,@"NoDOB"];
    else
        personData.userId = [NSString stringWithFormat:@"%@%@%@",personData.lastName,personData.firstName, [Date dateValueForCCD:personData.dateOfBirth ]];

    personData.phoneNumer = [personDataDict valueForKey:@"Phone Number"];
    if (addressDataDict != nil) {
        personData.streetAddress1 =   [addressDataDict valueForKey:@"Street Addr"];
        personData.streetAddress2 = [addressDataDict valueForKey:@"Street Addr2"];
        personData.state = [addressDataDict valueForKey:@"State"];
        personData.city = [addressDataDict valueForKey:@"City"];
        personData.zip = [addressDataDict valueForKey:@"Zip"];

    }
    if (primaryInsDataDict != nil) {
        MMLInsurance *insurance = [[CoreDataManager coreDataManager] newInsurance];
        insurance.carrier =   [primaryInsDataDict valueForKey:@"Carrier"];
        insurance.memberNumber = [primaryInsDataDict valueForKey:@"Member ID"];
        insurance.rxIN = [primaryInsDataDict valueForKey:@"RxIN"];
        insurance.rxPCN = [primaryInsDataDict valueForKey:@"RxPCN"];
        insurance.rxGroup = [primaryInsDataDict valueForKey:@"RxGroup"];
        insurance.backCardImage =   UIImagePNGRepresentation([primaryInsDataDict objectForKey:@"BackSide"]);
        insurance.frontCardImage = UIImagePNGRepresentation([primaryInsDataDict objectForKey:@"FrontSide"]);
        personData.insurance = insurance;
        //        personData.carrier =   [primaryInsDataDict valueForKey:@"Carrier"];
//        personData.groupNumber = [primaryInsDataDict valueForKey:@"Group Number"];
//        personData.memberNumber = [primaryInsDataDict valueForKey:@"Member ID"];
//        personData.rxIN = [primaryInsDataDict valueForKey:@"RxIN"];
//        personData.rxPCN = [primaryInsDataDict valueForKey:@"RxPCN"];
//        personData.rxGroup = [primaryInsDataDict valueForKey:@"RxGroup"];
//        personData.backCardImage =   [primaryInsDataDict objectForKey:@"BackSide"];
//        personData.cardImage = [primaryInsDataDict objectForKey:@"FrontSide"];
    }
    if (secondaryInsDataDict != nil) {
        MMLInsurance *insurance = [[CoreDataManager coreDataManager] newInsurance];
        insurance.carrier =   [secondaryInsDataDict valueForKey:@"Carrier"];
        insurance.memberNumber = [secondaryInsDataDict valueForKey:@"Member ID"];
        insurance.rxIN= [secondaryInsDataDict valueForKey:@"RxIN"];
        insurance.rxPCN = [secondaryInsDataDict valueForKey:@"RxPCN"];
        insurance.rxGroup = [secondaryInsDataDict valueForKey:@"RxGroup"];
        insurance.backCardImage =   UIImagePNGRepresentation([secondaryInsDataDict objectForKey:@"BackSide"]);
        insurance.frontCardImage = UIImagePNGRepresentation([secondaryInsDataDict objectForKey:@"FrontSide"]);
        personData.secondaryInsurance = insurance;

        
        
//        personData.carrier2 =   [secondaryInsDataDict valueForKey:@"Carrier"];
//        personData.groupNumber2 = [secondaryInsDataDict valueForKey:@"Group Number"];
//        personData.memberNumber2 = [secondaryInsDataDict valueForKey:@"Member ID"];
//        personData.rxIN = [secondaryInsDataDict valueForKey:@"RxPCN"];
//        personData.rxGroup2 = [secondaryInsDataDict valueForKey:@"RxGroup"];
//        personData.backCardImage2=   [secondaryInsDataDict objectForKey:@"BackSide"];
//        personData.cardImage2 = [secondaryInsDataDict objectForKey:@"FrontSide"];
    }
    if (self.image != nil) {
        personData.personImage = UIImagePNGRepresentation(image);
    }
  
    [[CoreDataManager coreDataManager] saveContext];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) saveAddressInfo:(NSDictionary *)dictionary {
    
  //  self.addressDataDict = [[[NSMutableDictionary alloc] initWithDictionary:dictionary] autorelease];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) saveInsuranceInfo:(NSDictionary *)dictionary isPrimary:(BOOL)isPrimary {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didFinishWithCamera
{
    [self dismissModalViewControllerAnimated:YES];
    self.pictureController = nil;
}
- (void)didTakePicture:(NSDictionary *)dictionary
{
    UIImage *picture = [dictionary valueForKey:UIImagePickerControllerOriginalImage];
   	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    UIImage *image2;
    if (picture.size.width < 64 && picture.size.height < 64) {
        image2 = picture;
        self.image = picture;
        personData.personImage = UIImagePNGRepresentation(self.image);
    } else {
        image2 = [[picture resizedImage:CGSizeMake(70,70) interpolationQuality:kCGInterpolationHigh ] thumbnailImage:70 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
        self.image = picture;
        personData.personImage = UIImagePNGRepresentation(self.image);

    }
    
    [addPhotoBtn removeLayer:@"Custom Text Layer"];
    [addPhotoBtn removeLayer:@"Custom User Image Layer"];
    [addPhotoBtn removeLayer:@"Custom Edit Text Layer"];
    
    [addPhotoBtn addImageLayer:@"Custom User Image Layer" withImage:image2];
    [addPhotoBtn addBottomTextLayer:@"Custom Edit Text Layer" withText:@"Edit"];
    
}

// The user will pick what to do with when the image is touched
- (void)displayEditPhotoActionSheet:(id)sender
{
    NSLog(@"displayEditPhotoActionSheet");
    
	UIActionSheet *editPhotoQuery = nil;
    if (personData.personImage != nil) {
        editPhotoQuery = [[UIActionSheet alloc] initWithTitle:@"Options to add or change the profile image"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"View Photo",@"Choose Photo",@"Take Photo",@"Delete Photo",nil];
        editPhotoQuery.tag = 6000;
    } else {
        editPhotoQuery   = [[UIActionSheet alloc] initWithTitle:@"Options to add or change the profile image"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"Choose Photo",@"Take Photo",@"Delete Photo",nil];
    }
	
	[editPhotoQuery showInView:self.navigationController.view];
    
	[editPhotoQuery release];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
    if(actionSheet.tag >= 6000)
	{
        if (buttonIndex == 0) {
            MMLPersonData *person = [[CoreDataManager coreDataManager] profileAtIndex:actionSheet.tag-6000];
			PictureViewerViewController *pictureViewerViewController = [[PictureViewerViewController alloc] initWithNibName:@"PictureViewerViewController" bundle:nil];
            pictureViewerViewController.cardImage = [UIImage imageWithData:person.personImage];
            pictureViewerViewController.delegate = self;
            [self presentModalViewController:pictureViewerViewController animated:YES];
            [pictureViewerViewController release];
        }
		if(buttonIndex == 1)
		{
            self.pictureController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureController.delegate = self;
            pictureController.imageSize = addPhotoBtn.frame.size;
            
			[pictureController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            [self presentModalViewController:pictureController.imagePickerController animated:YES];
            pictureController.view.tag = actionSheet.tag - 6000;
		}
		else if(buttonIndex == 2)
		{
			self.pictureController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureController.delegate = self;
            pictureController.imageSize = addPhotoBtn.frame.size;
            
			//Take a photograph with the camera.
			if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                [pictureController setupImagePicker:UIImagePickerControllerSourceTypeCamera];
			else
				[pictureController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];;
			
            pictureController.view.tag = actionSheet.tag - 6000;
			[self presentModalViewController:pictureController.imagePickerController animated:YES];
        }
		else if(buttonIndex == 3)
		{
            personData.personImage = nil;
            [addPhotoBtn removeLayer:@"Custom Text Layer"];
            [addPhotoBtn removeLayer:@"Custom User Image Layer"];
            [addPhotoBtn removeLayer:@"Custom Edit Text Layer"];
            [addPhotoBtn addTextLayer:@"Custom Text Layer" withText:@"add user photo"];
		}
		else if(buttonIndex == 4)
		{
            
		}
        else {
            
        }
	}
    else 	
	{
		if(buttonIndex == 0)
		{
            self.pictureController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureController.delegate = self;
            pictureController.imageSize = addPhotoBtn.frame.size;

			[pictureController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            [self presentModalViewController:pictureController.imagePickerController animated:YES];
            pictureController.view.tag = actionSheet.tag;
		}
		else if(buttonIndex == 1)
		{
			self.pictureController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureController.delegate = self;
            pictureController.imageSize = addPhotoBtn.frame.size;

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
            personData.personImage = nil;
            [addPhotoBtn removeLayer:@"Custom Text Layer"];
            [addPhotoBtn removeLayer:@"Custom User Image Layer"];
            [addPhotoBtn removeLayer:@"Custom Edit Text Layer"];
            [addPhotoBtn addTextLayer:@"Custom Text Layer" withText:@"add user photo"];
		}
		else if(buttonIndex == 3)
		{
			;
		}
    }
}


- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.datePicker removeFromSuperview];
    [self.toolBar removeFromSuperview];
}


- (void)doneAction:(id)sender
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = self.datePicker.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	CGRect endToolFrame = self.toolBar.frame;
    endToolFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	// start the slide down animation
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    // we need to perform some post operations after the animation is complete
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
    self.datePicker.frame = endFrame;
    self.toolBar.frame = endToolFrame;
	[UIView commitAnimations];
	
	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height += self.datePicker.frame.size.height;
	self.tableView.frame = newFrame;
	
	// remove the "Done" button in the nav bar
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;

	
	// deselect the current table row
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) displayDatePicker:(NSIndexPath *)indexPath {
	[tmpTextField resignFirstResponder];
	// check if our date picker is already on screen
	if (self.datePicker.superview == nil)
	{
		[self.view.window addSubview: self.datePicker];
        [self.view.window addSubview:self.toolBar];
        if (personData.dateOfBirth != nil) {
            datePicker.date = personData.dateOfBirth;
//            Date *date = [personData dateOfBirth];
//            NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
//            NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
//            [components setYear:date.year];
//            [components setMonth:date.month];
//            [components setDay:date.day];
//            datePicker.date = [calendar dateFromComponents:components];
        } else {
            NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
            NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
            [components setYear:1960];
            [components setMonth:1];
            [components setDay:1];
            datePicker.date = [calendar dateFromComponents:components];
        }
		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [self.datePicker sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		self.datePicker.frame = startRect;
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
        CGRect toolBarRect = CGRectMake(0, pickerRect.origin.y-44, toolBar.frame.size.width, toolBar.frame.size.height);
        self.toolBar.frame = CGRectMake(0.0,
                                        screenRect.origin.y + screenRect.size.height,
                                        pickerSize.width, pickerSize.height);
		// start the slide up animation
		[UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
		
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
		
        self.datePicker.frame = pickerRect;
		self.toolBar.frame = toolBarRect;
        // shrink the table vertical size to make room for the date picker
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height -= self.datePicker.frame.size.height;
        self.tableView.frame = newFrame;
		[UIView commitAnimations];
		self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
		// add the "Done" button to the nav bar
		//self.navigationItem.rightBarButtonItem = self.doneButton;
	}
}
- (void)pictureViewerDidDismiss:(PictureViewerViewController *)pictureViewerViewController
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) deleteUser:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete User" message:@"Do you want to delete the user profile?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
    [alertView release];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    } else if(buttonIndex ==1) {
        MMLMedicationList *list = personData.currentMedicationList;
        if (list != nil && [list.medicationList count] != 0) {
            NSSet *list1 = list.medicationList;
            for (MMLMedication *med in list1) {
                if ([RemindersViewController hasReminders:[med.creationID intValue]]) {
                    [RemindersViewController cancelAllReminders:[med.creationID intValue]];
                }
            }
        }
        [[CoreDataManager coreDataManager] deleteManagedObject:personData];
        [[CoreDataManager coreDataManager] saveContext];
            [self.navigationController popViewControllerAnimated:YES];
        
    }
}
@end
