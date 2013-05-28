//
//  DisplayNameService.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import "RxNormWebDataObject.h"
#import "sqlite3.h"

static NSString *const MMLFinishedUpdatingDisplayNamesNotification = @"MMLFinishedUpdatingDisplayNamesNotification";

@interface DisplayNameService : NSObject {

}
@property (nonatomic,readonly) BOOL isUpdating;

// Get the singleton of this object
+ (DisplayNameService *)displayNameService;

// Checks if the database needs to be updated
+ (BOOL)needsUpdate;

// Update of display names is blocking for too long, cancel the operation
- (void)cancelUpdate;

// Download display names from Rx-Norm and load
- (void)updateDisplayNames;

// Get the display names containing the search string from the database
- (NSMutableArray *)displayNamesForSearchString:(NSString *)searchString;

// Print the all the display names in the database, this is for debugging purposes
- (void)printDatabase;

- (void)sharedRelease; // Use to release the shared object when the application is completely done with it

- (void) addInvalidString:(NSString *) str;
@end
