//
//  InsuranceViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "InsuranceViewController.h"
#import "OverlayViewController.h"
#import "UIImage+Resize.h"
#import "GKImagePicker.h"
#import "PictureViewerViewController.h"
@interface InsuranceViewController ()<UIActionSheetDelegate,OverlayViewControllerDelegate,GKImagePickerDelegate,PictureViewerDelegate>{
    UITextField *tmpTextField;
}
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) NSArray *placeholders;
@property (nonatomic, retain) NSArray *labelPlaceholders;
@property (nonatomic, retain) OverlayViewController *pictureViewController;
@property (nonatomic,retain) GKImagePicker *imagePicker;


-(void)  saveAddress:(id) sender;

@end

@implementation InsuranceViewController
@synthesize imagePicker;
@synthesize labels;
@synthesize placeholders;
@synthesize insuranceDataDict;
@synthesize _delegate;
@synthesize isPrimary;
@synthesize labelPlaceholders;
@synthesize frontCardBtn;
@synthesize backCardBtn;
@synthesize pictureViewController;

- (void) dealloc {
    self.labels = nil;
    self.placeholders = nil;
    self.labelPlaceholders = nil;
    self.frontCardBtn =nil;
    self.backCardBtn = nil;
    self.pictureViewController = nil;
    self.imagePicker = nil;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.labels = [NSArray arrayWithObjects:@"Carrier",
                   @"Member ID",
                   @"RxIN",
                   @"RxPCN",
                   @"RxGroup",
                   nil];
	
	self.placeholders = [NSArray arrayWithObjects:@"Enter Carrier Name",
                         @"Enter Member ID",
                         @"Enter RxIN",
                         @"Enter RxPCN",
                         @"Enter RxGroup",
                         nil];
    self.labelPlaceholders = [NSArray arrayWithObjects:@"Carrier Name",
                         @"Member ID",
                         @"RxIN",
                         @"RxPCN",
                         @"RxGroup",
                         nil];

    self.title = @"Insurance";
    
    UIBarButtonItem *rightbarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveAddress:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightbarButton;
    self.navigationItem.hidesBackButton = YES;
    [self.tableView addSubview:frontCardBtn];
    if ([insuranceDataDict objectForKey:@"FrontSide"]) {
        [frontCardBtn setBackgroundImage:[insuranceDataDict objectForKey:@"FrontSide"] forState:UIControlStateNormal];

    } else
        [frontCardBtn addTextLayer:@"Custom Text Layer" withText:@"add front side of the insurance card photo"];

    [frontCardBtn addDashedBorderLayer:@"Custom Dashed Layer" withDashDistance:4];
    [frontCardBtn addTarget:self action:@selector(displayEditPhotoActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    frontCardBtn.tag = 0;
    if ([insuranceDataDict objectForKey:@"BackSide"]) {
        [backCardBtn setBackgroundImage:[insuranceDataDict objectForKey:@"BackSide"] forState:UIControlStateNormal];
        
    } else
        [backCardBtn addTextLayer:@"Custom Text Layer" withText:@"add back side of the insurance card photo"];
    [self.tableView addSubview:backCardBtn];
    
    [backCardBtn addDashedBorderLayer:@"Custom Dashed Layer" withDashDistance:4];
    [backCardBtn addTarget:self action:@selector(displayEditPhotoActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    backCardBtn.tag = 1;

    

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isPrimary) {
        self.title = @"Primary Insurance";
    } else {
        self.title = @"Secondary Insurance";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == 4 && [indexPath section] == 0){
        CGRect frame = cell.frame;
        frontCardBtn.frame = CGRectMake(frame.origin.x+10, frame.origin.y+frame.size.height+20, frontCardBtn.frame.size.width,frontCardBtn.frame.size.height);
        backCardBtn.frame = CGRectMake(frame.origin.x+10+frontCardBtn.frame.size.width+10, frame.origin.y+frame.size.height+20, backCardBtn.frame.size.width,backCardBtn.frame.size.height);
    }
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 6) {
        return 150;
    } else {
        return 44.0;
    }
}
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
	
	//cell.leftLabel.text = [self.labels objectAtIndex:indexPath.row];
	cell.rightTextField.placeholder = [self.placeholders objectAtIndex:indexPath.row];
    if (insuranceDataDict != nil && [insuranceDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]] != nil) {
        cell.rightTextField.text = [insuranceDataDict valueForKey:[self.labels objectAtIndex:indexPath.row]];
    }
	cell.indexPath = indexPath;
	cell.delegate = self;
    //Disables UITableViewCell from accidentally becoming selected.
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
}



- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if (tmpTextField == nil) {
        return YES;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview];
    [insuranceDataDict setValue:textField.text forKey:[self.labels objectAtIndex:indexPath.row] ];
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
        [_delegate saveInsuranceInfo:insuranceDataDict isPrimary:isPrimary];
	}   
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
    int btnIndex = buttonIndex;
    if (actionSheet.tag < 1000) {
        btnIndex++;
    } else {
        actionSheet.tag = actionSheet.tag - 1000;
    }
    CGSize imageSize;
    UIImage *image;
    if (actionSheet.tag == 0) {
        imageSize = self.frontCardBtn.frame.size;
        image = [self.frontCardBtn backgroundImageForState:UIControlStateNormal];

    } else {
        imageSize = self.backCardBtn.frame.size;
        image = [self.backCardBtn backgroundImageForState:UIControlStateNormal];


    }
    if (btnIndex == 0) {
        PictureViewerViewController *pictureViewerViewController = [[PictureViewerViewController alloc] initWithNibName:@"PictureViewerViewController" bundle:nil];
        pictureViewerViewController.cardImage = image;
        pictureViewerViewController.delegate = self;
        [self presentModalViewController:pictureViewerViewController animated:YES];
        [pictureViewerViewController release];
    } else if(btnIndex == 1)
		{
            self.pictureViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureViewController.delegate = self;
            pictureViewController.imageSize = imageSize;
			[pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            [self presentModalViewController:pictureViewController.imagePickerController animated:YES];
            pictureViewController.imagePickerController.view.tag = actionSheet.tag;
		}
		else if(btnIndex == 2)
		{
			self.pictureViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
			pictureViewController.delegate = self;
            pictureViewController.imageSize = self.frontCardBtn.frame.size;

			//Take a photograph with the camera.
			if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                [pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeCamera];
			else
				[pictureViewController setupImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];;
			
            pictureViewController.imagePickerController.view.tag = actionSheet.tag;
			[self presentModalViewController:pictureViewController.imagePickerController animated:YES];
		}
		else if(buttonIndex == 3)
		{
            if (actionSheet.tag == 0) {
            [frontCardBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [insuranceDataDict removeObjectForKey:@"FrontSide"];
            [frontCardBtn addTextLayer:@"Custom Text Layer" withText:@"add front side of the insurance card photo"];
            } else {
                
            [backCardBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [insuranceDataDict removeObjectForKey:@"BackSide"];
            [backCardBtn addTextLayer:@"Custom Text Layer" withText:@"add back side of the insurance card photo"];
            }

		}
		else if(buttonIndex == 4)
		{
			;
		}
	    
}
// The user will pick what to do with when the medication image is touched

- (void)displayEditPhotoActionSheet:(id)sender
{
    NSLog(@"displayEditPhotoActionSheet");
    UIActionSheet *editPhotoQuery;
    UIImage *image;
    if ([sender tag] == 0) { // front card
        image = [self.frontCardBtn backgroundImageForState:UIControlStateNormal];

    } else {
        // back card
        image = [self.backCardBtn backgroundImageForState:UIControlStateNormal];
    }
    if (image != nil) {
        editPhotoQuery = [[UIActionSheet alloc] initWithTitle:@"Options to add or change the Insurance Card photo"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"View Photo",@"Choose Photo",@"Take Photo",@"Delete Photo",nil];
        editPhotoQuery.tag = [sender tag]+1000;
    } else {
        editPhotoQuery   = [[UIActionSheet alloc] initWithTitle:@"Options to add or change the Insurance Card image"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Choose Photo",@"Take Photo",@"Delete Photo",nil];
        editPhotoQuery.tag = [sender tag];
        
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
    if (tag == 0) {
        [insuranceDataDict setObject:picture forKey:@"FrontSide" ];
         UIImage *image2 = [picture resizedImage:CGSizeMake(140,100) interpolationQuality:kCGInterpolationHigh ];
        [frontCardBtn setBackgroundImage:image2 forState:UIControlStateNormal];
        [frontCardBtn removeLayer:@"Custom Text Layer"];
    } else {
        [insuranceDataDict setObject:picture forKey:@"BackSide" ];
         UIImage *image2 = [picture resizedImage:CGSizeMake(140,100) interpolationQuality:kCGInterpolationHigh ];
        [backCardBtn setBackgroundImage:image2 forState:UIControlStateNormal];
        [backCardBtn removeLayer:@"Custom Text Layer"];
    }

}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image {
    int tag = 0;
    if (tag == 0) {
        [insuranceDataDict setObject:image forKey:@"FrontSide" ];
        UIImage *image2 = [image resizedImage:CGSizeMake(140,100) interpolationQuality:kCGInterpolationHigh ];
        [frontCardBtn setBackgroundImage:image2 forState:UIControlStateNormal];
        [frontCardBtn removeLayer:@"Custom Text Layer"];
    } else {
        [insuranceDataDict setObject:image forKey:@"BackSide" ];
        UIImage *image2 = [image resizedImage:CGSizeMake(140,100) interpolationQuality:kCGInterpolationHigh ];
        [backCardBtn setBackgroundImage:image2 forState:UIControlStateNormal];
        [backCardBtn removeLayer:@"Custom Text Layer"];
    }

}


/**
 * @method imagePickerDidCancel: gets called when the user taps the cancel button
 * @param imagePicker, the image picker instance
 */
- (void)imagePickerDidCancel:(GKImagePicker *)imagePicker{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)pictureViewerDidDismiss:(PictureViewerViewController *)pictureViewerViewController
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
