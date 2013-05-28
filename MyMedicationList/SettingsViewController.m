//
//  SettingsViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <QuartzCore/QuartzCore.h>
#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface SettingsViewController()  <UITextFieldDelegate>
{
    UISegmentedControl *shouldPassLockControl;
	UITextField *passwordEntry;
	UITextField *passwordReEntry;
	
    UISlider *fontSlider;
    UILabel *fontSizeLabel;
    
    UISegmentedControl *shouldShowMedImages;
    UISegmentedControl *shouldShowPictograms;
    UISegmentedControl *shouldEmailInsuranceCard;    
    
    UIButton *clearNotifications;
    
	NSInteger _passwordRowCount;
    
	// Saves the state of the password lock independent
	// of whether the passwords are matched.
	// Avoids the issue of making the state of the segment control
	// equal to the whether the passwords are SET (as opposed to whether
	// the user is merely deciding to enter a password)
	NSInteger currentPasswordSegment;
    NSInteger currentShowImageSegment;
	NSInteger currentShowPictogramSegment;
    NSInteger currentEmailInsuranceCardSegment;
}

@end

@implementation SettingsViewController
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
		
        self.title = @"Settings";
        
		_passwordRowCount = 1;
		currentPasswordSegment = 0;
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"isPasswordLocked"])
		{
			_passwordRowCount = 3;
			currentPasswordSegment = 1;
		}
		
        currentShowImageSegment = 0;
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldShowImages"])
        {
            currentShowImageSegment = 1;
        }
        
        currentShowPictogramSegment = 0;
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldShowPictograms"])
        {
            currentShowPictogramSegment = 1;
        }
        
        currentEmailInsuranceCardSegment = 0;
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldEmailInsuranceCard"])
        {
            currentEmailInsuranceCardSegment = 1;
        }

        
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)doneAndReturn
{
	if([passwordEntry isFirstResponder])
		[passwordEntry resignFirstResponder];
	else if([passwordReEntry isFirstResponder])
		[passwordReEntry resignFirstResponder];
	
	[_delegate viewControllerWillReturnHome:self.navigationController];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

   // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    
    self.tableView.scrollEnabled = NO;
   // self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    //UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableViewBG.png"]];
  //  [tempImageView setFrame:self.tableView.frame];
    
  //  self.tableView.backgroundView = tempImageView;
  //  [tempImageView release];
        
    
   // UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"HomeIcon.png"]
                 //                                                      style:UIBarButtonItemStyleBordered
                  //                                                    target:self
                  //                                                    action:@selector(doneAndReturn)];
  //  self.navigationItem.rightBarButtonItem = rightBarButton;
  //  [rightBarButton release];

}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of different settings sections
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if(section == 0)
		return _passwordRowCount;
	else
		return 1;
}

- (void)updatePasswordLock
{
	
	currentPasswordSegment = shouldPassLockControl.selectedSegmentIndex;
	
	// Stops the error that when user touches NO on the password lock segment
	// in the middle of entering a password
	if([self.tableView isFirstResponder])
		[self.tableView resignFirstResponder];
	
	if(currentPasswordSegment == 0)
	{
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isPasswordLocked"];
		[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passwordForLock"];

		_passwordRowCount = 1;

		// Erases the text so that dequeuing a reuseable cell does
		// not contain a ghost of the former text
		passwordEntry.text = nil;
		passwordReEntry.text = nil;
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],nil] 
							  withRowAnimation:UITableViewRowAnimationFade];

	}
	else
	{
			
		_passwordRowCount = 3;

		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],nil] 
							  withRowAnimation:UITableViewRowAnimationFade];

	}
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] 
						  withRowAnimation:UITableViewRowAnimationNone];
	
}


#define PASSWORDSELECTOR_TAG            1
#define FIRSTPASSFIELD                  2
#define SECONDPASSFIELD                 3
#define FONTSLIDER_TAG                  4
#define FONTSIZELABEL_TAG               5
#define SHOWMEDIMAGESELECTOR_TAG        7
#define SHOWPICTOGRAMSELECTOR_TAG       8
#define SHOWINSURANCECARDSELECTOR_TAG   9
#define MINFONTSIZE     15.0
#define MAXFONTSIZE     22.0
- (void)updateFontLabel
{
    NSLog(@"The font size label is being updated...");
    fontSizeLabel.text = [NSString stringWithFormat:@"%2d",(unsigned int)fontSlider.value];
}

- (void)updateFontSize
{
    NSLog(@"The font size is being updated...");
    [[NSUserDefaults standardUserDefaults] setFloat:(unsigned int)fontSlider.value forKey:@"MMLFontSize"];
}

- (void)updateShowImagesPreference
{
    NSLog(@"Whether we should show images when saving is being updated...");

    currentShowImageSegment = shouldShowMedImages.selectedSegmentIndex;
    
    if(shouldShowMedImages.selectedSegmentIndex == 0)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ShouldShowImages"];
    else
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShouldShowImages"];
}

- (void)updateShowPictogramPreference
{
    NSLog(@"Whether we should show pictograms when saving is being updated...");
    
    currentShowPictogramSegment = shouldShowPictograms.selectedSegmentIndex;
    
    if(shouldShowPictograms.selectedSegmentIndex == 0)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ShouldShowPictograms"];
    else
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShouldShowPictograms"];
}

- (void)updateEmailInsuranceCardPreference
{
    NSLog(@"Whether we should email the insurance card with other data...");
    
    currentEmailInsuranceCardSegment = shouldEmailInsuranceCard.selectedSegmentIndex;
    
    if(shouldEmailInsuranceCard.selectedSegmentIndex == 0)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ShouldEmailInsuranceCard"];
    else
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShouldEmailInsuranceCard"];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    	
    static NSString *PasswordSelectorCellIdentifier = @"PasswordSelectorCell";
	static NSString *PasswordEntryCellIdentifier = @"PasswordEntryCell";
    static NSString *PasswordReEntryCellIdentifier = @"PasswordReEntryCell";
    static NSString *FontSliderCellIdentifier = @"FontSliderCell";
    static NSString *ShowMedImageCellIdentifier = @"ShowMedImageCell";
    static NSString *ShowPictogramCellIdentifier = @"ShowPictogramCell";
    static NSString *ShowEmailInsuranceCardCellIdentifier = @"ShowEmailInsuranceCardCell";
    static NSString *notificationsCellIdentifier = @"NotificationsCellIdentifierCell";
    
    UITableViewCell *cell = nil;
	
	if(indexPath.section == 0)
	{
		if(indexPath.row == 0)
		{
			
			cell = [tableView dequeueReusableCellWithIdentifier:PasswordSelectorCellIdentifier];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PasswordSelectorCellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				shouldPassLockControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"OFF",@"ON",nil]] autorelease];
				shouldPassLockControl.tag = PASSWORDSELECTOR_TAG;
				shouldPassLockControl.frame = CGRectMake(165, 5, 130, 44-5-5);
				shouldPassLockControl.selectedSegmentIndex = currentPasswordSegment;
				shouldPassLockControl.segmentedControlStyle = UISegmentedControlStylePlain;
				shouldPassLockControl.backgroundColor = [UIColor clearColor];
				[shouldPassLockControl addTarget:self action:@selector(updatePasswordLock) forControlEvents:UIControlEventValueChanged];
				[cell.contentView addSubview:shouldPassLockControl];
			}
			else 
			{
				shouldPassLockControl = (UISegmentedControl *)[cell.contentView viewWithTag:PASSWORDSELECTOR_TAG];
				shouldPassLockControl.selectedSegmentIndex = currentPasswordSegment;
			}
			 
			
			cell.textLabel.text = @"Password Lock";
			cell.textLabel.backgroundColor = [UIColor clearColor];
			
			
		}
		else if(indexPath.row == 1)
		{
			
			cell = [tableView dequeueReusableCellWithIdentifier:PasswordEntryCellIdentifier];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PasswordEntryCellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;

				passwordEntry = [[[UITextField alloc] initWithFrame:CGRectMake(185, 5, 85, 35)] autorelease];
				passwordEntry.tag = FIRSTPASSFIELD;
				passwordEntry.delegate = self;
				passwordEntry.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"passwordForLock"];
				passwordEntry.font = [UIFont systemFontOfSize:26.0];
				passwordEntry.borderStyle = UITextBorderStyleRoundedRect;
				passwordEntry.keyboardType = UIKeyboardTypeNumberPad;
                passwordEntry.secureTextEntry = YES;
				[passwordEntry addTarget:self action:@selector(entryTextChanged) forControlEvents:UIControlEventEditingChanged];
				
				[cell.contentView addSubview:passwordEntry];
			}
			else {
				passwordEntry = (UITextField *)[cell.contentView viewWithTag:FIRSTPASSFIELD];
				passwordEntry.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"passwordForLock"];
			}
            passwordEntry.secureTextEntry = YES;

			cell.textLabel.text = @"Enter Password";
			cell.backgroundColor = [UIColor clearColor];
						
	//		if([[NSUserDefaults standardUserDefaults] boolForKey:@"isPasswordLocked"])
	//			cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]] autorelease];
//			else
				cell.accessoryView = nil;
			
		}
		else if(indexPath.row == 2)
		{
			cell = [tableView dequeueReusableCellWithIdentifier:PasswordReEntryCellIdentifier];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PasswordReEntryCellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
				passwordReEntry = [[[UITextField alloc] initWithFrame:CGRectMake(185, 5, 85, 35)] autorelease];
				passwordReEntry.tag = SECONDPASSFIELD;
				passwordReEntry.delegate = self;
				passwordReEntry.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"passwordForLock"];
				passwordReEntry.font = [UIFont systemFontOfSize:26.0];
				passwordReEntry.borderStyle = UITextBorderStyleRoundedRect;
				passwordReEntry.keyboardType = UIKeyboardTypeNumberPad;
                passwordReEntry.secureTextEntry = YES;
				[passwordReEntry addTarget:self action:@selector(reEntryTextChanged) forControlEvents:UIControlEventEditingChanged];
				
				[cell.contentView addSubview:passwordReEntry];
			}
			else{
				passwordReEntry = (UITextField *)[cell.contentView viewWithTag:SECONDPASSFIELD];
				passwordReEntry.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"passwordForLock"];
			}
            passwordReEntry.secureTextEntry = YES;

			cell.textLabel.text = @"Re-enter Password";
			cell.backgroundColor = [UIColor clearColor];

			//if([[NSUserDefaults standardUserDefaults] boolForKey:@"isPasswordLocked"])
		//		cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]] autorelease];
		//	else
				cell.accessoryView = nil;
			
		}
	}
	else if(indexPath.section == 3)
	{
        cell = [tableView dequeueReusableCellWithIdentifier:FontSliderCellIdentifier];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FontSliderCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            fontSlider = [[[UISlider alloc] initWithFrame:CGRectMake(165, 5, 130, 34)] autorelease];
            fontSlider.tag = FONTSLIDER_TAG;
            fontSlider.minimumValue = MINFONTSIZE;
            fontSlider.maximumValue = MAXFONTSIZE;
            fontSlider.backgroundColor = [UIColor clearColor];
            [fontSlider addTarget:self action:@selector(updateFontSize) forControlEvents:UIControlEventTouchUpInside];
            [fontSlider addTarget:self action:@selector(updateFontLabel) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:fontSlider];
            
            fontSizeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(110, 5, 40, 34)] autorelease];
            fontSizeLabel.tag = FONTSIZELABEL_TAG;
            fontSizeLabel.font = [UIFont boldSystemFontOfSize:17.0];
            fontSizeLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:fontSizeLabel];
            
        }
        else
        {
            fontSlider = (UISlider *)[cell.contentView viewWithTag:FONTSLIDER_TAG];
            fontSizeLabel = (UILabel *)[cell.contentView viewWithTag:FONTSIZELABEL_TAG];
        }
        
        cell.textLabel.text = @"Font Size - ";
        cell.textLabel.backgroundColor = [UIColor clearColor];
                                  
        fontSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"MMLFontSize"];
        fontSizeLabel.text = [NSString stringWithFormat:@"%2d",(unsigned int)fontSlider.value];
                
	}
    else if(indexPath.section == 4)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ShowMedImageCellIdentifier];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ShowMedImageCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
            shouldShowMedImages = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"OFF",@"ON", nil]] autorelease];
            shouldShowMedImages.tag = SHOWMEDIMAGESELECTOR_TAG;
            shouldShowMedImages.frame = CGRectMake(165, 5, 130, 44-5-5);
            shouldShowMedImages.selectedSegmentIndex = currentShowImageSegment;
            shouldShowMedImages.segmentedControlStyle = UISegmentedControlStylePlain;
            shouldShowMedImages.backgroundColor = [UIColor clearColor];
            [shouldShowMedImages addTarget:self action:@selector(updateShowImagesPreference) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:shouldShowMedImages];
        }
        else
        {
            shouldShowMedImages = (UISegmentedControl *)[cell.contentView viewWithTag:SHOWMEDIMAGESELECTOR_TAG];
            shouldShowMedImages.selectedSegmentIndex = currentPasswordSegment;
        }
        
        cell.textLabel.text = @"Show Images";
        cell.backgroundColor = [UIColor clearColor];
    }
    
    else if(indexPath.section == 5)
    {
    
        cell = [tableView dequeueReusableCellWithIdentifier:ShowPictogramCellIdentifier];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ShowPictogramCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
            shouldShowPictograms = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"OFF",@"ON", nil]] autorelease];
            shouldShowPictograms.tag = SHOWPICTOGRAMSELECTOR_TAG;
            shouldShowPictograms.frame = CGRectMake(165, 5, 130, 44-5-5);
            shouldShowPictograms.selectedSegmentIndex = currentShowPictogramSegment;
            shouldShowPictograms.segmentedControlStyle = UISegmentedControlStylePlain;
            shouldShowPictograms.backgroundColor = [UIColor clearColor];
            [shouldShowPictograms addTarget:self action:@selector(updateShowPictogramPreference) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:shouldShowPictograms];
            
        }
        else
        {
            shouldShowPictograms = (UISegmentedControl *)[cell.contentView viewWithTag:SHOWMEDIMAGESELECTOR_TAG];
            shouldShowPictograms.selectedSegmentIndex = currentShowPictogramSegment;
        }
        
        cell.textLabel.text = @"Show Pictograms";
        cell.backgroundColor = [UIColor clearColor];
    }
    
    else if(indexPath.section == 6)
    {
        
        cell = [tableView dequeueReusableCellWithIdentifier:ShowEmailInsuranceCardCellIdentifier];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ShowEmailInsuranceCardCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
            shouldEmailInsuranceCard = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"OFF",@"ON", nil]] autorelease];
            shouldEmailInsuranceCard.tag = SHOWINSURANCECARDSELECTOR_TAG;
            shouldEmailInsuranceCard.frame = CGRectMake(165, 5, 130, 44-5-5);
            shouldEmailInsuranceCard.selectedSegmentIndex = currentEmailInsuranceCardSegment;
            shouldEmailInsuranceCard.segmentedControlStyle = UISegmentedControlStylePlain;
            shouldEmailInsuranceCard.backgroundColor = [UIColor clearColor];
            [shouldEmailInsuranceCard addTarget:self action:@selector(updateEmailInsuranceCardPreference) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:shouldEmailInsuranceCard];
            
        }
        else
        {
            shouldEmailInsuranceCard = (UISegmentedControl *)[cell.contentView viewWithTag:SHOWINSURANCECARDSELECTOR_TAG];
            shouldEmailInsuranceCard.selectedSegmentIndex = currentEmailInsuranceCardSegment;
        }
        
        cell.textLabel.text = @"Email Insurance";
        cell.backgroundColor = [UIColor clearColor];
    } else if(indexPath.section == 1)
    {
        
        cell = [tableView dequeueReusableCellWithIdentifier:notificationsCellIdentifier];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notificationsCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            clearNotifications = [UIButton buttonWithType:UIButtonTypeCustom];
            [clearNotifications addTarget:self action:@selector(clearNotifications:) forControlEvents:UIControlEventTouchUpInside];
            
//            UIImage *buttonBackground = [UIImage imageNamed:@"whiteButton.png"];
//            UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"blueButton.png"];
//            UIImage *newImage = [buttonBackground stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];	
//            UIImage *newPressedImage = [buttonBackgroundPressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
//            [clearNotifications setBackgroundImage:newImage forState:UIControlStateNormal];
//            [clearNotifications setBackgroundImage:newPressedImage forState:UIControlStateHighlighted]; 
            [clearNotifications setTitle:@"Clear All Reminders" forState:UIControlStateNormal];
            [clearNotifications setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [clearNotifications setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            clearNotifications.frame = cell.contentView.frame;
            cell.textLabel.text = @"Clear All Reminders";
            cell.textLabel.backgroundColor = [UIColor clearColor];
            //[cell.contentView addSubview:clearNotifications];
        }
        else 
        {
           // shouldPassLockControl = (UISegmentedControl *)[cell.contentView viewWithTag:PASSWORDSELECTOR_TAG];
           // shouldPassLockControl.selectedSegmentIndex = currentPasswordSegment;
        }

    } else if(indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell2"] autorelease];
        }
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults valueForKey:@"backup"] !=nil ) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else
            cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = @"Allow iOS cloud backups";
        cell.textLabel.backgroundColor = [UIColor clearColor];

        
    }
	
	UIImage *rowBackground;
	NSInteger sectionRows = [self.tableView numberOfRowsInSection:indexPath.section];
	NSInteger row = indexPath.row;

	if (row == 0 && sectionRows == 1)
		rowBackground = [UIImage imageNamed:@"IsolatedCellLightGradient.png"];
	else if (row == 0)
		rowBackground = [UIImage imageNamed:@"TopCellLightGradient.png"];
	else if (row == sectionRows - 1)
		rowBackground = [UIImage imageNamed:@"BottomCellLightGradient.png"];
	else
		rowBackground = [UIImage imageNamed:@"MiddleCellLightGradient.png"];
	
	cell.backgroundView = [[[UIImageView alloc] initWithImage:rowBackground] autorelease];
		
    return cell;
}

- (void) clearNotifications:(id)sender {
    [[UIApplication sharedApplication]  cancelAllLocalNotifications];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notifications" 
                                                    message:@"Cleared all pending reminders!!!"
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(textField.tag == FIRSTPASSFIELD)
	{
		passwordEntry.text = nil;
		passwordReEntry.text = nil;
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isPasswordLocked"];	
		[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passwordForLock"];
		
		// In case there are check marks from a previous password entry, erase them
		[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryView = nil;
		[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]].accessoryView = nil;
	}
}


- (void)entryTextChanged
{

	if([passwordEntry.text length] == 4)
	{
		[passwordEntry resignFirstResponder];
		[passwordReEntry becomeFirstResponder];
	}
	
}

- (void)reEntryTextChanged
{
	if([passwordReEntry.text length] == 4)
	{
		[passwordReEntry resignFirstResponder];
		if([passwordEntry.text isEqualToString:passwordReEntry.text])
		{
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isPasswordLocked"];	
			[[NSUserDefaults standardUserDefaults] setObject:passwordReEntry.text forKey:@"passwordForLock"];
			//UIImageView *entryCheckMark = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]] autorelease];
		//	UIImageView *reentryCheckMark = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]] autorelease];
			//[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryView = entryCheckMark;
			//[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]].accessoryView = reentryCheckMark;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SUCCESS" message:@"Added the password sucessfully!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
		}
		else {
			//UIImageView *entryXMark = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"XMark.png"]] autorelease];
		//	UIImageView *reentryXMark = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"XMark.png"]] autorelease];
			//[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryView = entryXMark;
			//[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]].accessoryView = reentryXMark;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Pin number should be same in both password fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
		}
	}
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self clearNotifications:self];
    }
    else if(indexPath.section == 2) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults valueForKey:@"backup"] != nil) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [defaults removeObjectForKey:@"backup"];
            [AppDelegate excludeCoreDataCloudBackup:YES];
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [defaults setInteger:1 forKey:@"backup"];
            [AppDelegate excludeCoreDataCloudBackup:NO];
        }
        [defaults synchronize];
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end

