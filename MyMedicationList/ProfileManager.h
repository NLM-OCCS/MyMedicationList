//
//  ProfileManager.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import "PersonData.h"

@interface ProfileManager : NSObject

+ (ProfileManager *)profileManager;

- (BOOL)doesPersonExist:(PersonData *)person;
- (PersonData *)addPersonWithFirstName:(NSString *)firstName LastName:(NSString *)lastName Gender:(Gender)gender;
- (void)addPerson:(PersonData *)person;

- (BOOL)deletePersonAtIndex:(NSUInteger)index;

- (NSUInteger)profileCount;

- (PersonData *)profileAtIndex:(NSUInteger)index;

- (void)loadProfiles;
- (BOOL)saveProfiles;
- (void) removeProfileObjects;
- (NSString *) getPersonNameByProfileName:(NSString *)personName;
- (PersonData *) getPersonDataByProfileName:(NSString *)personName;
- (UIImage *) getPersonImageByProfileName:(NSString *)personName;
- (BOOL) savePersonData:(PersonData *) personData withName:(NSString *)personName;
- (NSUInteger) profileArchiveNameCount;
- (NSString *) getProfileArchiveNameAtIndex:(NSUInteger)index;
- (PersonData *)addPersonWithFirstName:(NSString *)firstName LastName:(NSString *)lastName Gender:(Gender)gender DOB:(Date *)date;
-(NSString *) personArchiveNameForUserId:(NSString *)userID;
- (void)saveProfileNames;
@end
