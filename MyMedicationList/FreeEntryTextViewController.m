//
//  FreeEntryTextViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "FreeEntryTextViewController.h"
#import "ELCTextFieldCell.h"
#import "MMLMedication.h"
#import "MedDetailInfoViewController.h"
#import "CoreDataManager.h"

@interface FreeEntryTextViewController() <ELCTextFieldDelegate>
@property (nonatomic, retain) NSArray *formArray;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) NSArray *placeholders;
@property (nonatomic,retain) IBOutlet UIPickerView *formPicker;
@property (nonatomic,retain) IBOutlet UIToolbar *toolbar;
-(IBAction) formPickerValueChanged:(id) formPicker;

-(IBAction) resignformPicker:(id)datePicker;

@end

@implementation FreeEntryTextViewController

@synthesize formArray,labels,placeholders,formPicker,toolbar,medName,person;

- (void) dealloc {
    self.formArray = nil;
    self.labels = nil;
    self.placeholders = nil;
    self.toolbar = nil;
    self.formPicker = nil;
    self.medName = nil;
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[CoreDataManager coreDataManager] rollBack];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
   self.formArray = [NSArray arrayWithObjects:@"Oral Tablet",
                          @"Extended Release Tablet",
                          @"Enteric Coated Tablet",
                          @"Extended Release Enteric Coated Capsule",
                          @"Oral Capsule",
                          @"Extended Release Capsule",
                          @"Enteric Coated Capsule",
                          @"Oral Solution",
                          @"Oral Suspension",
                          @"Mouthwash",
                          @"Ophthalmic Solution",
                          @"Toothpaste",
                          @"Vaginal Cream",
                          @"Vaginal Foam",
                          @"Vaginal Gel",
                          @"Vaginal Ring",
                          @"Vaginal Tablet",
                          @"Chewable Tablet",
                          @"Ophthalmic Ointment",
                          @"Medicated Shampoo",
                          @"Nasal Spray",
                          @"Irrigation Solution",
                          @"Ophthalmic Irrigation Solution",
                          @"Chewable Bar",
                          @"Disintegrating Tablet",
                          @"Extended Release Suspension",
                          @"Flakes",
                          @"Injectable Solution",
                          @"Injectable Suspension",
                          @"Intraperitoneal Solution",
                          @"Medicated Bar Soap",
                          @"Medicated Liquid Soap",
                          @"Mucous Membrane Topical Solution",
                          @"Nasal Inhalant",
                          @"Nasal Gel",
                          @"Nasal Ointment",
                          @"Nasal Solution",
                          @"Ophthalmic Gel",
                          @"Ophthalmic Suspension",
                          @"Oral Cream",
                          @"Otic Solution",
                          @"Otic Suspension",
                          @"Rectal Cream",
                          @"Rectal Suppository",
                          @"Sustained Release Buccal Tablet",
                          @"Topical Cream",
                          @"Topical Lotion",
                          @"Topical Oil",
                          @"Topical Ointment",
                          @"Topical Solution",
                          @"Transdermal Patch",
                          @"Wafer",
                          @"Lozenge",
                          @"Gas for Inhalation",
                          @"Inhalant Powder",
                          @"Powder Spray",
                          @"Rectal Ointment",
                          @"Sublingual Tablet",
                          @"Topical Powder",
                          @"Vaginal Ointment",
                          @"Rectal Foam",
                          @"Urethral Suppository",
                          @"Enema",
                          @"Topical Cake",
                          @"Granules",
                          @"Pellet",
                          @"Vaginal Suppository",
                          @"Inhalant Solution",
                          @"Mucosal Spray",
                          @"Oral Spray",
                          @"Topical Spray",
                          @"Oral Gel",
                          @"Rectal Gel",
                          @"Oral Paste",
                          @"Oral Foam",
                          @"Topical Foam",
                          @"Topical Gel",
                          @"Oral Ointment",
                          @"Oral Powder",
                          @"Paste",
                          @"Chewing Gum",
                          @"Douche",
                          @"Drug Implant",
                          @"Oral Strip",
                          @"Metered Dose Inhaler",
                          @"Nasal Inhaler",
                          @"Prefilled Syringe",
                          @"Dry Powder Inhaler",
                          @"Pack",
                          @"Prefilled Applicator",
                          @"Medicated Pad",
                          @"Medicated Tape",
                          @"Augmented Topical Cream",
                          @"Augmented Topical Lotion",
                          @"Augmented Topical Ointment",
                          @"Augmented Topical Gel",
                          @"Buccal Film",
                          @"Buccal Tablet",nil ];
    self.labels = [NSArray arrayWithObjects:@"Name",@"Strength",@"Form", nil];
    self.placeholders=[NSArray arrayWithObjects:@"Enter Name", @"Enter Strength", @"Enter Form", nil];

    UIBarButtonItem *rightbarButton = [[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(addMedication:)] autorelease];
    self.navigationItem.hidesBackButton = NO;
    //self.navigationItem.leftBarButtonItem = leftbarButton;
    self.navigationItem.rightBarButtonItem = rightbarButton;
    self.title = @"Medication Name";
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ELCTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ELCTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.rightTextField.placeholder = [self.placeholders objectAtIndex:indexPath.row];
    cell.indexPath = indexPath;
    cell.delegate = self;
    //Disables UITableViewCell from accidentally becoming selected.
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.rightTextField.inputView = nil;
    cell.rightTextField.inputAccessoryView = nil;;
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 15)] autorelease];
    cell.rightTextField.inset = UIEdgeInsetsMake(20, 0, 0, 0);
    cell.rightTextField.leftViewInset = UIEdgeInsetsMake(0, 0, 20, 0);
    label.text = [self.labels objectAtIndex:indexPath.row];
    label.textColor = [UIColor lightGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17];
    cell.rightTextField.leftViewMode = UITextFieldViewModeAlways;
    cell.rightTextField.leftView = label;

    if (indexPath.row == 2) {
        cell.rightTextField.inputView = self.formPicker;
        cell.rightTextField.inputAccessoryView = toolbar;
    }
    if (indexPath.row == 1) {
        cell.rightTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 55.0f;
    }
    return 55.0f;
    
}
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Add Medicine Name";
}


#pragma mark ELCTextFieldCellDelegate Methods

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview];
	if(indexPath != nil && indexPath.row < 1) {
        NSLog(@" textcellindex path Row is %d",indexPath.row);
		NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];       
        [[(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:path] rightTextField] becomeFirstResponder];
        return NO;
        
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
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview];
    NSLog(@"texcellBegin index path Row is %d",indexPath.row);
    formPicker.tag = indexPath.row;
    return YES;
}


// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    // Size for the single component
    return 295.0f;
}


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // Unit type is the only component in the picker
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.formArray count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.formArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"didSelectRow:%d inComponent:%d",row,component);
}


-(void) formPickerValueChanged:(id) picker {
    NSInteger row = [formPicker selectedRowInComponent:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    
    if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
        [[(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField] resignFirstResponder];
            [(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField].text = [self.formArray objectAtIndex:row];
    }

}

-(void) resignformPicker:(id)picker{
    NSInteger row = [formPicker selectedRowInComponent:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    
    if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
        [[(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField] resignFirstResponder];
        [(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath]  rightTextField].text = [self.formArray objectAtIndex:row];
    }
}
- (void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}
- (BOOL)isValidInput
{

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    ELCTextFieldCell *cell = (ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    if(cell != nil) {
       [[cell  rightTextField] resignFirstResponder];
        if ([cell rightTextField].text == nil || ([[cell rightTextField].text isEqualToString:@""])) {
                [self alertWithTitle:@"Empty Drug Name" message:@"Please enter a name for the drug"];
                return NO;
        }
    }  else {
        [self alertWithTitle:@"Empty Drug Name" message:@"Please enter a name for the drug"];
        return NO;
    }
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    cell = (ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    if(cell != nil) {
        [[cell  rightTextField] resignFirstResponder];
        if ([cell rightTextField].text == nil || ([[cell rightTextField].text isEqualToString:@""])) {
                [self alertWithTitle:@"Empty Strength" message:@"Please enter a strength for the drug"];
                return NO;
        }
    }  else {
            [self alertWithTitle:@"Empty Strength" message:@"Please enter a strength for the drug"];
            return NO;
    }
    indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    cell = (ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    if(cell != nil) {
        [[cell  rightTextField] resignFirstResponder];
        if ([cell rightTextField].text == nil || ([[cell rightTextField].text isEqualToString:@""])) {
             [self alertWithTitle:@"Empty Unit" message:@"Please enter a unit for the drug"];
            return NO;
        }
    }  else {
        [self alertWithTitle:@"Empty Unit" message:@"Please enter a unit for the drug"];
        return NO;
    }
    return YES;
}

- (void)addMedication:(id)sender
{
    NSLog(@"AddMedication");
    
    if([self isValidInput])
    {
        //Medication *medication = [[[Medication alloc] init] autorelease];
        MMLMedication *medication =     [[CoreDataManager coreDataManager]newMedication];
        NSMutableString *medicationName = [[[NSMutableString alloc] init] autorelease];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        ELCTextFieldCell *cell = (ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        NSString *name = cell.rightTextField.text;
        
        indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        cell = (ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        NSString *strength = cell.rightTextField.text;
        
        indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        cell = (ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        NSString *form = cell.rightTextField.text;
        // Assumes that the only valid input contains both a name, strength, and unit
        [medicationName appendString:[NSString stringWithFormat:@"%@ %@ %@",name,strength,form]];
        //ConceptProperty *concept = [[[ConceptProperty alloc] init] autorelease];
        MMLConceptProperty *concept = [[CoreDataManager coreDataManager] newConceptProperty];
        concept.name = medicationName;
        concept.synonym = medicationName;
        
        medication.conceptProperty = concept;
        medication.name = medicationName;
        unsigned int creationID = [[NSDate date] timeIntervalSince1970];
        
        medication.creationID = [NSNumber numberWithUnsignedInt:creationID];
        
        MedDetailInfoViewController *medicationDataViewController = [[MedDetailInfoViewController alloc] initWithNibName:@"MedDetailInfoViewController" bundle:nil];
        medicationDataViewController.delegate = _dataDelegate;
        medicationDataViewController.medication = medication;
        medicationDataViewController.person = person;
        
        [self.navigationController pushViewController:medicationDataViewController animated:YES];
        [medicationDataViewController release];    }
}
@end
