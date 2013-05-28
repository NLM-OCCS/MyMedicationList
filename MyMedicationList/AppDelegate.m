//
//  AppDelegate.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "AppDelegate.h"
#import "ImportViewController.h"
#import "ProfileManager.h"
#import "DisplayNameService.h"
#import "PasswordScreenViewController.h"

#import "ConceptProperty.h"
#import "Medication.h"
#import "Prescription.h"
#import "MedicationContainer.h"
#import "MedicationList.h"
#import "UserListViewController.h"
#import "MMLInsurance.h"
#import "MMLMedListViewController.h"
#import "MMLMedicationFrequency.h"
#import "MMLMedicationAmount.h"
#import "MMLMedicationInstruction.h"
#import "MMLConceptProperty.h"
#import "MMLCCDInfo.h"
#import "MMLIngredients.h"
#import "MMLMedication.h"
#import "MMLMedicationList.h"
#import "MMLPersonData.h"
#import  "CoreDataManager.h"

@interface AppDelegate ()<ImportViewDelegate,PasswordScreenDelegate>
@property (retain,nonatomic) ImportViewController *importViewController;
@property (retain,nonatomic) UserListViewController *homeScreenController;


- (void)loadSplashScreen;
- (void)loadPasswordScreen;

@end

@implementation AppDelegate
@synthesize importViewController = _importViewController;
@synthesize window = _window;
@synthesize homeScreenController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (NSArray *)parseIngredientString:(NSString *)ingredientString
{
    NSArray *components = [ingredientString componentsSeparatedByString:@" / "];
   
    NSMutableArray *ingredientStrings = [NSMutableArray arrayWithCapacity:[components count]];

    for (NSString *component in components)
        [ingredientStrings addObject:[component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    return ingredientStrings;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    

    NSLog(@"application:didFinishLaunchingWithOptions:");
    application.applicationIconBadgeNumber  = 0;
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    UserListViewController *profileListViewController = [[UserListViewController alloc] initWithNibName:@"ProfileListViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:profileListViewController];
    self.homeScreenController = profileListViewController;
    self.homeScreenController.importViewController = nil;
    
    [self loadSplashScreen];
    
    if([DisplayNameService needsUpdate])
    {
        DisplayNameService *displayNameService = [DisplayNameService displayNameService];
        [displayNameService updateDisplayNames];
    }
    self.window.rootViewController = navController;
    [navController release];
    [profileListViewController release];
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    application.applicationIconBadgeNumber = 0;
    NSString *reminderText = [notification.userInfo
                              objectForKey:@"kRemindMeNotificationDataKey"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reminder" 
                                                        message:reminderText delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"The url that is being passed when this application is opened is: %@",[url absoluteString]);
    
    NSError *error = nil;
    NSString *urlContents = [[[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error] autorelease];
    if(error)
    {
        NSLog(@"The was an error loading the contents of the URL.");
        NSLog(@"%@",[error localizedDescription]);
        NSLog(@"%@",[error localizedFailureReason]);
        UIAlertView *importErrorAlert = [[UIAlertView alloc] initWithTitle:@"Import Error"
                                                                   message:@"MyMedication encounted an error loading the medication list"
                                                                  delegate:nil 
                                                         cancelButtonTitle:@"OK" 
                                                         otherButtonTitles:nil];
        [importErrorAlert show];
        [importErrorAlert release];
        
        return NO;
    }
    // The file was successfully loaded into a string. Now we must ask the user if he/she would like to parse the xml
    // and turn it into a medicationlist
    else{
        
        NSLog(@"urlContents\n%@",urlContents);
        
        
        self.importViewController = [[[ImportViewController alloc] initWithNibName:@"ImportViewController" bundle:nil]autorelease];
        self.importViewController.delegate = self;
        self.importViewController.ccdString = urlContents;
        
        self.homeScreenController.importViewController = self.importViewController;
        if (self.importViewController != nil && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isPasswordLocked"]) {
                [self.homeScreenController presentModalImportViewController];
            }
        return YES;
    }
}

- (void)importViewControllerDidDismiss:(ImportViewController *)importViewController didImport:(BOOL)didImport error:(NSError *)error
{
    NSLog(@"importViewControllerDidDismiss:didImport:error");
    [self.homeScreenController dismissModalImportViewController];
    self.importViewController = nil;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //[[ProfileManager profileManager] saveProfiles];
    [[CoreDataManager coreDataManager] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    NSLog(@"applicationWillEnterForeground:");
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isPasswordLocked"])
		[self loadPasswordScreen];
       application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    NSLog(@"applicationDidBecomeActive:");
    if([DisplayNameService needsUpdate] )
    {
        DisplayNameService *displayNameService = [DisplayNameService displayNameService];
        if (!displayNameService.isUpdating)
            [displayNameService updateDisplayNames];
    }
    [self.homeScreenController migrateToCoreData];

}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)loadSplashScreen
{    
    NSLog(@"loadSplashScreen");
    // Attempt to load the splash screen image then check to make
	// sure that it is valid.
	UIImage *splashScreen = [UIImage imageNamed:@"Default"];
	    
	// Initialize the view containing the splash screen and add it to the main window
	UIImageView *splashScreenView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    splashScreenView.autoresizesSubviews = YES;
    splashScreenView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
	splashScreenView.image = splashScreen;

	[self.window addSubview:splashScreenView];
    [splashScreenView release];
    
    // Display the splash screen for 'delay' number of seconds then begin to animate it out.
	NSTimeInterval delay = 0.0;

    // The time the animation takes to complete
//    NSTimeInterval duration = 1.7;
    NSTimeInterval duration = 0.5;
    
    __block AppDelegate *blockSelf = self;
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        blockSelf.homeScreenController.view.userInteractionEnabled = NO;
        splashScreenView.alpha = 0;
    } completion:^(BOOL finished){
        [splashScreenView removeFromSuperview];
       blockSelf.homeScreenController.view.userInteractionEnabled = YES;
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"isPasswordLocked"])
            [blockSelf loadPasswordScreen];
        else{
            if([[NSUserDefaults standardUserDefaults] integerForKey:@"NumberOfTimesRun"] == 0)
            {
                [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"NumberOfTimesRun"];
                UIAlertView *setupProfileAlert = [[UIAlertView alloc] initWithTitle:@"Welcome To MyMedicationList" 
                                                                            message:@"Please create a profile to add medications." 
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                [setupProfileAlert show];
                [setupProfileAlert release];
            }
        }
    }];
}

- (void)loadPasswordScreen
{
    NSLog(@"loadPasswordScreen");    
	PasswordScreenViewController *passwordScreen = [[PasswordScreenViewController alloc] initWithNibName:@"PasswordScreenView" bundle:[NSBundle mainBundle]];
	passwordScreen.delegate = self;
	[self.window.rootViewController presentViewController:passwordScreen animated:YES completion:nil];
	[passwordScreen release];
}

- (void)passwordScreenViewControllerDidEnterCorrectPassword:(PasswordScreenViewController *)passwordScreenViewController
{
    NSLog(@"passwordScreenViewControllerDidEnterCorrectPassword:");
    if (self.importViewController != nil) {
        [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
            [self.homeScreenController presentModalImportViewController];
        }];
    } else
        [self.window.rootViewController dismissModalViewControllerAnimated:YES];

}

//Explicitly write Core Data accessors
- (NSManagedObjectContext *) managedObjectContext {
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    __managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"MMLCoreDataDB.sqlite"]];
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if(![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        /*Error for store creation should be handled in here*/
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"backup"] !=nil ) {
        NSError *error = nil;
        BOOL success = [storeUrl setResourceValue: [NSNumber numberWithBool: NO]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        
        if(!success){
            
            NSLog(@"Error excluding %@ from backup %@", [storeUrl lastPathComponent], error);
            
        }
    } else {
        NSError *error = nil;
        BOOL success = [storeUrl setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [storeUrl lastPathComponent], error);
            
        }
    }
    return __persistentStoreCoordinator;
}

+ (void) excludeCoreDataCloudBackup:(BOOL) exclude {
    NSURL *storeUrl = [NSURL fileURLWithPath: [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
                                               stringByAppendingPathComponent: @"MMLCoreDataDB.sqlite"]];

    if (exclude) {
        NSError *error = nil;
        BOOL success = [storeUrl setResourceValue: [NSNumber numberWithBool: YES]
                                           forKey: NSURLIsExcludedFromBackupKey error: &error];
        
        if(!success){
            
            NSLog(@"Error excluding %@ from backup %@", [storeUrl lastPathComponent], error);
            
        }
  
    } else {
        NSError *error = nil;
        BOOL success = [storeUrl setResourceValue: [NSNumber numberWithBool: NO]
                                           forKey: NSURLIsExcludedFromBackupKey error: &error];
        
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [storeUrl lastPathComponent], error);
            
        }

    }
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (BOOL) migrateToCoreData:(PersonData *)person {
    if (person != nil) {
        MMLPersonData *cperson = [[CoreDataManager coreDataManager] newPersonData];
        cperson.firstName = person.firstName;
        cperson.lastName = person.lastName;
        if (person.dateOfBirth != nil) {
            NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
            NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
            [components setYear:person.dateOfBirth.year];
            [components setMonth:person.dateOfBirth.month];
            [components setDay:person.dateOfBirth.day];
            cperson.dateOfBirth = [calendar dateFromComponents:components];
        }
        

        cperson.phoneNumer = person.phoneNumber;
        cperson.gender = [NSNumber numberWithInt:person.gender];
        cperson.streetAddress1 = person.streetAddress;
        cperson.streetAddress2 = person.streetAddress2;
        cperson.city = person.city;
        cperson.state = person.state;
        cperson.zip = person.zip;
        cperson.userId = person.userID;
        cperson.personImage = UIImagePNGRepresentation(person.personImage);
        MMLInsurance *primaryInsurance = [[CoreDataManager coreDataManager] newInsurance];
        primaryInsurance.carrier = person.carrier;
        primaryInsurance.groupNumber = person.groupNumber;
        primaryInsurance.memberNumber = person.memberNumber;
        primaryInsurance.rxIN = person.rxIN;
        primaryInsurance.rxPCN = person.rxPCN;
        primaryInsurance.rxGroup = person.rxGroup;
        primaryInsurance.backCardImage = UIImagePNGRepresentation(person.backCardImage);
        primaryInsurance.frontCardImage = UIImagePNGRepresentation(person.cardImage);
        cperson.insurance = primaryInsurance;
        MMLInsurance *secondaryInsurance = [[CoreDataManager coreDataManager] newInsurance];
        secondaryInsurance.carrier = person.carrier2;
        secondaryInsurance.groupNumber = person.groupNumber2;
        secondaryInsurance.memberNumber = person.memberNumber2;
        secondaryInsurance.rxIN = person.rxIN2;
        secondaryInsurance.rxPCN = person.rxPCN2;
        secondaryInsurance.rxGroup = person.rxGroup2;
        secondaryInsurance.backCardImage = UIImagePNGRepresentation(person.backCardImage2);
        secondaryInsurance.frontCardImage = UIImagePNGRepresentation(person.cardImage2);
        
        MMLMedicationList *currentMedicationList = [[CoreDataManager coreDataManager] newMedicationList];
        for (int i=0; i < [person.currentMedicationList count];i++) {
            MedicationContainer *container = [person.currentMedicationList objectAtIndex:i];
            Medication *oldMed = container.medication;
            MMLMedication *newMed = [[CoreDataManager coreDataManager] newMedication];
            newMed.name = oldMed.name;
            if (oldMed.startDate != nil) {
                NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
                NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
                [components setYear:oldMed.startDate.year];
                [components setMonth:oldMed.startDate.month];
                [components setDay:oldMed.startDate.day];
                newMed.startDate = [calendar dateFromComponents:components];
            }
            if (oldMed.stopDate != nil) {
                NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
                NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
                [components setYear:oldMed.stopDate.year];
                [components setMonth:oldMed.stopDate.month];
                [components setDay:oldMed.stopDate.day];
                newMed.stopDate = [calendar dateFromComponents:components];
            }
            if (oldMed.amount != nil) {
                MMLMedicationAmount *medAmount = [[CoreDataManager coreDataManager] newamount];
                medAmount.quantity = [NSNumber numberWithInt:oldMed.amount.quantity ];
                medAmount.amountType = [NSNumber numberWithInt:oldMed.amount.amountType ];
                newMed.medicationAmount = medAmount;
            }
            if (oldMed.frequency != nil) {
                MMLMedicationFrequency *medFrequency = [[CoreDataManager coreDataManager]newFrequency];
                medFrequency.frequency = [NSNumber numberWithInt:oldMed.frequency.frequency];
                newMed.medicationFrequency = medFrequency;
                NSLog(@"Frequency is %d", oldMed.frequency.frequency);
            }
            if (oldMed.instruction != nil) {
            MMLMedicationInstruction *medInstruction = [[CoreDataManager coreDataManager] newInstruction];
            medInstruction.instruction = [oldMed.instruction printInstruction];
            newMed.medicationInstruction = medInstruction;
            }
            if (oldMed.ingredients !=0 && [oldMed.ingredients count] > 0 ) {
                for (int j=0; j < [oldMed.ingredients count]; j++) {
                    MMLIngredients *newIngredient = [[CoreDataManager coreDataManager] newIngredients];
                    newIngredient.ingredient = [oldMed.ingredients objectAtIndex:j];
                    [newMed addIngredientsArrayObject:newIngredient];
                }
            }
            newMed.image = UIImagePNGRepresentation(oldMed.image);
            MMLConceptProperty *newConceptProperty = [[CoreDataManager coreDataManager] newConceptProperty];
            newConceptProperty.rxcui = [oldMed.conceptProperty rxcui];
            newConceptProperty.name = [oldMed.conceptProperty name];
            newConceptProperty.synonym = [oldMed.conceptProperty synonym];
            newConceptProperty.termtype = [oldMed.conceptProperty termtype];
            newConceptProperty.language = [oldMed.conceptProperty language];
            newConceptProperty.suppressflag = [oldMed.conceptProperty suppressflag];
            newConceptProperty.umlsCUI = [oldMed.conceptProperty UMLSCUI];
            newMed.conceptProperty = newConceptProperty;
            
            MMLCCDInfo *newCCDInfo = [[CoreDataManager coreDataManager] newCCDInfo];
            newCCDInfo.isClinicalDrug = [NSNumber numberWithBool:[oldMed.ccdInfo isClinicalDrug]];
            newCCDInfo.codeDisplayName = [oldMed.ccdInfo codeDisplayName];
            newCCDInfo.codeDisplayNameRxCUI = [oldMed.ccdInfo codeDisplayNameRxCUI];
            newCCDInfo.translationDisplayName = [oldMed.ccdInfo translationDisplayName];
            newCCDInfo.ingredientName = [oldMed.ccdInfo ingredientName];
            newCCDInfo.translationDisplayNameRxCUI = [oldMed.ccdInfo translationDisplayNameRxCUI];
            newCCDInfo.brandName = [oldMed.ccdInfo brandName];            
            newMed.ccdInfo = newCCDInfo;
            newMed.creationID = [NSNumber numberWithLong:oldMed.creationID ];
            [currentMedicationList addMedicationListObject:newMed];
        }
        cperson.currentMedicationList = currentMedicationList;
        MMLMedicationList *discontinuedMedicationList = [[CoreDataManager coreDataManager] newMedicationList];
        for (int i=0; i < [person.discontinuedMedicationList count];i++) {
            MedicationContainer *container = [person.discontinuedMedicationList objectAtIndex:i];
            Medication *oldMed = container.medication;
            MMLMedication *newMed = [[CoreDataManager coreDataManager] newMedication];
            newMed.name = oldMed.name;
            if (oldMed.startDate != nil) {
                NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
                NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
                [components setYear:oldMed.startDate.year];
                [components setMonth:oldMed.startDate.month];
                [components setDay:oldMed.startDate.day];
                newMed.startDate = [calendar dateFromComponents:components];
            }
            if (oldMed.stopDate != nil) {
                NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
                NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
                [components setYear:oldMed.stopDate.year];
                [components setMonth:oldMed.stopDate.month];
                [components setDay:oldMed.stopDate.day];
                newMed.stopDate = [calendar dateFromComponents:components];
            }
                     
            if (oldMed.amount != nil) {
                MMLMedicationAmount *medAmount = [[CoreDataManager coreDataManager] newamount];
                medAmount.quantity = [NSNumber numberWithInt:oldMed.amount.quantity ];
                medAmount.amountType = [NSNumber numberWithInt:oldMed.amount.amountType ];
                newMed.medicationAmount = medAmount;
            }
            
            if (oldMed.frequency != nil) {
                MMLMedicationFrequency *medFrequency = [[CoreDataManager coreDataManager]newFrequency];
                medFrequency.frequency = [NSNumber numberWithInt:oldMed.frequency.frequency];
                newMed.medicationFrequency = medFrequency;
                NSLog(@"Frequency is %d", oldMed.frequency.frequency);
            }
            if (oldMed.instruction != nil) {
                MMLMedicationInstruction *medInstruction = [[CoreDataManager coreDataManager] newInstruction];
                medInstruction.instruction = [oldMed.instruction printInstruction];
                newMed.medicationInstruction = medInstruction;
            }
            if (oldMed.ingredients !=0 && [oldMed.ingredients count] > 0 ) {
                for (int j=0; j < [oldMed.ingredients count]; j++) {
                    MMLIngredients *newIngredient = [[CoreDataManager coreDataManager] newIngredients];
                    newIngredient.ingredient = [oldMed.ingredients objectAtIndex:j];
                    [newMed addIngredientsArrayObject:newIngredient];
                }
            }
            newMed.image = UIImagePNGRepresentation(oldMed.image);
            MMLConceptProperty *newConceptProperty = [[CoreDataManager coreDataManager] newConceptProperty];
            newConceptProperty.rxcui = [oldMed.conceptProperty rxcui];
            newConceptProperty.name = [oldMed.conceptProperty name];
            newConceptProperty.synonym = [oldMed.conceptProperty synonym];
            newConceptProperty.termtype = [oldMed.conceptProperty termtype];
            newConceptProperty.language = [oldMed.conceptProperty language];
            newConceptProperty.suppressflag = [oldMed.conceptProperty suppressflag];
            newConceptProperty.umlsCUI = [oldMed.conceptProperty UMLSCUI];
            newMed.conceptProperty = newConceptProperty;
            
            MMLCCDInfo *newCCDInfo = [[CoreDataManager coreDataManager] newCCDInfo];
            newCCDInfo.isClinicalDrug = [NSNumber numberWithBool:[oldMed.ccdInfo isClinicalDrug]];
            newCCDInfo.codeDisplayName = [oldMed.ccdInfo codeDisplayName];
            newCCDInfo.codeDisplayNameRxCUI = [oldMed.ccdInfo codeDisplayNameRxCUI];
            newCCDInfo.translationDisplayName = [oldMed.ccdInfo translationDisplayName];
            newCCDInfo.ingredientName = [oldMed.ccdInfo ingredientName];
            newCCDInfo.translationDisplayNameRxCUI = [oldMed.ccdInfo translationDisplayNameRxCUI];
            newCCDInfo.brandName = [oldMed.ccdInfo brandName];
            newMed.ccdInfo = newCCDInfo;
            newMed.creationID = [NSNumber numberWithInt:oldMed.creationID ];
            [discontinuedMedicationList addMedicationListObject:newMed];
        }
        cperson.discontinuedMedicationList = discontinuedMedicationList;
        [[CoreDataManager coreDataManager]saveContext];
        return YES;
    }
    return YES;
}
@end
