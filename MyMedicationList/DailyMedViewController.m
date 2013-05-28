    //
//  DailyMedViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "DailyMedViewController.h"


@interface DailyMedViewController ()<UIWebViewDelegate> {
    UITapGestureRecognizer *_doubleTapGesture;
}
@property (retain,nonatomic) UIWebView *dailyMedWebView;
@property (retain,nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation DailyMedViewController
@synthesize dailyMedWebView = _dailyMedWebView;
@synthesize activityIndicator = _activityIndicator;

@synthesize delegate = _delegate;
@synthesize rxcuiString = _rxcuiString;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.title = @"Daily Med";
		self.rxcuiString = nil;
    }
    return self;
}

- (void)dealloc {
    
    self.rxcuiString = nil;
    self.activityIndicator = nil;
    self.dailyMedWebView = nil;
    
    [self.navigationController.navigationBar removeGestureRecognizer:_doubleTapGesture];
    [_doubleTapGesture release];
    
    [super dealloc];
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	
	self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
	self.view.backgroundColor = [UIColor whiteColor];

	self.title = @"DailyMed";
	
    UIBarButtonItem *rightBarButton = nil;
	if(_rxcuiString == nil)
	{
		rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"HomeIcon.png"] 
                                                          style:UIBarButtonItemStyleBordered 
                                                         target:self
                                                         action:@selector(doneAndReturn)];
	}
	else
	{
		rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(popViewControllerAnimated)];
	}

    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightBarButton release];
    
    
	self.dailyMedWebView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 460-44)] autorelease];
	_dailyMedWebView.delegate = self;
    
    // Double tap the navigation bar to return home
	_doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToHomePage)];
	_doubleTapGesture.numberOfTapsRequired = 2;
	[self.navigationController.navigationBar addGestureRecognizer:_doubleTapGesture];
     
    
	//UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
											//									   target:_dailyMedWebView
											//									   action:@selector(goBack)];
	//self.navigationItem.leftBarButtonItem = leftBarButton;
	// [leftBarButton release];
	
	[self.view addSubview:_dailyMedWebView];
	
	_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_activityIndicator.frame = CGRectMake(145, 220, 30, 30);
	[self.view addSubview:_activityIndicator];
}

- (void)goToHomePage
{
	NSString *urlStr = [NSString stringWithFormat:@"http://dailymed.nlm.nih.gov/"];
	NSURL *url = [NSURL URLWithString:urlStr];
	NSURLRequest *dailyMedRequest = [NSURLRequest requestWithURL:url];
	[_dailyMedWebView loadRequest:dailyMedRequest];
}

- (void)popViewControllerAnimated
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAndReturn
{
	[_delegate viewControllerWillReturnHome:self.navigationController];
}

// Start the activity indicator for when the webpage is loading
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[_activityIndicator startAnimating];
}

// Stop the activity indicator for when the webpage has stopped loading
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[_activityIndicator stopAnimating];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	//self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *urlStr;
	if(_rxcuiString == nil)
		urlStr = [NSString stringWithFormat:@"http://dailymed.nlm.nih.gov/"];
	else
		urlStr = [NSString stringWithFormat:@"http://dailymed.nlm.nih.gov/dailymed/mobile/rxcui.cfm?rxcui=%@",_rxcuiString];
		
	NSURL *url = [NSURL URLWithString:urlStr];
	NSURLRequest *dailyMedRequest = [NSURLRequest requestWithURL:url];
	[_dailyMedWebView loadRequest:dailyMedRequest];
}

 
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	// Return YES for supported orientations.
	if(interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown)
	{
		if(interfaceOrientation == UIInterfaceOrientationPortrait)
			_dailyMedWebView.frame = CGRectMake(0, 0, 320, 460-44);
		if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)||(interfaceOrientation == UIInterfaceOrientationLandscapeRight))
			_dailyMedWebView.frame = CGRectMake(0, 0, 480, 300-34);
		//[dailyMedWebView reload];
		return YES;
	}
	else
		return NO;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    //dailyMedWebView = nil;
}

@end
