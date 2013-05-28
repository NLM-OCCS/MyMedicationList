//
//  ModalMedicationInfoViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "ModalMedicationInfoViewController.h"
#import "RxNormWebDataObject.h"
#import "LoadingView.h"
#import "ModalMedicationSearchProtocol.h"
#import "UIContextAlertView.h"
#import "MedicationContainer.h"
#import "MMLMedication.h"
#import "Medication+CCDFunctionality.h"
#import "unistd.h"
#import "DisplayNameService.h"
#import "MedDetailInfoViewController.h"
#import "CoreDataManager.h"
#import "MMLConceptProperty.h"
#import "MMLCCDInfo.h"
#import "MMLIngredients.h"

@interface ModalMedicationInfoViewController () <RxNormWebDataDelegate,UIAlertViewDelegate> {
    
	RxNormWebDataObject *_webdataObject;
	NSString *_displayName;
	
    NSMutableArray *_drugConceptProperties;
    DisplayNameService *_displayNameService;
	LoadingView *_loadingView;
}

@property (copy,nonatomic) NSString *rxCUI;
@property (retain,nonatomic) NSIndexPath *chosenPath;
@end

@implementation ModalMedicationInfoViewController
@synthesize personData = _personData;
@synthesize delegate = _delegate;
@synthesize dataDelegate = _dataDelegate;
@synthesize displayName = _displayName;
@synthesize rxCUI = _rxCUI;
@synthesize chosenPath = _chosenPath;
@synthesize freeTextController;
@synthesize approxMatchOn;
#pragma mark -
#pragma mark Initialization

- (void)finishedUpdating:(NSNotification *)notification
{
    NSLog(@"We have finished updating the display names database...");
    if([LoadingView isOnScreen])
        [_loadingView removeView];
}

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
		        
        _drugConceptProperties = [[NSMutableArray alloc] init];
        
		_webdataObject = [RxNormWebDataObject webDataObject];
		_webdataObject.delegate = self; 
		
        self.chosenPath = nil;
        
		// One or the other of these values should be set before the view controller is pushed.
		self.displayName = nil;
		self.rxCUI = nil;
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

    NSLog(@"in ModalMedicationInfoViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MMLFinishedUpdatingDisplayNamesNotification object:nil];

	[_drugConceptProperties release];
	_drugConceptProperties = nil;
    self.personData = nil;
    self.chosenPath = nil;
    self.displayName = nil;
    self.rxCUI = nil;
    self.freeTextController = nil;
    [super dealloc];
}

- (void)filterDrugConcepts:(NSMutableArray *)drugConcepts
{
    ConceptProperty *concept = nil;
    NSUInteger size = [drugConcepts count];
    //NSLog(@"Here is the initial size: %d", size);
    NSString *medicationDisplayName = nil;
    for(NSUInteger index = 0; index < size; index++)
    {
        concept = [drugConcepts objectAtIndex:index];
        NSString *tty = concept.termtype;
        if ([tty isEqualToString:@"SCD"]) {
        medicationDisplayName = (concept.synonym != nil) ? concept.synonym : concept.name; 
        NSRange rangeOfSlash = [medicationDisplayName rangeOfString:@" / "];
        
        // A slash was found
        if(rangeOfSlash.length != 0)
        {
            // Don't filter when the slash is preceded by a '%' sign
            if([medicationDisplayName characterAtIndex:(rangeOfSlash.location-1)] != '%')
            {
                [drugConcepts removeObjectAtIndex:index];
                index--;
                size--;
            }
        }
        }
    }
}

- (void)contextAlertView:(UIContextAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        // Report the new medication to the medication list view controller
      //  [_delegate modalSearchViewController:self didSelectMedication:alertView.context];
        
        MedDetailInfoViewController *medicationDataViewController = [[MedDetailInfoViewController alloc] initWithNibName:@"MedDetailInfoViewController" bundle:nil];
        medicationDataViewController.delegate = _dataDelegate;
       // medicationDataViewController.isNew = YES;
        medicationDataViewController.person = self.personData;
        medicationDataViewController.medication = alertView.context;
        
        [self.navigationController pushViewController:medicationDataViewController animated:YES];
        [medicationDataViewController release];

    }
}

- (void)rxNormWebDataObject:(RxNormWebDataObject *)webDataObject didReturnResult:(id)result
{
    NSLog(@"rxNormWebdataObject:didReturnResult: ModalMedicationInfoViewController");
    if([result isKindOfClass:[NSMutableArray class]])
    {
        for(ConceptProperty *concept in ((NSMutableArray *)result)) {
          //  [_drugConceptProperties addObject:concept];
           if ([[concept termtype] isEqualToString:@"SCD"]) {
         //       NSRange rangeOfSlash = [[concept name] rangeOfString:@" / "];
              //  if(rangeOfSlash.length == 0)
          //      {
                    [_drugConceptProperties addObject:concept];
              //  }
            } else {
                [_drugConceptProperties addObject:concept];
            }
            NSLog(@"Retain COunt is %d", [concept retainCount]);
        }
        if (_drugConceptProperties == nil || [_drugConceptProperties count] == 0) {
            if (!approxMatchOn) {
                approxMatchOn = YES;
                [webDataObject getConceptPropertiesUsingApproxMatchWithDisplayName:self.displayName];
                return;
            }
        }
        approxMatchOn = NO;

        if([LoadingView isOnScreen])
            [_loadingView removeView];
        if ([_drugConceptProperties count] == 0) {
            FreeEntryTextViewController *tFreeTextController = [[[FreeEntryTextViewController alloc] initWithNibName:@"FreeEntryTextViewController" bundle:nil] autorelease];
     //       tFreeTextController.delegate = _delegate;
            tFreeTextController.medName = _displayName;
            tFreeTextController.person = self.personData;
            tFreeTextController.dataDelegate = self.dataDelegate;
            NSLog(@"freeTextEntered: %@",_displayName);
            self.freeTextController = tFreeTextController;
            [self.tableView addSubview:freeTextController.view];
            

        } else {
          //  [self filterDrugConcepts:_drugConceptProperties];
            ConceptProperty *tmpC = [[[ConceptProperty alloc] init] autorelease];
            tmpC.synonym =@"Enter Free Text...";
            [_drugConceptProperties addObject:tmpC];
            [self.tableView reloadData];
        }
    }
	
    if([result isKindOfClass:[CCDInfo class]])
    {
        
        if([LoadingView isOnScreen])
            [_loadingView removeView];
        
        //Medication *med = [[[Medication alloc] init] autorelease];
        MMLMedication *med = [[CoreDataManager coreDataManager] newMedication];
        
        
        // Initialize the needed data for the medication
        ConceptProperty *cProperty = [_drugConceptProperties objectAtIndex:_chosenPath.section];
        MMLConceptProperty *conceptProperty = [[CoreDataManager coreDataManager] newConceptProperty];
        if(([cProperty.synonym isEqualToString:@""])||(cProperty.synonym == nil)) {
        [med setValue:[cProperty name] forKey:@"name"];
        } else {
            if ([cProperty.synonym length] > [cProperty.name length]) {
                [med setValue:[cProperty name] forKey:@"name"];
            }
            else {
                [med setValue:[cProperty synonym] forKey:@"name"];
            }
        }
        NSLog(@"Med Name is %@ ",[med valueForKey:@"name"]);
        unsigned int creationID = [[NSDate date] timeIntervalSince1970];

        med.creationID = [NSNumber numberWithUnsignedInt:creationID];
        conceptProperty.rxcui = cProperty.rxcui;
        conceptProperty.name = cProperty.name;
        conceptProperty.synonym = cProperty.synonym;
        conceptProperty.termtype = cProperty.termtype;
        conceptProperty.language = cProperty.language;
        conceptProperty.suppressflag = cProperty.suppressflag;
        conceptProperty.umlsCUI = cProperty.UMLSCUI;
        conceptProperty.medication = med;
        med.conceptProperty = conceptProperty;
        
        CCDInfo *cInfo = (CCDInfo *)result;
        MMLCCDInfo *ccdInfo = [[CoreDataManager coreDataManager] newCCDInfo];
        ccdInfo.isClinicalDrug = [NSNumber numberWithBool:cInfo.isClinicalDrug];
        ccdInfo.codeDisplayName = cInfo.codeDisplayName;
        ccdInfo.codeDisplayNameRxCUI = cInfo.codeDisplayNameRxCUI;
        ccdInfo.translationDisplayName = cInfo.translationDisplayName;
        ccdInfo.translationDisplayNameRxCUI = cInfo.translationDisplayNameRxCUI;
        ccdInfo.ingredientName = cInfo.ingredientName;
        ccdInfo.brandName = cInfo.brandName;
        ccdInfo.medication = med;
        if (cInfo.codeDisplayName == nil || [cInfo.codeDisplayName isEqualToString:@""]) {
            ccdInfo.codeDisplayNameRxCUI= cProperty.rxcui;
            ccdInfo.codeDisplayName = med.name;
        }
        med.ccdInfo = ccdInfo;
        

      //  UIImage *medicationImage = [webDataObject getMedicationImage:med.conceptProperty.rxcui];
        
     //   med.image = medicationImage;
        
        //NSString *medicationIngredient = [webDataObject getIngredient:med.conceptProperty.rxcui];
        
        //NSLog(@"Here is the returned ingredient - ModalMedicationInfoViewController: %@",medicationIngredient);
        
        //med.ingredient = medicationIngredient;
        
     /////////////   med.ingredients = [Medication parseIngredientString:med.ccdInfo.ingredientName];
        
        [[CoreDataManager coreDataManager] setMMLIngedients:med.ccdInfo.ingredientName forMedication:med];
               
        NSString *duplicateIngredient = nil;
       ///////// if((duplicateIngredient = [_personData duplicateIngredient:med.ingredients]) != nil)
        duplicateIngredient = [[CoreDataManager coreDataManager] duplicateIngredient:med.ingredientsArray ForPerson:_personData];
        if (duplicateIngredient !=nil)
        {
            NSLog(@"The user has a duplicate");
            UIContextAlertView *duplicateAlert = [[UIContextAlertView alloc] initWithTitle:@"Duplicate Drug" 
                                                                                   message:[NSString stringWithFormat:@"A drug with the ingredient %@ is already in your medication list. Would you like to add it anyway?",duplicateIngredient]
                                                                                   context:med
                                                                                  delegate:self 
                                                                         cancelButtonTitle:nil
                                                                         otherButtonTitles:@"Yes",@"No", nil];
            [duplicateAlert show];
            [duplicateAlert release];
        }
        else
        {
            NSLog(@"The user does not have a duplicate"); 
          //  [_delegate modalSearchViewController:self didSelectMedication:med];
            
            MedDetailInfoViewController *medicationDataViewController = [[MedDetailInfoViewController alloc] initWithNibName:@"MedDetailInfoViewController" bundle:nil];
            medicationDataViewController.delegate = _dataDelegate;
           // medicationDataViewController.isNew = YES;
            medicationDataViewController.medication = med;
            medicationDataViewController.person = _personData;
            
            [self.navigationController pushViewController:medicationDataViewController animated:YES];
            [medicationDataViewController release];
            
            //[self.navigationController dismissModalViewControllerAnimated:YES];
        }
    }
    else
        NSLog(@"The kind of class returned is %@", [[result class] description]);
}

- (void)rxNormWebDataObjectDidWarn:(RxNormWebDataObject *)webDataObject warningMessage:(id)result {
    if([LoadingView isOnScreen])
        [_loadingView removeView];
    
    
	UIAlertView *medicationDataIssue = [[UIAlertView alloc] initWithTitle:@"Ingredient Search"
																  message:(NSString *)result
																 delegate:nil
														cancelButtonTitle:@"OK"
														otherButtonTitles:nil];
	[medicationDataIssue show];
	[medicationDataIssue release];
    [self.navigationController popViewControllerAnimated:YES];

}
- (void)rxNormWebDataObjectDidFail:(RxNormWebDataObject *)webDataObject
{
    if([LoadingView isOnScreen])
        [_loadingView removeView];
     
	UIAlertView *medicationDataIssue = [[UIAlertView alloc] initWithTitle:@"Medication Data Issue"
																  message:@"Information about this medication could not be found"
																 delegate:nil
														cancelButtonTitle:@"OK"
														otherButtonTitles:nil];
	[medicationDataIssue show];
	[medicationDataIssue release];
    [self.navigationController popViewControllerAnimated:YES];

}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                        //        target:self action:@selector(dismissInfo)];
    
 //   self.navigationItem.rightBarButtonItem = doneButton;
  //  [doneButton release];
    
   // self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
  //  UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableViewBG.png"]];
   // [tempImageView setFrame:self.tableView.frame];
    
   // self.tableView.backgroundView = tempImageView;
    //[tempImageView release];
    self.title = @"Search Results";

   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[CoreDataManager coreDataManager] rollBack];
 
	if(_displayName != nil && [_drugConceptProperties count] == 0) {
         _loadingView = [LoadingView loadingViewInView:self.navigationController.view withMessage:@"Loading..."];
		[_webdataObject getConceptPropertiesWithDisplayName:_displayName];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if([LoadingView isOnScreen])
    {
        [_webdataObject cancel];
        [_loadingView removeView];
    }
    if (self.freeTextController != nil) {
        self.freeTextController = nil;
    }
}


- (void)dismissInfo
{
    // If there are any download operations happening in the background then stop
    // them and remove them from the queue
	[_webdataObject cancel];
    
	// TODO: This is an ugly solution to dismissing the modal view controller, fix this
	//[_delegate modalSearchViewControllerDidCancel:self];
    [self.navigationController popViewControllerAnimated:YES];
}
		


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_drugConceptProperties count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0f;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([_drugConceptProperties count] != 0)
    {
        if([[[_drugConceptProperties objectAtIndex:indexPath.section] synonym] isEqualToString:@""]){
            NSString *str =  [[_drugConceptProperties objectAtIndex:indexPath.section] name];
            CGSize size = [str  sizeWithFont:[UIFont systemFontOfSize:17.0f] 
                           constrainedToSize:CGSizeMake(tableView.frame.size.width-60, CGFLOAT_MAX)
                               lineBreakMode:UILineBreakModeWordWrap];
            if (size.height < 30) {
                return 40.0f;
            } else
                return size.height+10;
        } else {
            NSString *str =  [[_drugConceptProperties objectAtIndex:indexPath.section] synonym];
            NSString *nameStr = [[_drugConceptProperties objectAtIndex:indexPath.section] name];
            CGSize size;
            if ([str length] > [nameStr length] && nameStr != nil && [nameStr length] == 0) {
             size = [nameStr  sizeWithFont:[UIFont systemFontOfSize:17.0f] 
                           constrainedToSize:CGSizeMake(tableView.frame.size.width-60, CGFLOAT_MAX)
                               lineBreakMode:UILineBreakModeWordWrap];
            } else {
                size = [str  sizeWithFont:[UIFont systemFontOfSize:17.0f] 
                        constrainedToSize:CGSizeMake(tableView.frame.size.width - 60, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
            }
            if (size.height < 30) {
                return 40.0f;
            } else
            return size.height+10;
        }
	} else 
        return 0;
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:17];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.text = [NSString stringWithFormat:@"  Drug #%d",section+1];
//    return [titleLabel autorelease];
//}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//	
//    if([_drugConceptProperties count] != 0)
//    {
//        if([[[_drugConceptProperties objectAtIndex:indexPath.section] synonym] isEqualToString:@""])
//            cell.textLabel.text = [[_drugConceptProperties objectAtIndex:indexPath.section] name];
//        else
//            cell.textLabel.text = [[_drugConceptProperties objectAtIndex:indexPath.section] synonym];
//	}
//    cell.textLabel.numberOfLines = 0;
//    cell.textLabel.backgroundColor = [UIColor clearColor];
//	 
//	
//    return cell;
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1"];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:@"Cell1"] autorelease];
                
    }
    CGSize constraint = CGSizeMake(tableView.frame.size.width - (30 * 2), CGFLOAT_MAX);
    CGSize size;
    NSString *text;
    if([_drugConceptProperties count] != 0)
    {
        if([[[_drugConceptProperties objectAtIndex:indexPath.section] synonym] isEqualToString:@""]) {
            text = [[_drugConceptProperties objectAtIndex:indexPath.section] name];
          size   = [[[_drugConceptProperties objectAtIndex:indexPath.section] name] sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        } else {
            text = [[_drugConceptProperties objectAtIndex:indexPath.section] synonym];
            NSString *nameStr = [[_drugConceptProperties objectAtIndex:indexPath.section] name];
            if ([text length] > [nameStr length] && nameStr != nil && [nameStr length] == 0) {
                size = [nameStr  sizeWithFont:[UIFont systemFontOfSize:17.0f] 
                            constrainedToSize:constraint
                                lineBreakMode:UILineBreakModeWordWrap];
                text = [[_drugConceptProperties objectAtIndex:indexPath.section] name];
            } else {
                size = [text  sizeWithFont:[UIFont systemFontOfSize:17.0f] 
                        constrainedToSize:constraint
                            lineBreakMode:UILineBreakModeWordWrap];
            }
        }
        cell.contentView.frame = CGRectMake(0, 0, tableView.frame.size.width - (30 * 2), MAX(size.height+10, 44.0f));
        cell.textLabel.text = text;
    }

    

    [cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
    [cell.textLabel setMinimumFontSize:17.0f];
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [cell.textLabel setTag:1];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
 //   if (!label)
 //       label = (UILabel*)[cell viewWithTag:1];
    
 //   [label setText:text];
  //  [label setFrame:CGRectMake(0, 0, tableView.frame.size.width - (30 * 2), MAX(size.height, 44.0f))];
    
    return cell;

}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    _loadingView = [LoadingView loadingViewInView:self.navigationController.view withMessage:@"Saving..."];
    
    self.chosenPath = indexPath;
    
    ConceptProperty *conceptProperty = [_drugConceptProperties objectAtIndex:_chosenPath.section];
    if ([conceptProperty.synonym isEqualToString:@"Enter Free Text..."]) {
        FreeEntryTextViewController *tFreeTextController = [[[FreeEntryTextViewController alloc] initWithNibName:@"FreeEntryTextViewController" bundle:nil] autorelease];
      //  tFreeTextController.delegate = _delegate;
        tFreeTextController.medName = _displayName;
        tFreeTextController.person = self.personData;
        tFreeTextController.dataDelegate = self.dataDelegate;
        NSLog(@"freeTextEntered: %@",_displayName);
        self.freeTextController = tFreeTextController;
        [self.tableView addSubview:freeTextController.view];
        [self.navigationController pushViewController:freeTextController animated:YES];    
    } else {
    [conceptProperty printConceptProperty];
    
    [_webdataObject getCCDInfo:conceptProperty];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

