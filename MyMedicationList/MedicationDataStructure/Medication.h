//
//  Medication.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import <Foundation/Foundation.h>
#import "Date.h"
#import "MedicationAmount.h"
#import "MedicationFrequency.h"
#include "MedicationInstruction.h"
#include "ConceptProperty.h"
#include "CCDInfo.h"

//@class Date,MedicationAmount,MedicationFrequency,MedicationInstruction,ConceptProperty,CCDInfo;

@interface Medication : NSObject<NSCoding,NSMutableCopying>{
  
}

@property (retain,nonatomic) Date *startDate;
@property (retain,nonatomic) Date *stopDate;
@property (retain,nonatomic) MedicationAmount *amount;
@property (retain,nonatomic) MedicationFrequency *frequency;
@property (retain,nonatomic) MedicationInstruction *instruction;
@property (retain,nonatomic) UIImage *image;
@property (retain,nonatomic) ConceptProperty *conceptProperty;
@property (retain,nonatomic) NSArray *ingredients;
@property (retain,nonatomic) CCDInfo *ccdInfo;
@property (assign,nonatomic) int creationID;
@property (readonly,nonatomic) NSString *name; // Returns the synonym or the name from the concept property as appropriate
@property (assign,nonatomic) unsigned int repeats;
@property (assign,nonatomic) unsigned int quantity;
@property (retain,nonatomic) Date *prescribeDate;
@property (copy,nonatomic) NSString *telephoneNumber;
@property (copy,nonatomic) NSString *prescriberFirstName;
@property (copy,nonatomic) NSString *prescriberLastName;
@property (copy,nonatomic) NSString *prescriberSuffix;
- (id)init;
- (id)initWithMedication:(Medication *)medication;

- (void)printMedication;

- (id)mutableCopy;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
