//
//  MMLPersonData.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMLInsurance, MMLMedicationList;

@interface MMLPersonData : NSManagedObject

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSData * personImage;
@property (nonatomic, retain) NSDate * dateOfBirth;
@property (nonatomic, retain) NSString * phoneNumer;
@property (nonatomic, retain) NSString * streetAddress1;
@property (nonatomic, retain) NSString * streetAddress2;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) MMLInsurance *insurance;
@property (nonatomic, retain) MMLMedicationList *currentMedicationList;
@property (nonatomic, retain) MMLMedicationList *discontinuedMedicationList;
@property (nonatomic, retain) MMLInsurance *secondaryInsurance;

@end
