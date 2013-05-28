//
//  MedSigViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MedSigViewController.h"
#import "MedicationAmount.h"
#import "MedicationFrequency.h"
#import "MedicationInstruction.h"
#import <QuartzCore/QuartzCore.h>


@interface MedSigViewController ()<UITextViewDelegate> {
    int selectedRow;
    int lastRowSelected;
    
}

@property(nonatomic,retain)     UITextView *instructionsNote;
@property (nonatomic,retain) NSArray *intervalArray;
@property(retain,nonatomic) UIBarButtonItem *doneBtn;
@property (retain,nonatomic) NSMutableArray *selectedIndexes;
@property (retain,nonatomic) NSString *instrValue;

@end

@implementation MedSigViewController
@synthesize type;
@synthesize delegate;
@synthesize selectedIndex;
@synthesize selectedValue;
@synthesize instructionsNote;
@synthesize readOnly,intervalArray,doneBtn,selectedIndexes,instrValue;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
   // [instructionsNote release];
    self.type = nil;
    self.selectedValue = nil;
    self.instructionsNote = nil;
    self.intervalArray = nil;
    self.doneBtn = nil;
    self.selectedIndexes = nil;
    self.instrValue = nil;
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.instructionsNote = [[[UITextView alloc] initWithFrame:CGRectMake(10, 10, 280, 120)] autorelease];
    self.instructionsNote.delegate = self;
    self.instructionsNote.backgroundColor = [UIColor clearColor];
    
    selectedRow = -1;
    lastRowSelected = -1;
    self.doneBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone
                                                 target:self
                                                 action:@selector(saveAndDismiss)] autorelease];
    
    self.navigationItem.rightBarButtonItem = doneBtn;
    self.navigationItem.hidesBackButton = NO;
    selectedRow = self.selectedIndex;
    self.instrValue = self.selectedValue;
    self.title = type;
    self.tableView.allowsMultipleSelection = YES;
    [self.tableView reloadData];
    if (readOnly) {
        self.tableView.userInteractionEnabled = NO;
        self.navigationItem.rightBarButtonItem = nil;

    }
    self.selectedIndexes = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    
    self.intervalArray = [NSArray arrayWithObjects:@"Every One Hour", @"Every Two Hours", @"Every Three Hours",
                          @"Every Four Hours", @"Every Six Hours", @"Every Eight Hours", @"Every Twelve Hours",@"Daily", @"Weekly", @"Monthly",nil];

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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([type isEqualToString:@"Instructions" ] && indexPath.row == NumberOfInstructions) {
        return 140.0f;
    }
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //[MedicationInstruction stringForDefinedInstruction:(MedicationDefinedInstruction)indexPath.row];
    if ([type isEqualToString:@"Amount"]) {
        return NumberOfAmountTypes;
    }
    if ([type isEqualToString:@"Frequency"]) {
        return NumberOfFrequencies;
        
    }
    if ([type isEqualToString:@"Instructions"]) {
        return NumberOfInstructions+1;
    }
    if ([type isEqualToString:@"Repeat Interval"]) {
        return 10;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ([type isEqualToString:@"Amount"]) {
        [MedicationAmount amountTypeStringForAmountType:(MedicationAmountType)indexPath.row];
    }
    if ([type isEqualToString:@"Frequency"]) {
        cell.textLabel.text = [MedicationFrequency frequencyStringForFrequency:(Frequency)indexPath.row];
    }
    if ([type isEqualToString:@"Instructions"]) {
        if (indexPath.row < NumberOfInstructions) {
            cell.textLabel.text = [MedicationInstruction stringForDefinedInstruction:(MedicationDefinedInstruction)indexPath.row];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TextViewCellIndentifier"];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextViewCellIndentifier"] autorelease];
                [instructionsNote setDelegate:self];
                [instructionsNote setReturnKeyType:UIReturnKeyDone];
                [instructionsNote setText:@"Enter custom instructions here"];
                [instructionsNote setTextColor:[UIColor lightGrayColor]];
                [instructionsNote setFont:[UIFont systemFontOfSize: 17 ]];
                self.instrValue = [self.instrValue stringByReplacingOccurrencesOfString:@"|" withString:@" "];
                self.instrValue = [self.instrValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (self.instrValue != nil && ![self.instrValue isEqualToString:@""] ) {
                    [instructionsNote setText:self.instrValue];
                    [instructionsNote setTextColor:[UIColor blackColor]];

                }
                instructionsNote.layer.borderColor = [UIColor grayColor].CGColor;
                instructionsNote.layer.borderWidth = 1.0;
            }
            [cell.contentView addSubview:instructionsNote];
        }
    }
    if ([type isEqualToString:@"Repeat Interval"]) {
        cell.textLabel.text = [self.intervalArray objectAtIndex:indexPath.row];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (selectedRow == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    if (selectedRow == 5000 && [type isEqualToString:@"Instructions"]) {
        NSArray *components = [selectedValue componentsSeparatedByString:@"|"];
        if ([components count] > 1) {
            for (int i=0; i < [components count];i++) {
                if ([[components objectAtIndex:i] compare:cell.textLabel.text options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [selectedIndexes removeObject:[NSNumber numberWithInt:[indexPath row] ]];
                    [selectedIndexes addObject:[NSNumber numberWithInt:[indexPath row] ]];
                    self.instrValue = [self.instrValue stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",cell.textLabel.text] withString:@" "];
                }
            }
        } else {
            if ([selectedValue  compare:cell.textLabel.text options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [selectedIndexes removeObject:[NSNumber numberWithInt:[indexPath row] ]];
                [selectedIndexes addObject:[NSNumber numberWithInt:[indexPath row] ]];
                self.instrValue = [self.instrValue stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@",cell.textLabel.text] withString:@" "];
            }

        }
    }
    if ([type isEqualToString:@"Repeat Interval"]) {
        if ([self.selectedValue isEqualToString:cell.textLabel.text]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    // Configure the cell...
    if (readOnly) {
        cell.userInteractionEnabled = NO;
    }
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([type isEqualToString:@"Instructions"] ) {
        if (indexPath.row < NumberOfInstructions) {
            [instructionsNote resignFirstResponder];
            if([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark){
                [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
                [selectedIndexes removeObject:[NSNumber numberWithInt:[indexPath row] ]];
            }else{
                [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
                [selectedIndexes addObject:[NSNumber numberWithInt:[indexPath row] ]];
            }
        } else {
        }
    } else {
        selectedRow = indexPath.row;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.selectedValue = cell.textLabel.text;
        NSIndexSet *set = [[NSIndexSet alloc]initWithIndex:0];
        [tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        [set release];
    }
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView.textColor == [UIColor lightGrayColor]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([instructionsNote.text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(textView.text.length == 0){
            textView.textColor = [UIColor lightGrayColor];
            textView.text = @"Enter custom instructions here";
            [textView resignFirstResponder];
        }
        return NO;
    }
    
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if(selectedRow != -1 && selectedRow != 5000) // Something else was selected.
	{

			lastRowSelected = selectedRow;
            selectedRow = -1;
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:lastRowSelected inSection:0]]
								  withRowAnimation:UITableViewRowAnimationNone];
		
	} else {
	  lastRowSelected = -1;
	  self.instrValue = @"";
	}
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				  target:self
																				  action:@selector(cancelTextEditing)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				target:self
																				action:@selector(doneAndResign)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	
	self.tableView.userInteractionEnabled = NO;
}
- (void) textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = doneBtn;
    doneBtn.title = @"Save";
	self.navigationItem.leftBarButtonItem = nil;
	self.tableView.userInteractionEnabled = YES;
}
- (void) doneAndResign
{
	[instructionsNote resignFirstResponder];
	self.navigationItem.rightBarButtonItem = doneBtn;
    doneBtn.title = @"Save";
	self.navigationItem.leftBarButtonItem = nil;
	self.tableView.userInteractionEnabled = YES;
    NSString *text = [instructionsNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text != nil && [text length] == 0) {
        instructionsNote.textColor = [UIColor lightGrayColor];
        instructionsNote.text = @"Enter custom instructions here";
        [instructionsNote resignFirstResponder];
    } 
    
}

- (void) saveAndDismiss
{

    if ([type isEqualToString:@"Frequency"]) {
        if (selectedRow != -1) {
            MedicationFrequency *frequency = [[[MedicationFrequency alloc]initWithFrequency:(Frequency)selectedRow] autorelease];
            [delegate medSigResponse:self withFrequency:frequency];
        }
    }
    if ([type isEqualToString:@"Instructions"]) {
        MedicationInstruction *instruction;
        NSMutableString *instrString = nil;
        
        if ([selectedIndexes count] > 1 && instructionsNote.textColor == [UIColor lightGrayColor] ) {
            for (int i=0; i < [selectedIndexes count]; i++) {
                NSNumber *ip = [selectedIndexes objectAtIndex:i];
                MedicationInstruction *instruction = [[[MedicationInstruction alloc] initWithDefinedInstruction:(MedicationDefinedInstruction)[ip intValue]] autorelease];
                if (instrString == nil) {
                    instrString = [[NSMutableString alloc] initWithCapacity:200];
                }
                [instrString appendFormat:@"|%@",[instruction printInstruction] ];
                
            }
            NSString *text = [instructionsNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (text != nil && [text length] == 0 && ![text isEqualToString:@"Enter custom instructions here"]) {
                [instrString appendFormat:@"|%@",text ];
            }
            if (instrString != nil)
             instruction = [[[MedicationInstruction alloc]initWithCustomInstruction:instrString] autorelease];
            [delegate medSigResponse:self withInstruction:instruction];
        } else if ([selectedIndexes count] == 1 && instructionsNote.textColor == [UIColor lightGrayColor]) {
            int selected = [[selectedIndexes objectAtIndex:0] intValue];
            if (selected < NumberOfInstructions && selected != -1) {
                instruction = [[[MedicationInstruction alloc] initWithDefinedInstruction:(MedicationDefinedInstruction)selected] autorelease];
            } else {
                instruction = [[[MedicationInstruction alloc]initWithCustomInstruction:instructionsNote.text] autorelease];
            }
            [delegate medSigResponse:self withInstruction:instruction];
        } else {
            if ([selectedIndexes count] > 0) {
                for (int i=0; i < [selectedIndexes count]; i++) {
                    NSNumber *ip = [selectedIndexes objectAtIndex:i];
                    MedicationInstruction *instruction = [[[MedicationInstruction alloc] initWithDefinedInstruction:(MedicationDefinedInstruction)[ip intValue]] autorelease];
                    if (instrString == nil) {
                        instrString = [[NSMutableString alloc] initWithCapacity:200];
                    }
                    [instrString appendFormat:@"|%@",[instruction printInstruction] ];
                    
                }
                NSString *text = [instructionsNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (text != nil && ![text length] == 0 && ![text isEqualToString:@"Enter custom instructions here"]) {
                    [instrString appendFormat:@"|%@",text ];
                }
                instruction = [[[MedicationInstruction alloc]initWithCustomInstruction:instrString] autorelease];
                [delegate medSigResponse:self withInstruction:instruction];

            } else {
                NSString *text = [instructionsNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (text != nil && [text length] == 0 && ![text isEqualToString:@"Enter custom instructions here"]) {
                instruction = [[[MedicationInstruction alloc]initWithCustomInstruction:instructionsNote.text] autorelease];
                [delegate medSigResponse:self withInstruction:instruction];
                }
            }
            
        }
        
        if (instrString != nil)
            [instrString release];

    }
    if ([type isEqualToString:@"Repeat Interval"]) {
        if (selectedRow != -1) {
            [delegate medSigResponse:self withRepeatInterval:[self.intervalArray objectAtIndex:selectedRow]];
        }
    }
    
    //
   	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelTextEditing
{
	[instructionsNote resignFirstResponder];
    NSString *text = [instructionsNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text != nil && [text length] == 0) {
        instructionsNote.textColor = [UIColor lightGrayColor];
        instructionsNote.text = @"Enter custom instructions here";
    }
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = doneBtn;
    self.instrValue = self.selectedValue;
	self.tableView.userInteractionEnabled = YES;
    lastRowSelected = -1;
    doneBtn.title = @"Save";
}
@end
