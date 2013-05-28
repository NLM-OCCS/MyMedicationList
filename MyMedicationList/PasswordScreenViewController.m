//
//  PasswordScreenViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "PasswordScreenViewController.h"


@interface PasswordScreenViewController ()<UITextFieldDelegate> {
    
}

@property (retain,nonatomic) IBOutlet UITextField *passwordField;
@property (retain,nonatomic) IBOutlet UIImageView *passwordAttemptResponse;

@end

@implementation PasswordScreenViewController
@synthesize passwordField = _passwordField;
@synthesize passwordAttemptResponse = _passwordAttemptResponse;
@synthesize delegate = _delegate;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		_passwordField.delegate = self;
		_passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_passwordField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc - PasswordScreenViewController");
    self.passwordField = nil;
    self.passwordAttemptResponse = nil;
    [super dealloc];
}

- (void)passwordFieldUpdated:(id)sender
{
	NSLog(@"Here is the text %@", _passwordField.text);
	if([_passwordField.text length] == 4)
	{
		if([_passwordField.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"passwordForLock"]])
			[_delegate passwordScreenViewControllerDidEnterCorrectPassword:self];
        else
        {
            __block PasswordScreenViewController *blockSelf = self;
            NSTimeInterval animationTime = 0.25;
            NSTimeInterval animationDelay = 1.5;            
            [UIView animateWithDuration:animationTime animations:^{
                blockSelf.passwordAttemptResponse.alpha = 1;
            }];
            
            [UIView animateWithDuration:animationTime delay:animationDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                blockSelf.passwordAttemptResponse.alpha = 0;
            }completion:^(BOOL finished) {
                blockSelf.passwordField.text = nil;
            }];

        }
	}
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[_passwordField addTarget:self action:@selector(passwordFieldUpdated:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
