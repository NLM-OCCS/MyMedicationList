//
//  MedicationContainer.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>

@class Medication;
@class Prescription;

@interface MedicationContainer : NSObject<NSCoding,NSMutableCopying>{
    
}
@property (readonly,nonatomic) Medication *medication;
@property (readonly,nonatomic) Prescription *prescription;


- (id)init;
- (id)initWithMedication:(Medication*)medication;
- (id)initWithPrescription:(Prescription*)prescription;
- (id)initWithMedication:(Medication *)medication prescription:(Prescription *)prescription;

- (id)mutableCopy;

// NSCoding protocol methods, used for saving to disk
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
