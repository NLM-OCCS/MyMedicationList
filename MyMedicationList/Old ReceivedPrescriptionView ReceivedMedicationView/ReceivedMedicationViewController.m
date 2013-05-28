//
//  ReceivedMedicationViewController.m
//  MyMedList
//
//  Created by Andrew on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReceivedMedicationViewController.h"


@interface ReceivedMedicationViewController () <UIActionSheetDelegate> {
    UISegmentedControl *medListChoice;
	//UINavigationBar *nameNavBar;
	UILabel *medListUserTitle;
    
    NSMutableArray *isSelectedPrescription;
    
    id<ReceivedMedicationDelegate> delegate;
	
@private
	BOOL useDetailView;
    NSUInteger numSelected;
}

@end


@implementation ReceivedMedicationViewController
@synthesize currentMedications=_currentMedications;
@synthesize discontinuedMedications=_discontinuedMedications;
@synthesize prescribedMedications=_prescribedMedications;
@synthesize receivedMedicationListName=_receivedMedicationListName;
@synthesize delegate=_delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    NSLog(@"initWithStyle RecievedMedication");
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        useDetailView = NO;
		_prescribedMedications = [[MedicationList alloc] initWithArchiveName:@"TempPrescribedMedications"];
        numSelected = 0;
     }
    return self;
}

- (void)dealloc
{
    [medListChoice release];
    [isSelectedPrescription release];
    [_prescribedMedications release];
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
    NSLog(@"viewDidLoad RecievedMedication");
    
    self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    medListChoice = [[UISegmentedControl alloc] initWithFrame: CGRectZero];
    medListChoice.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    medListChoice.segmentedControlStyle = UISegmentedControlStyleBar;
    [medListChoice insertSegmentWithTitle:@"Current" atIndex:0 animated:NO];
    [medListChoice insertSegmentWithTitle:@"Discontinued" atIndex:1 animated:NO];
    [medListChoice sizeToFit];
    medListChoice.selectedSegmentIndex = 0;
    [medListChoice addTarget:self action:@selector(chooseMedList) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = medListChoice;
    
    self.navigationItem.prompt = @"";
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Return" 
                                                                       style:UIBarButtonItemStyleBordered 
                                                                      target:self
                                                                      action:@selector(doneAndReturnHome)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightBarButton release];
    

    UIFont *nameFont = [UIFont fontWithName:@"MarkerFelt-Thin" size:24.0f];
    CGSize nameSize = [_receivedMedicationListName sizeWithFont:nameFont];
    
    medListUserTitle = [[[UILabel alloc] initWithFrame:CGRectMake((320.0-nameSize.width)/2.0, 7, nameSize.width, nameSize.height)] autorelease];
    medListUserTitle.text = _receivedMedicationListName;
    medListUserTitle.textColor = [UIColor whiteColor];
    medListUserTitle.backgroundColor = [UIColor clearColor];
    medListUserTitle.font = nameFont;
	
	[self.navigationController.navigationBar addSubview:medListUserTitle];

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
    
    //self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    /*
    if(medListUserTitle == nil)
	{
		UIFont *nameFont = [UIFont fontWithName:@"MarkerFelt-Thin" size:24.0f];
		CGSize nameSize = [_receivedMedicationListName sizeWithFont:nameFont];
		
		medListUserTitle = [[[UILabel alloc] initWithFrame:CGRectMake((320.0-nameSize.width)/2.0, 7, nameSize.width, nameSize.height)] autorelease];
		medListUserTitle.text = _receivedMedicationListName;
		medListUserTitle.textColor = [UIColor whiteColor];
		medListUserTitle.backgroundColor = [UIColor clearColor];
		medListUserTitle.font = nameFont;
	}
	
	[self.navigationController.navigationBar addSubview:medListUserTitle];
     */
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

- (void)printIndexSet:(NSMutableIndexSet *)indexSet
{
    NSLog(@"printIndexSet");
    while([indexSet count] != 0)
    {
        NSUInteger index = [indexSet firstIndex];
        NSLog(@"Index: %d",index);
        [indexSet removeIndex:index];
    }
}

/*
- (void)updateCurrentMedications
{
    NSLog(@"updateCurrentMedications ReceivedMedications");
    
    NSMutableArray *currentIndices = [[NSMutableArray alloc] init];
    
    // Get the indices of all the prescribed medications being added to the current medication list
    for(NSUInteger index = 0; index < [_prescribedMedications count]; index++)
    {
        if(((Medication *)[_prescribedMedications objectAtIndex:index]).onMedList)
        {
            NSLog(@"Is onMedList at index %d",index);
            [currentIndices addObject:[NSNumber numberWithInt:index]];
        }
    }
    
    // If there are no medications to add then we are done
    if([currentIndices count] == 0)
    {
        [currentIndices release];
        return;
    }
    
    // Add the appropriate medications from the prescribed medication list to the current medication list
    for(NSUInteger index = 0; index < [currentIndices count]; index++)
    {
        NSUInteger currentIndex = [[currentIndices objectAtIndex:index] intValue];
        [_currentMedications addObject:[_prescribedMedications objectAtIndex:currentIndex]];
    }
    
    // Set up an index set with all the indices of medications we'll delete from the prescription list because they we're added to the current medication list
    // The medications from the current medication list that we deleted
    // The medications that were added to current medication list from the prescription list. To delete them we set up an index set of those indices
    NSMutableIndexSet *currentIndexSet = [[NSMutableIndexSet alloc] init];
    for(NSNumber *index in currentIndices)
        [currentIndexSet addIndex:[index intValue]];
    
    // Delete the medication that are not current
    [_prescribedMedications removeObjectsAtIndexes:currentIndexSet];
    // Delete the indices that no longer refer to medications in the prescription list
    [isSelectedPrescription removeObjectsAtIndexes:currentIndexSet]; 
    [currentIndices release];
    [currentIndexSet release];
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection ReceivedMedications");
    // Return the number of rows in the section.

        if(medListChoice.selectedSegmentIndex == 0)
            return [_currentMedications count];
        else
            return [_discontinuedMedications count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(useDetailView)
        return [DetailedMedicationCell cellHeight];
	else
		return [ShortMedicationCell cellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *MedicationCellIdentifier = @"MedicationCell";
	static NSString *DiscontinuedCellIdentifier = @"DiscontinuedCell";
 	static NSString *PlainCellIdentifier = @"PlainCell";
	
    UITableViewCell *cell;
	if(!useDetailView)
	{
        
        cell = [tableView dequeueReusableCellWithIdentifier:PlainCellIdentifier];

        if(medListChoice.selectedSegmentIndex == 0)
		{
			if (cell == nil) {
                cell = [[[ShortMedicationCell alloc] initWithType:ShortCurrentMedicationCell reuseIdentifier:PlainCellIdentifier] autorelease];
            }
         
            [(ShortMedicationCell *)cell setMedicationData:[_currentMedications objectAtIndex:indexPath.row]];
        }
        else
        {
         	if (cell == nil) {
                cell = [[[ShortMedicationCell alloc] initWithType:ShortDiscontinuedMedicationCell reuseIdentifier:PlainCellIdentifier] autorelease];
            }
            
            [(ShortMedicationCell *)cell setMedicationData:[_discontinuedMedications objectAtIndex:indexPath.row]];
        }
        
	}
	else
	{
        cell = [tableView dequeueReusableCellWithIdentifier:MedicationCellIdentifier];	
		if(medListChoice.selectedSegmentIndex == 0)
		{
			
			if (cell == nil) {
                cell = [[[DetailedMedicationCell alloc] initWithType:DetailedCurrentMedicationCell reuseIdentifier:MedicationCellIdentifier] autorelease];
            }
            
            [(DetailedMedicationCell *)cell setMedicationData:[_currentMedications objectAtIndex:indexPath.row]];

 		}
		else
		{
		
			if (cell == nil) {
                cell = [[[DetailedMedicationCell alloc] initWithType:DetailedDiscontinuedMedicationCell reuseIdentifier:DiscontinuedCellIdentifier] autorelease];
            }
            
            [(DetailedMedicationCell *)cell setMedicationData:[_discontinuedMedications objectAtIndex:indexPath.row]];
        }
	}
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)chooseMedList
{
	// Calls cellforRowAtIndexPath to change the background image for the cells
	[self.tableView reloadData];
}

// When this view controller is not flipped it will be dismissed and the home screen will reappear
- (void)doneAndReturnHome
{
    NSLog(@"doneAndReturnHome");
	[_delegate receivedMedicationViewControllerDidDismiss:self];
}

- (void)updateMedicationActionButton
{
    if(numSelected == 0)
    {
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                           style:UIBarButtonItemStyleBordered 
                                                                          target:self
                                                                          action:@selector(doneAndReturnHome)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
        [rightBarButton release];
    }
    else
    {
        // We only need to add the 'Add' button once, this is a minor efficiency consideration
        if(![self.navigationItem.rightBarButtonItem.title isEqualToString:@"Add"])
        {
            UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" 
                                                                               style:UIBarButtonItemStyleBordered 
                                                                              target:self
                                                                              action:@selector(addPrescriptions)];
            self.navigationItem.rightBarButtonItem = rightBarButton;
            [rightBarButton release];
        }
    }
}

- (void)addPrescriptions
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
        NSLog(@"ButtonIndex 0");

        NSMutableArray *deleteRowsIndexPaths = [[[NSMutableArray alloc] init] autorelease];
        for(NSUInteger index = 0; index < [_prescribedMedications count]; index++)
        {
            if([[isSelectedPrescription objectAtIndex:index] boolValue])
            {
                //((Medication *)[_prescribedMedications objectAtIndex:index]).onMedList = YES;
                NSLog(@"Yes value at index %d",index);
                [deleteRowsIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            }
        }
        
        //[self updateCurrentMedications];
        numSelected = 0;
        [self updateMedicationActionButton];

        [self.tableView deleteRowsAtIndexPaths:deleteRowsIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
        NSLog(@"ButtonIndex 1");
    }
}

/*
- (void)showMedList
{
    ReceivedMedicationViewController *medListViewController = [[ReceivedMedicationViewController alloc] initWithStyle:UITableViewStyleGrouped];
    medListViewController.delegate = self;
    medListViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    medListViewController.isMedList = YES;
    medListViewController.currentMedications = self.currentMedications;
    medListViewController.discontinuedMedications = self.discontinuedMedications;
    medListViewController.receivedMedicationListName = self.receivedMedicationListName;
    
    medListViewController.prescribedMedications = self.prescribedMedications;
    
    UINavigationController *medListNavigationController = [[UINavigationController alloc] initWithRootViewController:medListViewController];
    [medListViewController release];
    
    [self presentModalViewController:medListNavigationController animated:YES];
    [medListNavigationController release];
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    NSLog(@"You selected the cell at row %d, section %d",indexPath.row, indexPath.section);
}

@end
