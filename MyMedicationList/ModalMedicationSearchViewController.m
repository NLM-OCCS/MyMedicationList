//
//  ModalMedicationSearchViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//
#import "ModalMedicationSearchViewController.h"
#import "Medication.h"
#import "ModalMedicationInfoViewController.h"
#import "ModalMedicationSearchProtocol.h"
#import "unistd.h"
#import "DisplayNameService.h"
#import "LoadingView.h"
#import "CoreDataManager.h"

@interface ModalMedicationSearchViewController ()<UISearchBarDelegate,UISearchDisplayDelegate> {
	UISearchDisplayController *_searchCtrl;
	NSMutableArray *_medicationFound;
    
    DisplayNameService *_displayNameService;
}

@property (retain,nonatomic) LoadingView *loadingView;

@end


@implementation ModalMedicationSearchViewController
@synthesize loadingView = _loadingView;
@synthesize personData = _personData;
@synthesize delegate = _delegate;
@synthesize dataDelegate = _dataDelegate;

#pragma mark -
#pragma mark Initialization

static NSString *kFreeTextString = @"Enter free text...";

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
		
        self.navigationItem.title = @"Search";
        
		_medicationFound = [[NSMutableArray alloc] init];
		
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																					target:self
																					action:@selector(dismissSearch)];
		self.navigationItem.leftBarButtonItem = doneButton;
		[doneButton release];
		
			
		// Setup the search bar where the user enters the drug he/she is looking for
		UISearchBar *mySearchBar = [[UISearchBar alloc] init];
		mySearchBar.placeholder = @"Enter a medication name here.";
		//mySearchBar.showsCancelButton = YES;
		
		[mySearchBar sizeToFit];
		self.tableView.tableHeaderView = mySearchBar;				
		mySearchBar.delegate = self;

		// Setup the search display controller that manages the search bar
		_searchCtrl = [[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
		_searchCtrl.delegate = self;
		_searchCtrl.searchResultsDataSource = self;
		_searchCtrl.searchResultsDelegate = self;
		[mySearchBar release];
		
        _displayNameService = [DisplayNameService displayNameService];
        
        // Setup this view controller to be notified when the database is finished being updated
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(finishedUpdating:) 
                                                     name:MMLFinishedUpdatingDisplayNamesNotification 
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Deregistering for the notification");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MMLFinishedUpdatingDisplayNamesNotification object:nil];
    self.loadingView = nil;
    self.personData = nil;    
    self.delegate = nil;
    [_displayNameService release];
    _displayNameService = nil;
    [_searchCtrl release];
    _searchCtrl = nil;
	[_medicationFound release];
    _medicationFound = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
   // if ([DisplayNameService displayNameService].isUpdating)
       // self.loadingView = [LoadingView loadingViewInView:self.navigationController.view withMessage:@"Updating..."];
    [[CoreDataManager coreDataManager] rollBack];

    self.navigationController.toolbarHidden = YES;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([LoadingView isOnScreen])
        [_loadingView removeView]; 
}

- (void)finishedUpdating:(NSNotification *)notification
{
    NSLog(@"We have finished updating the display names database...");
    if([LoadingView isOnScreen])
        [_loadingView removeView];
}

// User discontinues searching for a medication, returns to the current medication list
- (void)dismissSearch
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark View lifecycle
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
	[searchBar resignFirstResponder];
}

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	NSLog(@"Search String: %@",searchString);
	[_medicationFound removeAllObjects];
	
	// We have a string of three characters or longer so we load the search results
	if ([searchString length] >= 3) {
		
		[_medicationFound addObjectsFromArray:[_displayNameService displayNamesForSearchString:searchString]];
		
        [_medicationFound addObject:kFreeTextString];   
		return YES;
	}
	// If we have entered less than three letters then the search
	// results should be clear
	else 
		return YES;

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Have a row for each medication display name found
	return [_medicationFound count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_medicationFound count] > 0)
    {
        if([[_medicationFound objectAtIndex:indexPath.row] isEqualToString:@""]){
            NSString *str =  [_medicationFound objectAtIndex:indexPath.row];
            CGSize size = [str  sizeWithFont:[UIFont systemFontOfSize:17.0f] 
                           constrainedToSize:CGSizeMake(tableView.frame.size.width, CGFLOAT_MAX)
                               lineBreakMode:UILineBreakModeWordWrap];
            if (size.height < 30) {
                return 44.0f;
            } else
                return size.height;
        } else {
            NSString *str =  [_medicationFound objectAtIndex:indexPath.row];
            NSString *nameStr = [_medicationFound objectAtIndex:indexPath.row];
            CGSize size;
            if ([str length] > [nameStr length]) {
                size = [nameStr  sizeWithFont:[UIFont systemFontOfSize:17.0f] 
                            constrainedToSize:CGSizeMake(tableView.frame.size.width, CGFLOAT_MAX)
                                lineBreakMode:UILineBreakModeWordWrap];
            } else {
                size = [str  sizeWithFont:[UIFont systemFontOfSize:17.0f] 
                        constrainedToSize:CGSizeMake(tableView.frame.size.width, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
            }
            if (size.height < 30) {
                return 44.0f;
            } else
                return size.height;
        }

    }
    return 44;

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
       // cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:50];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 0;
    }
    
    // Configure the cell...
	cell.textLabel.text = [_medicationFound objectAtIndex:indexPath.row];
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"didSelectRowAtIndexPath");
	UIViewController *medInfoViewController = nil;
    
    if([((NSString *)[_medicationFound objectAtIndex:indexPath.row]) compare:kFreeTextString] == NSOrderedSame)
    {
        
        FreeEntryTextViewController *freeTextViewController = [[FreeEntryTextViewController alloc] initWithNibName:@"FreeEntryTextViewController" bundle:nil];
        //freeTextViewController.delegate = _delegate;
        freeTextViewController.dataDelegate = _dataDelegate;
        freeTextViewController.person = self.personData;

        freeTextViewController.medName = _searchCtrl.searchBar.text;
        NSLog(@"freeTextEntered: %@",_searchCtrl.searchBar.text);
        medInfoViewController = freeTextViewController;
    }
    else
    {
        ModalMedicationInfoViewController *modalMedicationInfoViewController = [[ModalMedicationInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
        modalMedicationInfoViewController.personData = _personData;
        modalMedicationInfoViewController.delegate = _delegate;
        modalMedicationInfoViewController.displayName = [_medicationFound objectAtIndex:indexPath.row];
        modalMedicationInfoViewController.dataDelegate = _dataDelegate;

        medInfoViewController = modalMedicationInfoViewController;
	}
    
	[self.navigationController pushViewController:medInfoViewController animated:YES];
	[medInfoViewController release];

}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
}

@end

