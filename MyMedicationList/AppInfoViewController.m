//
//  AppInfoViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "AppInfoViewController.h"
#import "ButtonFactory.h"
#import "ContactUsViewController.h"


@implementation AppInfoViewController
@synthesize delegate = _delegate; 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
     UIView *thisView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds] ];
     self.view = thisView;
    [thisView release];
    /////////////////////////////////////////////////////
    // Set up text on a rounded rect background
    UIImage *textBackground = [UIImage imageNamed:@"AboutTextBackground"];
    UIImage *newImage = [textBackground stretchableImageWithLeftCapWidth:15.0 topCapHeight:10.0];	
	
    UIImageView *textBackgroundView = [[UIImageView alloc] initWithImage:newImage];
    textBackgroundView.frame = CGRectMake(10, 10, 300, 155);
    
    [self.view addSubview:textBackgroundView];
    [textBackgroundView release];
    
    NSString *aboutText = @"My Medication List\nNational Library Of Medicine\n\nDepartment: MeSH\nDate Built: April 21st 2013\nVersion: 1.10";    
    UIFont *aboutTextFont = [UIFont fontWithName:@"MarkerFelt-Thin" size:19];
    
    UILabel *aboutTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, textBackgroundView.frame.size.width-20, 
                                                                           textBackgroundView.frame.size.height-20)];
    aboutTextLabel.backgroundColor = [UIColor clearColor];
    aboutTextLabel.font = aboutTextFont;
    aboutTextLabel.numberOfLines = 0;
    aboutTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    aboutTextLabel.contentMode = UIViewContentModeTop;
    
    aboutTextLabel.text = aboutText;
    
    [aboutTextLabel sizeToFit];
    
    [textBackgroundView addSubview:aboutTextLabel];
    
    float buttonWidth = 250;
    float buttonHeight = 40; 
    //composeDraftButton.frame = CGRectMake((300.0-buttonWidth)/2.0,(44-buttonHeight)/2.0,buttonWidth,buttonHeight);
    
    UIButton *composeButton = [[ButtonFactory newButtonWithTitle:@"Contact MyMedList" size:CGSizeMake(buttonWidth, buttonHeight)] autorelease];
    //composeButton.center = CGPointMake(cell.center.x-10, cell.center.y);
    composeButton.frame = CGRectMake(35, 180, 250, 40);
    [composeButton addTarget:self action:@selector(openEmailViewer) forControlEvents:UIControlEventTouchUpInside];
    [composeButton setTitle:@"Contact MyMedList Support" forState:UIControlStateNormal];
    
    //[cell.contentView addSubview:composeButton];
    [aboutTextLabel release];
    [self.view addSubview:composeButton];
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    [self.view  sendSubviewToBack:tableView];
    [tableView release];}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
  //  self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
  //  UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"HomeIcon.png"]
                           //                                            style:UIBarButtonItemStyleBordered
                            //                                          target:self
                            //                                          action:@selector(doneAndReturn)];
 //   self.navigationItem.rightBarButtonItem = rightBarButton;
 //   [rightBarButton release];
    self.navigationItem.hidesBackButton = NO;
    self.title = @"About";
    self.navigationController.navigationItem.hidesBackButton = NO;
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

-(void) openEmailViewer {

    ContactUsViewController *viewController = [[ContactUsViewController alloc]init];
   // viewController.delegate = self.delegate;
    [self.navigationController pushViewController:viewController animated:YES];
    //UINavigationController *presentNavController = [[UINavigationController alloc]init];
   // [presentNavController pushViewController:viewController animated:YES];
  //  [self presentModalViewController:presentNavController animated:YES];
[viewController release];
  //  [presentNavController release];
//if([MFMailComposeViewController canSendMail])
//{
//    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
//    mailViewController.mailComposeDelegate = self;
//    
//    //NSLog(@"%@",_CCDString);
//    //NSLog(@"%@",_CCDTable);
//    
//    [mailViewController setToRecipients:[NSArray arrayWithObjects:@"NLM_MML_Custserv@mail.nih.gov",nil]];
//    [mailViewController setSubject:@"MML:<Please enter the subject>"];
//    [mailViewController setMessageBody:@"" isHTML:YES];
//    
//    
//    [self presentModalViewController:mailViewController animated:YES];
//    [mailViewController release];
//}
//else {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Message" 
//                                                    message:@"This device is not currently setup to send email" 
//                                                   delegate:nil 
//                                          cancelButtonTitle:@"OK" 
//                                          otherButtonTitles:nil];
//    [alert show];
//    [alert release];
//}

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
