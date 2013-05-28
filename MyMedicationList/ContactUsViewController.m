//
//  ContactUsViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "ContactUsViewController.h"

@implementation ContactUsViewController
@synthesize delegate,sendMailBtn,tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
    self.sendMailBtn = nil;
    self.tableView = nil;
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)doneAndReturn
{
    [self.delegate viewControllerWillReturnHome:self.navigationController];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
   // self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.title =@"Contact MyMedList";
    
    
    UIImage *textBackground = [UIImage imageNamed:@"AboutTextBackground"];
    UIImage *newImage = [textBackground stretchableImageWithLeftCapWidth:15.0 topCapHeight:10.0];	
	
    UIImageView *textBackgroundView = [[UIImageView alloc] initWithImage:newImage];
    textBackgroundView.frame = CGRectMake(10, 10, 300, 160);
    
    
    UIImage *textBackground1 = [UIImage imageNamed:@"AboutTextBackground"];
    UIImage *newImage1 = [textBackground1 stretchableImageWithLeftCapWidth:15.0 topCapHeight:10.0];	
	
    UIImageView *textBackgroundView1 = [[UIImageView alloc] initWithImage:newImage1];
    textBackgroundView1.frame = CGRectMake(10, 180, 300, 200);

    
    [self.view addSubview:textBackgroundView];
    [self.view sendSubviewToBack:textBackgroundView];
    [textBackgroundView release];
    [self.view addSubview:textBackgroundView1];
    [self.view sendSubviewToBack:textBackgroundView1];
    [textBackgroundView1 release];
    UIImage *buttonBackground = [UIImage imageNamed:@"whiteButton.png"];
    UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"blueButton.png"];
    sendMailBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	sendMailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[sendMailBtn setTitle:@"Send Mail" forState:UIControlStateNormal];
	
    [sendMailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendMailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	
	UIImage *newImage3 = [buttonBackground stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[sendMailBtn setBackgroundImage:newImage3 forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [buttonBackgroundPressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[sendMailBtn setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	sendMailBtn.backgroundColor = [UIColor clearColor];
    [self.view  sendSubviewToBack:tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void) openEmailViewer:(id)sender {
    
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        
        //NSLog(@"%@",_CCDString);
        //NSLog(@"%@",_CCDTable);
        
        [mailViewController setToRecipients:[NSArray arrayWithObjects:@"mmlinfo@mail.nlm.nih.gov",nil]];
        [mailViewController setSubject:@"MML:<Please enter the subject>"];
        [mailViewController setMessageBody:@"" isHTML:YES];
        
        
        [self presentModalViewController:mailViewController animated:YES];
        [mailViewController release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Message" 
                                                        message:@"This device is not currently setup to send email" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	
	if(result == MFMailComposeResultCancelled)
		NSLog(@"The mail was cancelled.");
	else if(result == MFMailComposeResultSent)
		NSLog(@"The mail was sent");
	
	if(error != nil)
		NSLog(@"%@",[error description]);
	
	// The user is done using the email to send his/her. Dismiss the mail view controller
	[self dismissModalViewControllerAnimated:YES];
}
@end
