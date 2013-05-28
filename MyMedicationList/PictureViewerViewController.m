//
//  PictureViewerViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "PictureEncasingView.h"
#import "PictureViewerViewController.h"

@interface PictureViewerViewController (){
    UIImage *_defaultInsuranceCardImage;
}
@property (strong,nonatomic) IBOutlet UIScrollView *pictureScrollView;
@property (strong,nonatomic) PictureEncasingView *pictureEncasingView;
@property (strong,nonatomic) UIToolbar *toolbar;
@property (strong,nonatomic) UIButton *cancelButton;

@end



@implementation PictureViewerViewController
@synthesize pictureScrollView = _pictureScrollView;
@synthesize pictureEncasingView = _pictureEncasingView;
@synthesize cardImage = _cardImage;
@synthesize delegate = _delegate;
@synthesize toolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"PictureViewViewController initWithNibName");
        // Custom initialization
               
        _defaultInsuranceCardImage = [UIImage imageNamed:@"InsuranceCard.png"];
        [_defaultInsuranceCardImage retain];
        
        PictureEncasingView *encasingView = [[PictureEncasingView alloc] initWithEncasedImage:_defaultInsuranceCardImage];
        self.pictureEncasingView = encasingView;
        [encasingView release];
    }
    return self;
}


- (void)dealloc {
    [_defaultInsuranceCardImage release];
    _defaultInsuranceCardImage = nil;
    self.pictureScrollView = nil;
    self.delegate = nil;
    [super dealloc];
}
 

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Card Image property methods

- (void)setCardImage:(UIImage *)cardImage
{
    NSLog(@"setCardImage:");
    if(self.pictureEncasingView == nil)
        NSLog(@"self.pictureEncasingView == nil");
    if(self.pictureEncasingView.encasedImage == nil)
        NSLog(@"self.pictureEncasingView.encasedImage == nil");
    if(cardImage == nil)
        NSLog(@"cardImage == nil");
    self.pictureEncasingView.encasedImage = cardImage;
}

- (UIImage *)cardImage
{
    return self.pictureEncasingView.encasedImage;
}

#pragma mark - Scroll View delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    NSLog(@"viewForZoomingInScrollView:");
    return self.pictureEncasingView;
}

#pragma mark - Tap Gesture callback

- (void)dismiss:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [_delegate pictureViewerDidDismiss:self];
}
- (void)_setupCancelButton{
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButtonPressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
    
    [[self.cancelButton titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
    [[self.cancelButton titleLabel] setShadowOffset:CGSizeMake(0, 1)];
    [self.cancelButton setFrame:CGRectMake(0, 0, 50, 30)];
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel",@"") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:0.173 green:0.176 blue:0.176 alpha:1] forState:UIControlStateNormal];
    [self.cancelButton setTitleShadowColor:[UIColor colorWithRed:0.827 green:0.831 blue:0.839 alpha:1] forState:UIControlStateNormal];
    [self.cancelButton  addTarget:self action:@selector(_actionCancel) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)_setupToolbar{
        self.toolbar = [[[UIToolbar alloc] initWithFrame:CGRectZero] autorelease];
        [self.toolbar setBackgroundImage:[self _toolbarBackgroundImage] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [self.view addSubview:self.toolbar];
        
        [self _setupCancelButton];
       // [self _setupUseButton];
        
        UIBarButtonItem *cancel = [[[UIBarButtonItem alloc] initWithCustomView:self.cancelButton] autorelease];
        UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        
        [self.toolbar setItems:[NSArray arrayWithObjects:cancel, flex,  nil]];
}
- (UIImage *)_toolbarBackgroundImage{
    
    CGFloat components[] = {
        1., 1., 1., 1.,
        123./255., 125/255., 132./255., 1.
    };
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 54), YES, 0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(0, 54), kCGImageAlphaNoneSkipFirst);
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	
	CGGradientRelease(gradient);
    UIGraphicsEndImageContext();
    CGColorSpaceRelease(colorSpace);
    
    
    return viewImage;
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"super viewDidLoad");
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
   // UITapGestureRecognizer *tapDismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
 //   [self.pictureScrollView addGestureRecognizer:tapDismissGesture];
 //   [tapDismissGesture release];
    //[self _setupToolbar];
    
    [self.pictureScrollView addSubview:self.pictureEncasingView];
  //  [self.toolbar setHidden:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"shouldAutorotateToInterfaceOrientation2");
    if(interfaceOrientation == UIInterfaceOrientationPortrait)
        NSLog(@"shouldAutorotateToInterfaceOrientation Portrait view");
    else
        NSLog(@"shouldAutorotateToInterfaceOrientation Landscape view");
    if(interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown)
    {
        self.pictureEncasingView.interfaceOrientation = interfaceOrientation;
        return YES;
    }
    else 
        return NO;
}

@end
