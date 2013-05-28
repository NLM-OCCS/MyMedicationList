//
//  ProfileManager.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "ProfileManager.h"
#import "StorageDirectory.h"
#import "MedicationContainer.h"
#import <sys/xattr.h>

@implementation ProfileManager

static ProfileManager *instance = nil;
static NSMutableArray *profileArchiveNames = nil;
static NSMutableArray *profiles = nil;

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)fileName
{
    const char* filePath = [fileName fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

+ (ProfileManager *)profileManager
{
	if(instance == nil)
	{
		profileArchiveNames = [[NSMutableArray alloc] init];
		profiles = [[NSMutableArray alloc] init];
		instance = [[super allocWithZone:NULL] init];

	}
	return instance;
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

- (oneway void)release
{
	NSLog(@"We will do nothing");
}

- (id)autorelease
{
	return self;
}

- (void)loadProfileNames
{
	
	NSString *fullArchiveName = @"ProfileNames.archive";
	NSString *profileNamesArchivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
    
	NSMutableArray *tempProfileNameArray = [NSKeyedUnarchiver unarchiveObjectWithFile:profileNamesArchivePath];
	if ((tempProfileNameArray == nil)||([tempProfileNameArray count] == 0))
		printf("No Profiles have been saved yet so the loaded profile name array is empty.\n");
	else 
		[profileArchiveNames addObjectsFromArray:tempProfileNameArray];
    	
}

- (void)saveProfileNames
{
	
    NSString *fullArchiveName = [NSString stringWithFormat:@"ProfileNames.archive"];
    NSString *profileNamesArchivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
    NSLog(@"Saving Profile Names at archive path: %@",profileNamesArchivePath);
    [NSKeyedArchiver archiveRootObject:profileArchiveNames toFile:profileNamesArchivePath];	
	const char* filePath = [profileNamesArchivePath fileSystemRepresentation];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"backup"] !=nil ) {
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    if (result == 0) {
        NSLog (@"Set the backup flag\n");
    }
    } else {
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 0;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        if (result == 0) {
            NSLog (@"Set the backup flag\n");
        }
    }
}

- (NSString *)createProfileName
{
    NSString *profileName = nil;
	if([profileArchiveNames count] == 0)
		profileName = [NSString stringWithFormat:@"Person0"];
	else 
	{
		NSString *personIntegerString = [[profileArchiveNames lastObject] substringFromIndex:[@"Person" length]];
		profileName = [NSString stringWithFormat:@"Person%d",([personIntegerString intValue]+1)];
	}

    NSLog(@"profileName created: %@",profileName);
    return profileName;
}

- (BOOL)doesPersonExist:(PersonData *)person
{
 
    for(NSString *profileArchiveName in profileArchiveNames)
	{
		NSString *fullArchiveName = [NSString stringWithFormat:@"%@.archive",profileArchiveName];
		NSString *profileNameArchivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
		NSLog(@"profile at archive path: %@",profileNameArchivePath);
		PersonData *person1 = [NSKeyedUnarchiver unarchiveObjectWithFile:profileNameArchivePath];
        NSLog(@"Profile id %@",person1.userID);

        if([person.userID isEqualToString:person1.userID])
            return YES;
	}
    NSLog(@"Profile id %@",person.userID);
    for(PersonData *profile in profiles)
    {
        if([person.userID isEqualToString:profile.userID])
            return YES;
    }
    
    return NO;
}

-(NSString *) personArchiveNameForUserId:(NSString *)userID {
    for(NSString *profileArchiveName in profileArchiveNames)
	{
    NSString *fullArchiveName = [NSString stringWithFormat:@"%@.archive",profileArchiveName];
    NSString *profileNameArchivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
    PersonData *person1 = [NSKeyedUnarchiver unarchiveObjectWithFile:profileNameArchivePath];
    if([userID isEqualToString:person1.userID])
        return profileArchiveName;
    }
    return @"";
}
- (PersonData *)personForUserID:(NSString *)userID
{
    
    for(NSString *profileArchiveName in profileArchiveNames)
	{
		NSString *fullArchiveName = [NSString stringWithFormat:@"%@.archive",profileArchiveName];
		NSString *profileNameArchivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
		PersonData *person1 = [NSKeyedUnarchiver unarchiveObjectWithFile:profileNameArchivePath];
        if([userID isEqualToString:person1.userID])
            return person1;
	}
    
    for(PersonData *profile in profiles)
    {
        if([userID isEqualToString:profile.userID])
            return profile;
    }
    
    return nil;
    
}

- (PersonData *)addPersonWithFirstName:(NSString *)firstName LastName:(NSString *)lastName Gender:(Gender)gender
{
	
	NSString *newProfileName = [self createProfileName];
	PersonData *person = [[[PersonData alloc] initWithArchiveName:newProfileName] autorelease];
	person.firstName = firstName;
	person.lastName = lastName;
	person.gender = gender;
	
	[profileArchiveNames addObject:newProfileName];
    [self savePersonData:person withName:newProfileName];
	//SL CHANG[profiles addObject:person];
	
	return person;
}
- (PersonData *)addPersonWithFirstName:(NSString *)firstName LastName:(NSString *)lastName Gender:(Gender)gender DOB:(Date *)date
{
	
	NSString *newProfileName = [self createProfileName];
	PersonData *person = [[[PersonData alloc] initWithArchiveName:newProfileName] autorelease];
	person.firstName = firstName;
	person.lastName = lastName;
	person.gender = gender;
    person.dateOfBirth = date;
	
	[profileArchiveNames addObject:newProfileName];
    [self savePersonData:person withName:newProfileName];
	//SL CHANG[profiles addObject:person];
	return person;
}
- (void)addPerson:(PersonData *)person
{
    if(![self doesPersonExist:person])
    {
        NSString *newProfileName = [self createProfileName];
        person.archiveName = newProfileName;
        
        [profileArchiveNames addObject:newProfileName];
       // [profiles addObject:person];
        [self savePersonData:person withName:newProfileName];

    }
    else
    {
        

        PersonData *existingPerson = [self personForUserID:person.userID];
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        NSLog(@"Printing personWithFirstName");
        [existingPerson printPerson];
        // Replace the medications /////////////////////////////////////////
        [existingPerson.currentMedicationList removeAllObjects];
        [existingPerson.discontinuedMedicationList removeAllObjects];    
        
        for (MedicationContainer *medContainer in person.currentMedicationList)
            if(medContainer.medication != nil)
                [existingPerson.currentMedicationList addObject:[medContainer mutableCopy]];
        
        for (MedicationContainer *medContainer in person.discontinuedMedicationList)
            if(medContainer.medication != nil)
                [existingPerson.discontinuedMedicationList addObject:[medContainer mutableCopy]];
        
        
        // Add the prescriptions /////////////////////////////////////////
        for (MedicationContainer *medContainer in person.currentMedicationList) {
            if((medContainer.medication == nil)&&(medContainer.prescription != nil))
                [existingPerson.currentMedicationList addObject:[[medContainer mutableCopy] autorelease]];
        }
        existingPerson.archiveName = person.archiveName;
        
        existingPerson.personImage = person.personImage;
        
                
        existingPerson.phoneNumber = person.phoneNumber;
        existingPerson.streetAddress = person.streetAddress;
        existingPerson.streetAddress2 =person.streetAddress2;
        existingPerson.city = person.city;
        existingPerson.state = person.state;
        existingPerson.zip = person.zip;
        
        existingPerson.carrier = person.carrier;
        existingPerson.groupNumber = person.groupNumber;
        existingPerson.memberNumber = person.memberNumber;
        existingPerson.rxIN = person.rxIN;
        existingPerson.rxPCN = person.rxPCN;
        existingPerson.rxGroup = person.rxGroup;
        existingPerson.cardImage = person.cardImage;
        existingPerson.backCardImage = person.backCardImage;
        
        existingPerson.carrier2 = person.carrier2;
        existingPerson.groupNumber2 = person.groupNumber2;
        existingPerson.memberNumber2 = person.memberNumber2;
        existingPerson.rxIN = person.rxIN2;
        existingPerson.rxPCN = person.rxPCN2;
        existingPerson.rxGroup2 = person.rxGroup2;
        existingPerson.cardImage2 = person.cardImage2;
        existingPerson.backCardImage2 = existingPerson.backCardImage2;
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        [self savePersonData:existingPerson withName:[self personArchiveNameForUserId:person.userID]];
        [existingPerson printPerson];
        [person printPerson];

    }
        [self saveProfileNames];

}



- (BOOL)deletePersonAtIndex:(NSUInteger)index;
{

	if(index >= [self profileArchiveNameCount])
    {
		NSLog(@"Invalid index, profile can not be deleted...");
        return NO;
    }
	else
    {

        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *errorPerson = nil;
        
        NSString *fullArchiveName = [NSString stringWithFormat:@"%@.archive",[self getProfileArchiveNameAtIndex:(NSUInteger)index]];
        
     //   [profileArchiveNames removeObjectAtIndex:index];
        
        index = 0;
                
   //     [profiles removeObjectAtIndex:index];
        
        // If the app crashes after deletion but before a chance to save there may be 
        // multiple instances of the same profile name because the file which contains
        // this names isn't saved even though we remove the associated file for the personData just below
      //  [self saveProfileNames];
        
        // Attempt to delete the physical file containing the user data
        if([fileManager removeItemAtPath:[storageDirectory() stringByAppendingPathComponent:fullArchiveName] error:&errorPerson])
            return YES;
        else
        {
            NSLog(@"Deleting the file failed. This may be because it does not exist");
            NSLog(@"Error: %@",[errorPerson localizedDescription]);

            return  NO;
        }
    }
}

- (NSMutableArray *)profiles
{
	return profiles;
}

- (NSUInteger) profileArchiveNameCount
{
    return [profileArchiveNames count];
}
- (NSUInteger)profileCount
{
	return [profiles count];
}
- (NSString *) getProfileArchiveNameAtIndex:(NSUInteger)index {
    if(([self profileArchiveNameCount] == 0)||(index >= [self profileArchiveNameCount]))
        return nil;
	else
		return [profileArchiveNames objectAtIndex:index];
}
- (PersonData *)profileAtIndex:(NSUInteger)index
{
	if(([self profileCount] == 0)||(index >= [self profileCount]))
		return nil;
	else
		return [profiles objectAtIndex:index];
}

- (void)loadProfiles
{
	[self loadProfileNames];
    NSLog(@"loadProfiles");
//    
//    NSString *fullArchiveName = nil;
//    NSString *profileNameArchivePath = nil;
//    
//	for(NSString *profileName in profileArchiveNames)
//	{
//		fullArchiveName = [NSString stringWithFormat:@"%@.archive",profileName];
//		profileNameArchivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
//		NSLog(@"Loading profile at archive path: %@",profileNameArchivePath);
//	
//		PersonData *person = [NSKeyedUnarchiver unarchiveObjectWithFile:profileNameArchivePath];
//		if(person != nil)
//		{
//			NSLog(@"The person loaded had the following Archive Name: %@",person.archiveName);
//			//[profiles addObject:person];
//		}
//	}
}

- (NSString *) getPersonNameByProfileName:(NSString *)personName {
    NSString *fullArchiveName = nil;
    NSString *profileNameArchivePath = nil;
    fullArchiveName = [NSString stringWithFormat:@"%@.archive",personName];
    profileNameArchivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
    NSLog(@"Loading profile at archive path: %@",profileNameArchivePath);
	
    PersonData *person = [NSKeyedUnarchiver unarchiveObjectWithFile:profileNameArchivePath];
    if(person != nil)
    {
        return [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName ];
    }
    return nil;
}

- (PersonData *) getPersonDataByProfileName:(NSString *)personName {
    NSString *fullArchiveName = nil;
    NSString *profileNameArchivePath = nil;
    fullArchiveName = [NSString stringWithFormat:@"%@.archive",personName];
    profileNameArchivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
    NSLog(@"Loading profile at archive path: %@",profileNameArchivePath);
	
    PersonData *person = [NSKeyedUnarchiver unarchiveObjectWithFile:profileNameArchivePath];
    if(person != nil)
    {
        return person;
    }
    return nil;
}
- (UIImage *) getPersonImageByProfileName:(NSString *)personName {
    NSString *fullArchiveName = nil;
    NSString *profileNameArchivePath = nil;
    fullArchiveName = [NSString stringWithFormat:@"%@.archive",personName];
    profileNameArchivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
    NSLog(@"Loading profile at archive path: %@",profileNameArchivePath);
	
    PersonData *person = [NSKeyedUnarchiver unarchiveObjectWithFile:profileNameArchivePath];
    if(person != nil)
    {
        return [person personImage];
    }
    return nil;
}
- (BOOL) savePersonData:(PersonData *) personData withName:(NSString *)personName {
    BOOL archived = NO;	
    NSString *fullArchiveName = [NSString stringWithFormat:@"%@.archive",personName];
    NSString *profileNameArchivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
    NSLog(@"Saving profile at archive path: %@",profileNameArchivePath);
    archived = [NSKeyedArchiver archiveRootObject:personData toFile:profileNameArchivePath];
    const char* filePath = [profileNameArchivePath fileSystemRepresentation];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"backup"] !=nil ) {
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        if (result == 0) {
            NSLog (@"Set the backup flag\n");
        }
    } else {
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 0;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        if (result == 0) {
            NSLog (@"Set the backup flag\n");
        }
        
    }
    return archived;
    
}
- (BOOL)saveProfiles
{
    NSLog(@"About to save some profiles...");
    NSLog(@"Profile Count: %d",[self profileCount]);
	[self saveProfileNames];
    NSLog(@"saveProfiles");
    
	BOOL archived = NO;	
	for(PersonData *profile in profiles)
	{
		NSString *fullArchiveName = [NSString stringWithFormat:@"%@.archive",profile.archiveName];
		NSString *profileNameArchivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
		NSLog(@"Saving profile at archive path: %@",profileNameArchivePath);
		archived = [NSKeyedArchiver archiveRootObject:profile toFile:profileNameArchivePath];
        const char* filePath = [profileNameArchivePath fileSystemRepresentation];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults valueForKey:@"backup"] !=nil ) {
            const char* attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 1;
        
            int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
            if (result == 0) {
                NSLog (@"Set the backup flag\n");
            }
        } else {
            const char* attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 0;
            
            int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
            if (result == 0) {
                NSLog (@"Set the backup flag\n");
            }

        }

	}
	
	return archived;
}

-(void) removeProfileObjects {
    [profiles removeAllObjects];
    [profileArchiveNames removeAllObjects];
}
@end
