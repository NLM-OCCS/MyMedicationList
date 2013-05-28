//
//  PersonData.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import "Date.h"
#import "PersonDataEnums.h"

@class MedicationList;

@interface PersonData : NSObject<NSCoding>{

}

@property (nonatomic,copy) NSString *archiveName;
@property (nonatomic,readonly) NSString *userID;
@property (nonatomic,copy) NSString *firstName;
@property (nonatomic,copy) NSString *lastName;
@property (nonatomic,assign) Gender gender;
@property (nonatomic,copy) UIImage *personImage;

@property (nonatomic,readonly) MedicationList *currentMedicationList;
@property (nonatomic,readonly) MedicationList *discontinuedMedicationList;

@property (nonatomic,retain) Date *dateOfBirth;
@property (nonatomic,copy) NSString *phoneNumber;
@property (nonatomic,copy) NSString *streetAddress;
@property (nonatomic,copy) NSString *streetAddress2;

@property (nonatomic,copy) NSString *city;
@property (nonatomic,copy) NSString *state;
@property (nonatomic,copy) NSString *zip;

@property (nonatomic,copy) NSString *carrier;
@property (nonatomic,copy) NSString *groupNumber;
@property (nonatomic,copy) NSString *memberNumber;
@property (nonatomic,copy) NSString *rxIN;
@property (nonatomic,copy) NSString *rxPCN;
@property (nonatomic,copy) NSString *rxGroup;
@property (nonatomic,retain) UIImage *cardImage;
@property (nonatomic,retain) UIImage *backCardImage;


@property (nonatomic,copy) NSString *carrier2;
@property (nonatomic,copy) NSString *groupNumber2;
@property (nonatomic,copy) NSString *memberNumber2;
@property (nonatomic,copy) NSString *rxIN2;
@property (nonatomic,copy) NSString *rxPCN2;
@property (nonatomic,copy) NSString *rxGroup2;
@property (nonatomic,retain) UIImage *cardImage2;
@property (nonatomic,retain) UIImage *backCardImage2;


- (id)init;
- (id)initWithArchiveName:(NSString *)archiveName;

- (NSString *)ccdString;
- (NSString *)ccdStringTableOnly;

// Returns the first ingredient in 'ingredients' that matches an ingredient 
// in the currentMedicationList. Returns nil if no match is found.
- (NSString *)duplicateIngredient:(NSArray *)ingredients;

- (void)printPerson;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
