//
//  AddressViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "AddressViewController.h"

@class ELCTextFieldCell;

@interface AddressViewController  (){
    UITextField *tmpTextField;
}
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) NSArray *placeholders;
@property (nonatomic,retain)  NSArray *labelPlaceholders;
-(void)  saveAddress:(id) sender;

@end

@implementation AddressViewController
@synthesize labels;
@synthesize placeholders;
@synthesize addressDataDict;
@synthesize labelPlaceholders;
@synthesize _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) dealloc {
    self.labels = nil;
    self.placeholders = nil;
    self.labelPlaceholders = nil;
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.labels = [NSArray arrayWithObjects:@"Street Addr",
                   @"Street Addr2",
                   @"City",
                   @"State",
                   @"Zip",
                   nil];
	
	self.placeholders = [NSArray arrayWithObjects:@"Enter Street Address",
                         @"Enter Street Address2",
                         @"Enter City",
                         @"Enter State",@"Enter Zip Code",nil];
    self.labelPlaceholders = [NSArray arrayWithObjects:@"Street Address",
                                              @"Street Address2",
                                              @"City",
                                              @"State",@"Zip Code", nil];
                         
    self.title = @"Address";
    
    UIBarButtonItem *rightbarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveAddress:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightbarButton;
    self.navigationItem.hidesBackButton = YES;

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddressCell";
    ELCTextFieldCell *cell;
    cell = (ELCTextFieldCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
         cell = [[[ELCTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
#pragma mark -
#pragma mark Table view data source

- (void)configureCell:(ELCTextFieldCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	cell.rightTextField.placeholder = [self.placeholders objectAtIndex:indexPath.row];
    if (addressDataDict != nil && [addressDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]] != nil) {
        cell.rightTextField.text = [addressDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]];
    }
	cell.indexPath = indexPath;
	cell.delegate = self;
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 15)] autorelease];
    cell.rightTextField.inset = UIEdgeInsetsMake(20, 0, 0, 0);
    cell.rightTextField.leftViewInset = UIEdgeInsetsMake(0, 0, 20, 0);
    label.text = [self.labelPlaceholders objectAtIndex:indexPath.row];
    label.textColor = [UIColor lightGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:13];
    cell.rightTextField.leftViewMode = UITextFieldViewModeAlways;
    cell.rightTextField.leftView = label;
    cell.rightTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    cell.rightTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;

    //Disables UITableViewCell from accidentally becoming selected.
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

}


- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if (tmpTextField == nil) {
        return YES;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview];
    [addressDataDict setValue:textField.text forKey:[self.labels objectAtIndex:indexPath.row] ];
	if(indexPath != nil && indexPath.row < [labels count]-1) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        [[(ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:path] rightTextField] becomeFirstResponder];
        return NO;
	}
	else {
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
       tmpTextField = textField;
        return YES;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


-(void) saveAddress:(id)sender {
    [tmpTextField resignFirstResponder];
    tmpTextField = nil;
	if([_delegate respondsToSelector:@selector(saveAddressInfo:)]) {
        [_delegate saveAddressInfo:addressDataDict];
	}
}
@end
