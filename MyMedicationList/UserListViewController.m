//
//  UserListViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "UserListViewController.h"
#import "CCDParser.h"
#import "UIPickerAlertView.h"
#import "UIImage+Resize.h"
#import "AppInfoViewController.h"
#import "UserInfoViewController.h"
#import "MMLMedListViewController.h"
#import "MMLCustomImageButton.h"
#import <QuartzCore/QuartzCore.h>
#import "OverlayViewController.h"
#import "SettingsViewController.h"
#import "CoreDataManager.h"
#import "PictureViewerViewController.h"
#import "ProfileManager.h"
#import "RemindersViewController.h"

@interface UserListViewController ()<UIActionSheetDelegate,CCDParserDelegate,UIPickerAlertDelegate,OverlayViewControllerDelegate,PictureViewerDelegate> {
    
    BOOL isReturningHome;
    BOOL editingExistingProfile;
    BOOL editingExistingMedicationList;
    BOOL hasRowForProfileAdd;
    BOOL infoButtonPressed;
    // TODO: This value is set to 0 and is never changed, consider deleting
    NSUInteger numberOfPaddingCells;
    
	NSUInteger _numberOfAddingCells;
}

@property (copy,nonatomic) NSString *receivedString;
@property (retain, nonatomic) CCDParser *parser;
@property (retain, nonatomic) MMLPersonData *parsedPerson;
@property (retain,nonatomic) OverlayViewController *pictureViewController;

@end


@implementation UserListViewController

@synthesize receivedString = _receivedString;
@synthesize parser = _parser;
@synthesize parsedPerson = _parsedPerson;
@synthesize genderTableViewCell;
@synthesize bluetoothActionView;
@synthesize pictureViewController;
@synthesize importViewController;

@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    [self.tableView reloadData];


}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Users";
    self.navigationItem.hidesBackButton = NO;
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"14-gear"] style:UIBarButtonItemStyleBordered target:self action:@selector(openSettingsController:)];
    self.navigationItem.leftBarButtonItem = btnItem;
    [btnItem release];
   // UIBarButtonItem *homeButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doneAndReturn)];
  //  self.navigationItem.leftBarButtonItem = homeButton;
    UIButton *_appInfoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    _appInfoButton.frame = CGRectMake(277, 20, 50, 50);
    _appInfoButton.tag = 1;
    [_appInfoButton addTarget:self action:@selector(showAppInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc]initWithCustomView:_appInfoButton];
    self.navigationItem.rightBarButtonItem = infoItem;
    
    [infoItem release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
        return 100;
    }
    else
        return 80.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else
        return [[CoreDataManager coreDataManager] profileCount];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Add User Profile";
    } else {
        return @"Users";
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserProfileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
         cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		
    }
    NSArray *subViewsArray = [cell.imageView subviews];
    for (int i=0; i < [subViewsArray count];i++) {
        if ([subViewsArray[i] isKindOfClass:[MMLCustomImageButton class]]) {
            MMLCustomImageButton *btn1 = (MMLCustomImageButton *)subViewsArray[i];
            [btn1 removeFromSuperview];
            break;
        }
    }

    MMLCustomImageButton *btn = [[[MMLCustomImageButton alloc] initWithFrame:CGRectZero] autorelease];

    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == 0) {
        cell.imageView.image = [UIImage imageNamed:@"UnknownPerson.png"];
        cell.imageView.userInteractionEnabled = NO;
        cell.textLabel.text = @"Add User Profile";
    } else {
        //cell.imageView.image = [UIImage imageNamed:@"addPhoto.png"];
       // cell.imageView.image = nil;
        cell.imageView.image = nil;
        cell.imageView.frame = CGRectMake(0,0,80,80);
        UIGraphicsBeginImageContext(cell.imageView.bounds.size);
        [cell.imageView.image drawInRect:cell.imageView.bounds];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.imageView.userInteractionEnabled = YES;
      
        btn.frame = CGRectMake(5,5,70,70);
        [btn addDashedBorderLayer:@"Custom Dashed Layer" withDashDistance:4];
             UIImage *personImage = [[CoreDataManager coreDataManager] getPersonImageByIndex:indexPath.row];
        if (personImage != nil) {
            UIImage *image2 = [[personImage resizedImage:CGSizeMake(70,70) interpolationQuality:kCGInterpolationHigh ] thumbnailImage:70 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
            [btn addImageLayer:@"Custom User Image Layer" withImage:image2];
            [btn addBottomTextLayer:@"Custom Edit Text Layer" withText:@"Edit"];
        } else {
            [btn addTextLayer:@"Custom Text Layer" withText:@"add user photo"];
        }

        btn.tag = indexPath.row + 5000;
        cell.textLabel.text = [[CoreDataManager coreDataManager] getPersonNameByIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [btn addTarget:self action:@selector(displayEditPhotoActionSheet:) forControlEvents:UIControlEventTouchUpInside];
        [cell.imageView addSubview:btn];

    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"The accessory view at row %d was tapped",indexPath.row);

    
	
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0 ) {
        UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
       // UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:userInfoViewController animated:YES];
        [userInfoViewController release];

//        UIActionSheet *addChoiceAction = [[UIActionSheet alloc] initWithTitle:@"Add User Profile"
//                                                                     delegate:self
//                                                            cancelButtonTitle:@"Cancel"
//                                                       destructiveButtonTitle:nil
//                                                            otherButtonTitles:@"Add profile",@"Import profile (Bluetooth)", nil];
//        [addChoiceAction showInView:self.navigationController.view];
//        [addChoiceAction release];
    } else {
        UIActionSheet *addChoiceAction = [[UIActionSheet alloc] initWithTitle:@"PROFILE ACTIONS"
                                                               delegate:self
                                                               cancelButtonTitle:@"Cancel"
                                                               destructiveButtonTitle:nil
                                                               otherButtonTitles:@"Edit Profile",@"Manage Medications", nil];
        addChoiceAction.tag = 4000+indexPath.row;
        [addChoiceAction showInView:self.navigationController.view];
        [addChoiceAction release];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];


}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
	NSLog(@"Step 1");
	if (indexPath.section == 0 && indexPath.row == 0) {
        return NO;
    }
    return YES;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Step 3");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [[CoreDataManager coreDataManager] deletePersonAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [[CoreDataManager coreDataManager]saveContext];
    }
    
}

- (void)pictureViewerDidDismiss:(PictureViewerViewController *)pictureViewerViewController
{
    [self dismissModalViewControllerAnimated:YES];
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
            self.pictureViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureViewController.delegate = self;
            pictureViewController.imageSize = CGSizeMake(300,300);
            
			[pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            [self presentModalViewController:pictureViewController.imagePickerController animated:YES];
            pictureViewController.imagePickerController.view.tag = actionSheet.tag-1000;
		}
		else if(buttonIndex == 2)
		{
			self.pictureViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureViewController.delegate = self;
            pictureViewController.imageSize = CGSizeMake(300,300);
            
			//Take a photograph with the camera.
			if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                [pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeCamera];
			else
				[pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];;
			
            pictureViewController.imagePickerController.view.tag = actionSheet.tag-1000;
			[self presentModalViewController:pictureViewController.imagePickerController animated:YES];
		}
		else if(buttonIndex == 3)
		{
            
            MMLPersonData *person = [[CoreDataManager coreDataManager] profileAtIndex:actionSheet.tag-6000];
            MMLMedicationList *list = person.currentMedicationList;
            if (list != nil && [list.medicationList count] != 0) {
                NSSet *list1 = list.medicationList;
                for (MMLMedication *med in list1) {
                    if ([RemindersViewController hasReminders:[med.creationID intValue]]) {
                        [RemindersViewController cancelAllReminders:[med.creationID intValue]];
                    }
                }
            }
            person.personImage = nil;
            [[CoreDataManager coreDataManager] saveContext];
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:actionSheet.tag - 6000 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
		}
		else if(buttonIndex == 3)
		{
            
		}
        else {
            
        }
	}
    else 	if(actionSheet.tag >= 5000)
	{
		if(buttonIndex == 0)
		{
            self.pictureViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureViewController.delegate = self;
            pictureViewController.imageSize = CGSizeMake(300,300);

			[pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            [self presentModalViewController:pictureViewController.imagePickerController animated:YES];
            pictureViewController.imagePickerController.view.tag = actionSheet.tag;
		}
		else if(buttonIndex == 1)
		{
			self.pictureViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureViewController.delegate = self;
            pictureViewController.imageSize = CGSizeMake(300,300);

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
            
            MMLPersonData *person = [[CoreDataManager coreDataManager] profileAtIndex:actionSheet.tag-5000];
            person.personImage = nil;
            [[CoreDataManager coreDataManager] saveContext];
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:actionSheet.tag - 5000 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
		}
		else if(buttonIndex == 3)
		{
        }
        else {
            
        }
	}
    else if(actionSheet.tag >= 4000) {
            if(buttonIndex == 0)
            {
               
                MMLPersonData *person = [[CoreDataManager coreDataManager] profileAtIndex:actionSheet.tag-4000];
                UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
                userInfoViewController.personData = person;
                [self.navigationController pushViewController:userInfoViewController animated:YES];
                [userInfoViewController release];

            }
            else if (buttonIndex == 1) {
                
                MMLMedListViewController *medListViewController = [[MMLMedListViewController alloc] initWithNibName:@"MMLMedListViewController" bundle:nil];
                medListViewController.personData = [[CoreDataManager coreDataManager] profileAtIndex:actionSheet.tag - 4000];
                medListViewController.personArchiveName = [NSString stringWithFormat:@"%d",actionSheet.tag -4000 ];
                [self.navigationController pushViewController:medListViewController animated:YES];
                [medListViewController release];

            } else {
                // do nothing this is cancel.
            }
    }
	else {
        }
    
}

-(void) appViewController:(id) sender {
    
    
}
- (void)addProfile
{
    
    UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
	[self.navigationController pushViewController:userInfoViewController animated:YES];
    [userInfoViewController release];
}

- (void)doneAndReturn
{
	isReturningHome = YES;
	[_delegate viewControllerWillReturnHome:self.navigationController];
}

- (void)displayEditPhotoActionSheet:(id)sender
{
    NSLog(@"displayEditPhotoActionSheet");
    UIButton *btn = (UIButton *) sender;
    
     MMLPersonData *person = [[CoreDataManager coreDataManager] profileAtIndex:btn.tag-5000];
    UIActionSheet *editPhotoQuery = nil;
    if (person.personImage != nil) {
        editPhotoQuery = [[UIActionSheet alloc] initWithTitle:@"Options to add or change the profile image"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"View Photo",@"Choose Photo",@"Take Photo",@"Delete Photo",nil];
        editPhotoQuery.tag = btn.tag+1000;
    } else {
       editPhotoQuery  = [[UIActionSheet alloc] initWithTitle:@"Options to add or change the profile image"
                                                                    delegate:self
                                                           cancelButtonTitle:@"Cancel"
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:@"Choose Photo",@"Take Photo",@"Delete Photo",nil];
        editPhotoQuery.tag = btn.tag;
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
     MMLPersonData *person = [[CoreDataManager coreDataManager] profileAtIndex:tag-5000];
    person.personImage =  UIImagePNGRepresentation(picture) ;
    [[CoreDataManager coreDataManager] saveContext];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:tag - 5000 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - CCD Parser delegate callbacks

- (void)ccdParserDidFail:(CCDParser *)ccdParser
{
    UIAlertView *parseFailAlert = [[UIAlertView alloc] initWithTitle:@"Data failure"
                                                             message:@"User data could not be extracted."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
    [parseFailAlert show];
    [parseFailAlert release];
}

- (void)ccdParser:(CCDParser *)ccdParser didParsePerson:(MMLPersonData *)personData
{   
    self.parsedPerson = personData;
    if(personData.dateOfBirth != nil)
    {
        [[CoreDataManager coreDataManager] saveContext];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Successfully created the user profile" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
         [self.tableView reloadData];
    }
    else
    {
        UIPickerAlertView *dateOfBirthPicker = [[UIPickerAlertView alloc] initWithDelegate:self];
        [dateOfBirthPicker show];
        [dateOfBirthPicker release];
    }
}

- (void) showAppInfo:(id)sender {
    AppInfoViewController *appInfoViewController = [[AppInfoViewController alloc] init];
   // appInfoViewController.delegate = self;
    
    [self.navigationController pushViewController:appInfoViewController animated:YES];
    [appInfoViewController release];
}

- (void) openSettingsController:(id)sender {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
   // settingsViewController.delegate = self;
    
    [self.navigationController pushViewController:settingsViewController animated:YES];
    [settingsViewController release];
}
- (void)presentModalImportViewController
{
    // [self animateModalImportViewUp:UP];
    if (self.navigationController != nil) {
        UIViewController *vc = [self.navigationController visibleViewController];
        [vc presentModalViewController:importViewController animated:YES];
    } else {
        
        [self presentModalViewController:importViewController animated:YES];
    }
}

- (void)dismissModalImportViewController
{
    //[self animateModalImportViewUp:DOWN];
    if (self.navigationController != nil) {
        UIViewController *vc = [self.navigationController visibleViewController];
        [vc dismissModalViewControllerAnimated:YES]; //:_importViewController animated:YES];
    } else {
        
        [self dismissModalViewControllerAnimated:YES];
    }
}


- (void) migrateToCoreData {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    [[ProfileManager profileManager] removeProfileObjects];    
    [[ProfileManager profileManager] loadProfiles];
    int profileCount = [[ProfileManager profileManager] profileArchiveNameCount];
    if (profileCount > 0) {
        for (int i=0; i < profileCount; i++) {
            PersonData *person = [[ProfileManager profileManager] getPersonDataByProfileName:[[ProfileManager profileManager] getProfileArchiveNameAtIndex:i]];
            [aDelegate migrateToCoreData:person];
        }
        [[ProfileManager profileManager] removeProfileObjects];
        [[ProfileManager profileManager] loadProfiles];
        profileCount = [[ProfileManager profileManager] profileArchiveNameCount];
        for (int i=0; i < profileCount; i++) {
            [[ProfileManager profileManager] deletePersonAtIndex:i];
        }
        [[ProfileManager profileManager] removeProfileObjects];
        [[ProfileManager profileManager] saveProfileNames];
        [self.tableView reloadData];        
    }
}
- (void)importViewControllerDidDismiss:(ImportViewController *)importViewController didImport:(BOOL)didImport error:(NSError *)error
{
    NSLog(@"importViewControllerDidDismiss:didImport:error");
    [self dismissModalImportViewController];
    self.importViewController = nil;
}

@end
