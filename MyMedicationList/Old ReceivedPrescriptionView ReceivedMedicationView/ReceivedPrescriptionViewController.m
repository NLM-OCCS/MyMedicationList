//
//  ReceivedPrescriptionViewController.m
//  MyMedList
//
//  Created by Andrew on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReceivedPrescriptionViewController.h"
#import "ReceivedMedicationViewController.h"
#import "PersonData.h"
#import "DetailedMedicationCell.h"
#import "ShortMedicationCell.h"
#import "MedicationList.h"


@interface ReceivedPrescriptionViewController () <UIActionSheetDelegate>//<ReceivedMedicationDelegate,UIActionSheetDelegate> 
{
    
    NSMutableArray *_isSelectedPrescription;
    
    BOOL _useDetailView;
    
    // The number of prescriptions that are currently selected
    // Used to determine whether the user should 'Add' or is 'Done'
    NSUInteger _numSelected;
}

@end

@implementation ReceivedPrescriptionViewController
@synthesize delegate=_delegate;
@synthesize isFromImport=_isFromImport;
@synthesize receivedMedicationListName=_receivedMedicationListName;
@synthesize personData=_personData;
@synthesize currentMedications=_currentMedications;
@synthesize discontinuedMedications=_discontinuedMedications;
@synthesize prescribedMedications=_prescribedMedications;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _isFromImport = YES;
        _prescribedMedications = [[NSMutableArray alloc] init];
        _numSelected = 0;
    }
    return self;
}

- (void)dealloc
{
    [_receivedMedicationListName release];
    [_personData release];
    [_currentMedications release];
    [_discontinuedMedications release];
    [_prescribedMedications release];
    [_isSelectedPrescription release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    // Get sizing information about the label text to be added to the navigation bar
    NSString *prescriptionString = @"Prescriptions";
    UIFont *prescriptionStringFont = [UIFont fontWithName:@"MarkerFelt-Thin" size:24.0f];
    CGSize prescriptionLabelSize = [prescriptionString sizeWithFont:prescriptionStringFont];
    
    // Set up the label telling the user the content of the list
    UILabel *prescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, prescriptionLabelSize.width, prescriptionLabelSize.height)];
    prescriptionLabel.backgroundColor = [UIColor clearColor];
    prescriptionLabel.textColor = [UIColor whiteColor];
    prescriptionLabel.font = prescriptionStringFont;
    prescriptionLabel.text = prescriptionString;
    
    self.navigationItem.titleView = prescriptionLabel;
    [prescriptionLabel release];
    
    // Give extra room in the navigation bar by adding an empty prompt
    self.navigationItem.prompt = @"";
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                       style:UIBarButtonItemStyleBordered 
                                                                      target:self
                                                                      action:@selector(doneAndReturnHome)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightBarButton release];
    
    /*
    if(!_isFromImport)
    {
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"MedList" 
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(showMedList)];
        self.navigationItem.leftBarButtonItem = leftBarButton;
        [leftBarButton release];
    }
     */
    
    // Setup the array which records whether or not a given cell in the tableview is selected
    _isSelectedPrescription = [[NSMutableArray alloc] initWithCapacity:[_currentMedications count]];
    for(NSUInteger index = 0; index < [_prescribedMedications count]; index++)
        [_isSelectedPrescription addObject:[NSNumber numberWithBool:NO]];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [_prescribedMedications count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_useDetailView)
        return [DetailedMedicationCell cellHeight];
	else
		return [ShortMedicationCell cellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    static NSString *MedicationCellIdentifier = @"MedicationCell";
 	static NSString *PlainCellIdentifier = @"PlainCell";
	
    UITableViewCell *cell;
	if(!_useDetailView)
	{
        cell = [tableView dequeueReusableCellWithIdentifier:PlainCellIdentifier];
        
        if (cell == nil) {
            cell = [[[ShortMedicationCell alloc] initWithType:ShortCurrentMedicationCell reuseIdentifier:PlainCellIdentifier] autorelease];
        }
        [(ShortMedicationCell *)cell setMedicationData:[_prescribedMedications objectAtIndex:indexPath.row]];
        
	}
	else
	{
        cell = [tableView dequeueReusableCellWithIdentifier:MedicationCellIdentifier];	
        if (cell == nil) {
            cell = [[[DetailedMedicationCell alloc] initWithType:DetailedCurrentMedicationCell reuseIdentifier:MedicationCellIdentifier] autorelease];
        }
        [(DetailedMedicationCell *)cell setMedicationData:[_prescribedMedications objectAtIndex:indexPath.row]];
	}
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


// When this view controller is not flipped it will be dismissed and the home screen will reappear
- (void)doneAndReturnHome
{
    NSLog(@"doneAndReturnHome");
	[_delegate receivedPrescriptionViewControllerDidDismiss:self];
}

- (void)updateMedicationActionButton
{
    if(_numSelected == 0)
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                           style:UIBarButtonItemStyleBordered 
                                                                          target:self
                                                                          action:@selector(doneAndReturnHome)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [doneButton release];
    }
    else
    {
        // We only need to add the 'Add' button once, this is a minor efficiency improvement
        if(![self.navigationItem.rightBarButtonItem.title isEqualToString:@"Add"])
        {
            UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" 
                                                                               style:UIBarButtonItemStyleBordered 
                                                                              target:self
                                                                              action:@selector(addPrescriptionsActionSheet)];
            self.navigationItem.rightBarButtonItem = addButton;
            [addButton release];
        }
    }
}

- (void)addPrescriptionsActionSheet
{
    UIActionSheet *addPrescriptionQuery = [[UIActionSheet alloc] initWithTitle:@"Add these prescriptions to your medication list?"
                                                                      delegate:self 
                                                             cancelButtonTitle:@"No" 
                                                        destructiveButtonTitle:nil
                                                             otherButtonTitles:@"Yes", nil];
    [addPrescriptionQuery showInView:self.navigationController.view];
    [addPrescriptionQuery release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSLog(@"Yes Button");
        NSMutableArray *deleteRowsIndexPaths = [[[NSMutableArray alloc] init] autorelease];
        for(NSUInteger index = 0; index < [_prescribedMedications count]; index++)
        {
            if([[_isSelectedPrescription objectAtIndex:index] boolValue])
            {
                //((Medication *)[_prescribedMedications objectAtIndex:index]).onMedList = YES;
                [deleteRowsIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            }
        }
        
        //[self updateCurrentMedications];
        
        _numSelected = 0;
        [self updateMedicationActionButton];
        
        [self.tableView deleteRowsAtIndexPaths:deleteRowsIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
        NSLog(@"No Button");
    }
}

/*
- (void)receivedMedicationViewControllerDidDismiss:(ReceivedMedicationViewController *)receivedMedicationViewController
{
    [self dismissModalViewControllerAnimated:YES];
}
*/
 
- (void)showMedList
{
    /*
    ReceivedMedicationViewController *receivedMedicationViewController = [[ReceivedMedicationViewController alloc] initWithStyle:UITableViewStyleGrouped];
    receivedMedicationViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    receivedMedicationViewController.delegate = self;
    receivedMedicationViewController.currentMedications = self.currentMedications;
    receivedMedicationViewController.discontinuedMedications = self.discontinuedMedications;
    receivedMedicationViewController.prescribedMedications = self.prescribedMedications;    
    receivedMedicationViewController.receivedMedicationListName = self.receivedMedicationListName;
    
    UINavigationController *medListNavigationController = [[UINavigationController alloc] initWithRootViewController:receivedMedicationViewController];
    [receivedMedicationViewController release];
    
    [self presentModalViewController:medListNavigationController animated:YES];
    [medListNavigationController release];
     */
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if([[_isSelectedPrescription objectAtIndex:indexPath.row] boolValue])
    {
        [tableView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor whiteColor];
        [_isSelectedPrescription replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
        _numSelected--;
    }
    else
    {
        [tableView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor greenColor];
        [_isSelectedPrescription replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        _numSelected++;
    }
    
    [self updateMedicationActionButton];
}

@end
