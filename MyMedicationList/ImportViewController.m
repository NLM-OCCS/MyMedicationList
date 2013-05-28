//
//  ImportViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "ImportViewController.h"
#import "MMLPersonData.h"
#import "CoreDataManager.h"
#import "CCDParser.h"
#import "ButtonFactory.h"
#import "UIPickerAlertView.h"

@interface ImportViewController  ()<CCDParserDelegate,UIPickerAlertDelegate>
@property (retain,nonatomic) IBOutlet UIImageView *importImageBackground;
@property (retain,nonatomic) IBOutlet UITextField *nameImportTextField;
@property (retain,nonatomic) NSString *patientName;
@property (retain,nonatomic) CCDParser *parser;
@property (retain,nonatomic) MMLPersonData *parsedPerson;

@end

@implementation ImportViewController
@synthesize importImageBackground=_importImageBackground;
@synthesize nameImportTextField=_nameImportTextField;
@synthesize patientName = _patientName;
@synthesize parser = _parser;
@synthesize parsedPerson = _parsedPerson;

@synthesize ccdString=_ccdString;
@synthesize delegate=_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _parser = [[CCDParser alloc] init];
        _parser.delegate = self;
    }
    return self;
}

- (void)dealloc {
    self.parser = nil;
    self.delegate = nil;
    self.importImageBackground = nil;
    self.nameImportTextField = nil;
    self.patientName = nil;
    self.parsedPerson = nil;
    NSLog(@"Dealloc in importViewController");
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Date Picker callback methods
- (void)pickerAlertViewDidDismiss:(UIPickerAlertView *)pickerAlertView withDate:(NSDate *)selectedDate
{   
    _parsedPerson.dateOfBirth = selectedDate;
    [[CoreDataManager coreDataManager] saveContext];
}

#pragma mark - Parser callback methods

- (void)ccdParser:(CCDParser *)ccdParser didParsePerson:(MMLPersonData *)personData
{
    NSLog(@"ccdParser:didParsePerson: - ImportViewController");   
    self.parsedPerson = personData;
    if(personData.dateOfBirth != nil) {
        [[CoreDataManager coreDataManager] saveContext];
    } else
    {
        UIPickerAlertView *dateOfBirthPicker = [[UIPickerAlertView alloc] initWithDelegate:self];
        [dateOfBirthPicker performSelector:@selector(show) withObject:nil afterDelay:0.75];
        [dateOfBirthPicker release];
    }
}

- (void)ccdParserDidFail:(CCDParser *)ccdParser
{
    NSLog(@"ccdParserDidFail: - ImportViewController");
    UIAlertView *parseFailAlert = [[UIAlertView alloc] initWithTitle:@"Data failure" 
                                                             message:@"User data could not be extracted from the file." 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
    [parseFailAlert show];
    [parseFailAlert release];
}

#pragma mark - Decision button methods

- (void)yesImport
{
    NSLog(@"yesImport");
    
    if(self.ccdString == nil)
        [_delegate importViewControllerDidDismiss:self didImport:NO error:nil];
    
    _parser.parseString = self.ccdString;
    [_parser parse];
    
    [_delegate importViewControllerDidDismiss:self didImport:YES error:nil];
}

- (void)noImport
{
    NSLog(@"noImport");    
    [_delegate importViewControllerDidDismiss:self didImport:NO error:nil];
}


#pragma mark - ccdString property override



- (NSString *)parseNameComponent:(NSString *)component fromString:(NSString *)string
{
    NSString *elementContent = nil;
    
    NSRange componentRangeStart = [string rangeOfString:[NSString stringWithFormat:@"<%@>",component]];
    if (componentRangeStart.length != 0) {
        NSRange componentRangeEnd = [string rangeOfString:[NSString stringWithFormat:@"</%@>",component]];
        NSUInteger componentLocationStart = componentRangeStart.location+componentRangeStart.length;
        if(componentRangeEnd.length != 0)
        {
            elementContent = [string substringWithRange:NSMakeRange(componentLocationStart,componentRangeEnd.location-componentLocationStart)];
            NSLog(@"elementContent parse succeeded for %@",component);
        }
        else
            NSLog(@"elementContent parse failed for %@",component);
    }
    else
        NSLog(@"elementContent parse failed for %@",component);
    
    return elementContent;
}

- (NSString *)parsePatientName:(NSString *)ccd
{
    NSString *parsedPatientName = nil;
    
    NSString *firstName = nil;
    NSString *lastName = nil;
    
    lastName = [self parseNameComponent:@"family" fromString:ccd];
    firstName = [self parseNameComponent:@"given" fromString:ccd];
                     
    if((firstName != nil)&&(lastName != nil))
        parsedPatientName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    else
        parsedPatientName = @"Unknown User";
    
    return parsedPatientName;
}

- (void)setCcdString:(NSString *)ccdString
{
    NSLog(@"Setting the CCDString...");
    if(ccdString != _ccdString)
    {
        _ccdString = [ccdString retain];
        self.patientName = [self parsePatientName:ccdString];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.0];

    _nameImportTextField.text = @"Unknown User";
    
    CGFloat backgroundWidth = _importImageBackground.frame.size.width;
    CGFloat centerDisplayment = 55.0f;
    CGFloat verticalHeight = 186.0f;
    CGFloat buttonWidth = 80.0f;
    CGFloat buttonHeight = 40.0f;

    UIButton *yesButton = [[ButtonFactory newButtonWithTitle:@"Yes" size:CGSizeMake(buttonWidth, buttonHeight)] autorelease];
    yesButton.frame = CGRectMake((backgroundWidth-buttonWidth)/2.0-centerDisplayment, verticalHeight, buttonWidth, buttonHeight);
    [yesButton addTarget:self action:@selector(yesImport) forControlEvents:UIControlEventTouchUpInside];
    [_importImageBackground addSubview:yesButton];
    
    UIButton *noButton = [[ButtonFactory newButtonWithTitle:@"No" size:CGSizeMake(buttonWidth, buttonHeight)] autorelease];
    noButton.frame = CGRectMake((backgroundWidth-buttonWidth)/2.0+centerDisplayment, verticalHeight, buttonWidth, buttonHeight);
    [noButton addTarget:self action:@selector(noImport) forControlEvents:UIControlEventTouchUpInside];
    [_importImageBackground addSubview:noButton];

    _nameImportTextField.text = _patientName;
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

@end
