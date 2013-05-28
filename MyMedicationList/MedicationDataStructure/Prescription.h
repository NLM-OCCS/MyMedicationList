//
//  Prescription.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//
#include "Medication.h"
@class Date;

@interface Prescription : Medication<NSCoding,NSMutableCopying>{
    
}



@property (assign,nonatomic) BOOL isOnMedList;

- (id)init;
- (id)initWithMedication:(Medication *)medication;

- (void)printMedication;

- (id)mutableCopy;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
