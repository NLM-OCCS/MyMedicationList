//
//  DisplayNameService.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <dispatch/dispatch.h>
#import "DisplayNameService.h"
#include "StorageDirectory.h"
#include <sys/xattr.h>

@interface DisplayNameService ()

@property (assign,nonatomic) BOOL isUpdating;
@property (assign,nonatomic) NSUInteger currentDatabaseIndex;
@property (readonly,nonatomic) NSUInteger backupDatabaseIndex;

@end


@implementation DisplayNameService
@synthesize isUpdating=_isUpdating;
@synthesize currentDatabaseIndex = _currentDatabaseIndex;
@synthesize backupDatabaseIndex = _backupDatabaseIndex;




static DisplayNameService *instance = nil;

static RxNormWebDataObject *webDataObject = nil;

static NSOperationQueue *queue = nil;

static NSMutableArray *drugNames = nil;
static sqlite3_stmt *addStmt = nil;
static sqlite3_stmt *truncateStmt=nil;
static sqlite3_stmt *invalidStmt = nil;

static NSString *databaseNames[2] = {@"drugNames",@"drugNamesBackup"};
static sqlite3 *database = NULL;
static sqlite3 *databaseBackup = NULL;
static sqlite3 *databases[2];
static BOOL databaseReady = NO;
static BOOL databaseBackupReady = NO;
static BOOL databaseState[2];
static BOOL finishUpdateSoon = NO;      // If we are close to finishing the update do not let the user cancel. This might leave the
                                        // without a database to use


+ (BOOL)openDatabaseWithIndex:(NSUInteger)dbIndex atPath:(NSString *)writableDBPath
{
    NSLog(@"openDatabase:atPath");
    // Open the database. The database was prepared outside the application.
    NSLog(@"Opening the database");
    if (sqlite3_open([writableDBPath UTF8String], &databases[dbIndex]) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(databases[dbIndex]);
        databases[dbIndex] = NULL;
        NSLog(@"Failed to open database with message '%s'.", sqlite3_errmsg(databases[dbIndex]));
        // Additional error handling, as appropriate...
        return NO;
    }
    else
        return YES;
    
}

+ (void)initializeDatabase:(NSUInteger)databaseIndex
{
    
    NSLog(@"initializeDatabase:");
    BOOL success = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    /* Database was stored in Documents directory because it is safe during updates and restores. 
       This is not the best solution because you have allowed file sharing in the app you
       can see this database in iTunes which makes the app vulnerable to user error i.e. the
       user deletes this database which is used to search for display names
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",databaseNames[currentDatabaseIndex]]];
    */
    
    /* Technical note QA1699 says that the Library directory is not visible to users
       but is also safe during updates and restores. Using a "Private Documents" subdirectory is 
       helpful for preventing name collisions.
    */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",databaseNames[databaseIndex]]];
    // TODO: When finished testing with NSDocumentDirectory in storageDirectory() you can delete the above and uncomment the line below
    //NSString *writableDBPath = [storageDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",databaseNames[databaseIndex]]];
    
    // The writable database does not exist, so copy the default to the appropriate location.
    if ([fileManager fileExistsAtPath:writableDBPath] == NO) {
        NSLog(@"Copying database to writable location");
    
        NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:databaseNames[databaseIndex] ofType:@"db"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if (!success) {
            NSLog(@"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            databaseReady = NO;
        }
        const char* filePath = [writableDBPath fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        if (result == 0) {
            NSLog (@"Set the backup flag\n");
        }

    }
    

    NSLog(@"Database Being referenced: %@",databaseNames[databaseIndex]);
    databaseState[databaseIndex] = [DisplayNameService openDatabaseWithIndex:databaseIndex atPath:writableDBPath];

}

+ (DisplayNameService *)displayNameService
{
    NSLog(@"displayNameService");
	if(instance == nil)
	{

        instance = [[super allocWithZone:NULL] init];
        
        databases[0] = database;
        databases[1] = databaseBackup;
        
        databaseState[0] = databaseReady;
        databaseState[1] = databaseBackupReady;
        
        instance.currentDatabaseIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"MMLCurrentDatabaseInt"];
        [DisplayNameService initializeDatabase:instance.currentDatabaseIndex];
        
        NSLog(@"instance.currentDatabaseIndex = %d",instance.currentDatabaseIndex);
        NSLog(@"database name = %@",databaseNames[instance.currentDatabaseIndex]);

        instance.isUpdating = NO;
        
        webDataObject = [RxNormWebDataObject webDataObject];
        
        [[NSNotificationCenter defaultCenter] addObserver:instance 
                                                 selector:@selector(finishedDownloadingDisplayNames:) 
                                                     name:MMLDisplayNamesFinishedDownloadingNotification 
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:instance 
                                                 selector:@selector(failedDownloadingDisplayNames:) 
                                                     name:MMLDisplayNamesUpdatingFailedNotification 
                                                   object:nil];
        sqlite3_stmt *statementChk;
        sqlite3_prepare_v2(databases[instance.currentDatabaseIndex], "SELECT name FROM sqlite_master WHERE type='table' AND name='invalidStrings';", -1, &statementChk, nil);
        
        bool boo = FALSE;
        
        if (sqlite3_step(statementChk) == SQLITE_ROW) {
            boo = TRUE;
        } else {
            // create the table
            sqlite3_stmt *createTableStmt;
            sqlite3_prepare_v2(databases[instance.currentDatabaseIndex], "create table invalidStrings AS select name from drugs where 1=0;", -1, &createTableStmt, nil);
            if (sqlite3_exec(databases[instance.currentDatabaseIndex], "CREATE TABLE invalidStrings AS select name from drugs where 1=0;", NULL, NULL, NULL)) {
                NSLog(@"Error Received!!!");
            
            }
            
            //     sqlite3_step(createTableStmt);
            sqlite3_finalize(createTableStmt); // free statement
        }
        
        drugNames = [[NSMutableArray alloc] init];
	}
	return instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	return [[self displayNameService] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax;
}

- (void)sharedRelease
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(addStmt != NULL)
        sqlite3_finalize(addStmt);
    if(database != NULL)
        sqlite3_close(database);
    [drugNames release];
    drugNames = nil;
    [instance release];
    instance = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:MMLDisplayNamesFinishedDownloadingNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:MMLDisplayNamesUpdatingFailedNotification 
                                                  object:nil];    
}

- (oneway void)release
{
	NSLog(@"DisplayNameService release");
    if (drugNames == nil) {
        [drugNames release];
        drugNames = nil;
    }
}

- (id)autorelease
{
	return self;
}

- (void)setCurrentDatabaseIndex:(NSUInteger)currentDatabaseIndex
{
    NSLog(@"setCurrentDatabaseIndex:");
    _currentDatabaseIndex = currentDatabaseIndex;
    // The backup database index is always opposite of the currentDatabaseIndex
    _backupDatabaseIndex = (_currentDatabaseIndex == 0) ? 1 : 0;
}

+ (BOOL)needsUpdate
{
    NSLog(@"needsUpdate");
    NSDate *lastUpdateDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"MMLLastUpdateDate"];
    
    // The user has never updated so we should do that now
    if(lastUpdateDate == nil)
        return YES;
    // Calculate if the user needs to update
    else
    {
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
        
        NSDate *todayDate = [NSDate date];
        
        NSDateComponents *lastUpdate = [gregorian components:unitFlags fromDate:lastUpdateDate];
        NSDateComponents *today = [gregorian components:unitFlags fromDate:todayDate];
        if(abs(lastUpdate.month-today.month) >= 1)
            return YES;
        else
        {
            if(lastUpdate.year != today.year)
                return YES;
            else 
                return NO;
        }
    }
}

// Update of display names is blocking for too long, cancel the operation
- (void)cancelUpdate
{
    // We are approaching a critical section in the update code so we give
    // an extra second to finish the work. This is still not absolute protection
    // but the methods that need to finish are very fast in comparision to the
    // a possibly laggy download of data. The extra second should be more than
    // enough time to finish.
    if(!finishUpdateSoon)
    {
        // Dispatch queues are garaunteed to finish there work even when released
        dispatch_queue_t extraTimeQueue = dispatch_queue_create("gov.nlm.nih.mml.extraTime", NULL);        
        
        // Sleep for 1 second in the background to give the method a chance to finish
        dispatch_async(extraTimeQueue, ^(void) {
            sleep(1);
            // If we still haven't finished processing the method then we cancel
            dispatch_async(dispatch_get_main_queue(), ^{
                [queue cancelAllOperations];
            });
        });    

        dispatch_release(extraTimeQueue);
    }
    else
        [queue cancelAllOperations];
    
    finishUpdateSoon = NO;
}

- (void)resetBackupDatabase
{
    NSLog(@"resetDatabase");
    
    // Initialize the backup database
    [DisplayNameService initializeDatabase:self.backupDatabaseIndex];
    
    NSString *sqlStatement = [NSString stringWithFormat:@"delete from drugs"];
    
    if (databaseState[self.backupDatabaseIndex]) {
        if (sqlite3_exec(databases[self.backupDatabaseIndex], [sqlStatement UTF8String], NULL, NULL, NULL)) {
            NSLog(@"Error Received!!!");
        }
    }
}

- (void) addInvalidString:(NSString *) invalidString {
    sqlite3_stmt *statementChk;
    sqlite3_prepare_v2(database, "SELECT name FROM sqlite_master WHERE type='table' AND name='invalidStrings';", -1, &statementChk, nil);
    
    bool boo = FALSE;
    
    if (sqlite3_step(statementChk) == SQLITE_ROW) {
        boo = TRUE;
    } else {
        // create the table
        sqlite3_stmt *createTableStmt;
        sqlite3_prepare_v2(database, "create table invalidStrings AS select name from drugs where 1=0;", -1, &createTableStmt, nil);
        if (sqlite3_exec(databases[self.currentDatabaseIndex], "CREATE TABLE invalidStrings AS select name from drugs where 1=0;", NULL, NULL, NULL)) {
            NSLog(@"Error Received!!!'%s'", sqlite3_errmsg(databases[self.currentDatabaseIndex]));
        }

   //     sqlite3_step(createTableStmt);
        sqlite3_finalize(createTableStmt); // free statement
    }
    
    if (sqlite3_exec(databases[self.currentDatabaseIndex], [@"begin transaction" UTF8String], NULL, NULL, NULL)) {
        NSLog(@"Error Received!!!");
    }
    
    if(invalidStmt == nil) {
        const char *sql = "insert into invalidStrings(name) values(?)";
        if(sqlite3_prepare_v2(databases[self.currentDatabaseIndex], sql, -1, &invalidStmt, NULL) != SQLITE_OK)
            NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databases[0]));
    }
    sqlite3_bind_text(invalidStmt, 1, [invalidString UTF8String], -1, SQLITE_TRANSIENT);
    if(SQLITE_DONE != sqlite3_step(invalidStmt))
        NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databases[self.currentDatabaseIndex]));
    
    sqlite3_clear_bindings(invalidStmt);
    sqlite3_reset(invalidStmt);
    if (sqlite3_exec(databases[self.currentDatabaseIndex], [@"end transaction" UTF8String], NULL, NULL, NULL)) {
        NSLog(@"Error Received!!!");
    }


}
- (void)addDrugNames:(NSArray *)drugNames
{
    NSLog(@"addDrugNames:");	
    
    if(queue == nil)
        queue = [[NSOperationQueue alloc] init];

    // Close the backup database...
    sqlite3_close(databases[self.backupDatabaseIndex]);

    // copy the backup database db file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",databaseNames[self.backupDatabaseIndex]]];
    // TODO: When finished testing with NSDocumentDirectory in storageDirectory() you can delete the above and uncomment the line below
    //NSString *writableDBPath = [storageDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",databaseNames[databaseIndex]]];
    
    // The writable database does not exist, so copy the default to the appropriate location.
   
    NSLog(@"Copying database to writable location");
        
    NSString *defaultDBPath = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",databaseNames[self.currentDatabaseIndex]]];
    
    if ([fileManager fileExistsAtPath:writableDBPath] == YES) {
        if ([fileManager removeItemAtPath:writableDBPath error:&error] != YES) {
             NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
    }
    
    BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
            NSLog(@"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            databaseReady = NO;
    }
    const char* filePath = [writableDBPath fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    if (result == 0) {
        NSLog (@"Set the backup flag\n");
    }

    // open the backup database db file
    if (sqlite3_open([writableDBPath UTF8String], &databases[self.backupDatabaseIndex]) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(databases[self.backupDatabaseIndex]);
        databases[self.backupDatabaseIndex] = NULL;
        NSLog(@"Failed to open database with message '%s'.", sqlite3_errmsg(databases[self.backupDatabaseIndex]));
        // Additional error handling, as appropriate...
        
    }
       // Prevents retain cycle. Eventhough we are dealing with a singleton it is good memory management
    __block DisplayNameService *blockSelf = self;
    // truncate the drugs tables
    const char *truncateSql = "DELETE FROM drugs";
    if(sqlite3_prepare_v2(databases[blockSelf.backupDatabaseIndex], truncateSql, -1, &truncateStmt, NULL) != SQLITE_OK)
        NSLog(@"Error while truncate statement. '%s'", sqlite3_errmsg(databases[blockSelf.backupDatabaseIndex]));
    if(SQLITE_DONE != sqlite3_step(truncateStmt))
        NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databases[blockSelf.backupDatabaseIndex]));
    [queue addOperationWithBlock:^{
        
        if (sqlite3_exec(databases[blockSelf.backupDatabaseIndex], [@"begin transaction" UTF8String], NULL, NULL, NULL)) {
            NSLog(@"Error Received!!!");
        
        }
        
        if(addStmt == nil) {
            const char *sql = "insert into drugs(name) values(?)";
            if(sqlite3_prepare_v2(databases[blockSelf.backupDatabaseIndex], sql, -1, &addStmt, NULL) != SQLITE_OK)
                NSLog(@"Error while creating add statement. '%s'", sqlite3_errmsg(databases[blockSelf.backupDatabaseIndex]));
        }
        
        int i = 0;
        for(NSString *drugName in drugNames)
        {
            i++;
            if(i%1002 == 0)
            {
                NSLog(@"Adding drug with name: %@",drugName);
                i = 0;
            }
   
            sqlite3_bind_text(addStmt, 1, [drugName UTF8String], -1, SQLITE_TRANSIENT);
            if(SQLITE_DONE != sqlite3_step(addStmt))
                NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(databases[blockSelf.backupDatabaseIndex]));
            
            sqlite3_clear_bindings(addStmt);
            sqlite3_reset(addStmt);
        }
        
        if (sqlite3_exec(databases[blockSelf.backupDatabaseIndex], [@"end transaction" UTF8String], NULL, NULL, NULL)) {
            NSLog(@"Error Received!!!");
        
        }
        
        
        // Now the update is over so just close the first main database and then copy the original and open the database
        
        // Make the database pointer, point to the newly updated databaseBackup pointer
        NSLog(@"Updated databaseBackup pointer: %p",databases[blockSelf.backupDatabaseIndex]);
        NSLog(@"current database pointer: %p",databases[blockSelf.currentDatabaseIndex]);        
        
        finishUpdateSoon = YES;
        // Update the integer to refer to the appropriately updated database
        
        //int dbIndex = blockSelf.currentDatabaseIndex;
       // blockSelf.currentDatabaseIndex = (blockSelf.currentDatabaseIndex == 0) ? 1 : 0;
        NSLog(@"current database pointer: %p",databases[blockSelf.currentDatabaseIndex]); 
        
        // Shutdown the initial database since we are no longer using it
        // Note: backupDatabaseIndex now has the value currentDatabaseIndex used to have
        // so we are actually shutting down the correct database
        sqlite3_close(databases[self.currentDatabaseIndex]);
        
       NSString *writableDBPath1 = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",databaseNames[blockSelf.currentDatabaseIndex]]];
        // TODO: When finished testing with NSDocumentDirectory in storageDirectory() you can delete the above and uncomment the line below
        //NSString *writableDBPath = [storageDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",databaseNames[databaseIndex]]];
        
        // The writable database does not exist, so copy the default to the appropriate location.
        
        NSLog(@"Copying database to writable location");
        
        NSString *defaultDBPath1 = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",databaseNames[blockSelf.backupDatabaseIndex]]];
        NSError *error1=nil;
        
        if ([fileManager fileExistsAtPath:writableDBPath1] == YES) {
            if ([fileManager removeItemAtPath:writableDBPath1 error:&error1] != YES) {
                NSLog(@"Unable to delete file: %@", [error localizedDescription]);
            }
        }
        BOOL success1 = [fileManager copyItemAtPath:defaultDBPath1 toPath:writableDBPath1 error:&error1];
        if (!success1) {
            NSLog(@"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            databaseReady = NO;
        }
        const char* filePath = [writableDBPath1 fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        if (result == 0) {
            NSLog (@"Set the backup flag\n");
        }

        // open the backup database db file
        if (sqlite3_open([writableDBPath UTF8String], &databases[self.currentDatabaseIndex]) != SQLITE_OK) {
            // Even though the open failed, call close to properly clean up resources.
            sqlite3_close(databases[self.currentDatabaseIndex]);
            databases[self.currentDatabaseIndex] = NULL;
            NSLog(@"Failed to open database with message '%s'.", sqlite3_errmsg(databases[self.currentDatabaseIndex]));
            // Additional error handling, as appropriate...
            
        }
       // databases[dbIndex] = NULL;
     //   databaseState[dbIndex] = NO;
        
        NSLog(@"current databaseBackup pointer: %p", (databases[blockSelf.currentDatabaseIndex] == NULL) ? 0 : databases[blockSelf.currentDatabaseIndex]); 
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"MMLLastUpdateDate"];
        [[NSUserDefaults standardUserDefaults] setInteger:blockSelf.currentDatabaseIndex forKey:@"MMLCurrentDatabaseInt"];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSLog(@"Sending out the following notification: %@",MMLFinishedUpdatingDisplayNamesNotification);
            NSNotification *notification = [NSNotification notificationWithName:MMLFinishedUpdatingDisplayNamesNotification 
                                                                         object:self 
                                                                       userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            blockSelf.isUpdating = NO;
            finishUpdateSoon = NO;
        }];
    }];

}


static int retrieveNames(void *context, int count, char **values, char **columns)
{

    [(NSMutableArray *)context addObject:[NSString stringWithUTF8String:values[0]]];    
    return SQLITE_OK;
}

- (NSMutableArray *)displayNamesForSearchString:(NSString *)searchString
{
    NSLog(@"current databaseBackup pointer: %p", (databases[self.currentDatabaseIndex] == NULL) ? 0 : databases[self.currentDatabaseIndex]); 
    NSLog(@"Updated databaseBackup pointer: %p",databases[self.backupDatabaseIndex]);
    NSLog(@"current database pointer: %p",databases[self.currentDatabaseIndex]);  
    NSString *sqlStatement = [NSString stringWithFormat:@"select name from (select \'1\' num, name from drugs where name like \'%@%%\' and name not in (select name from invalidStrings) union select  \'2\', name from drugs where name like \'%%%@%%\' and name not like \'%@%%\' and name not in (select name from invalidStrings) ) order by num ",searchString,searchString,searchString];
	[drugNames removeAllObjects];
    
    if (databaseState[self.currentDatabaseIndex]) {
        char *error;
        if (sqlite3_exec(databases[self.currentDatabaseIndex], [sqlStatement UTF8String], retrieveNames, drugNames, &error)) {
            NSLog(@"Failed to create writable database file with message '%s'.", error);
            sqlite3_free(error);
        }
    }
    NSLog(@"Drugnames %@",drugNames);
	return drugNames;    
    
}


static int retrieveAll(void *context, int count, char **values, char **columns)
{
    
    NSLog(@"Name = %@",[NSString stringWithUTF8String:values[0]]);
    return SQLITE_OK;
}

- (void)printDatabase
{
    NSLog(@"printDatabase");
    NSString *sqlStatement = [NSString stringWithFormat:@"select * from drugs"];
    
    if (databaseReady) {
        if(SQLITE_OK != sqlite3_exec(database, [sqlStatement UTF8String], retrieveAll, NULL, NULL))
            NSLog(@"There was a problem printing the database...");
    }
    else
        NSLog(@"The database is not ready for access");

}

- (void)failedDownloadingDisplayNames:(NSNotification *)notification
{
    NSLog(@"failedDownloadingDisplayNames:");
    self.isUpdating = NO;

    if(databaseState[self.backupDatabaseIndex])
    {
        // Shutdown the backup database since we are no longer using it
        sqlite3_close(databases[self.backupDatabaseIndex]);
        databases[self.backupDatabaseIndex] = NULL;
        databaseState[self.backupDatabaseIndex] = NO;
    }
}

- (void)finishedDownloadingDisplayNames:(NSNotification *)notification
{
    NSLog(@"finishedDownloadingDisplayNames:");
    NSDictionary *displayTermsList = [notification userInfo];
    NSArray *terms = [displayTermsList objectForKey:@"term"];
    
    [self addDrugNames:terms];
}

- (void)updateDisplayNames
{
    NSLog(@"updateDisplayNames");
    
    // Get the backup database ready for writing the new terms
    [self resetBackupDatabase];
    
    // If the backup database could not be properly initialized then there is no further work to be done
    if(!databaseState[self.backupDatabaseIndex])
        return;
            
    self.isUpdating = YES;
    
    // Will post a notification to this object by calling finishedDownloadingDisplayNames:
    [webDataObject getDisplayNames];

}

@end
