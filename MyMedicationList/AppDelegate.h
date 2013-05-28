//
//  AppDelegate.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "PersonData.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) UIWindow *window;

- (void)loadPasswordScreen;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
 - (NSString *)applicationDocumentsDirectory;
+ (void) excludeCoreDataCloudBackup:(BOOL) exclude;
- (BOOL) migrateToCoreData:(PersonData *)person ;
@end
