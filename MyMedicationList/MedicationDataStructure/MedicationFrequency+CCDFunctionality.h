//
//  MedicationFrequency+CCDFunctionality.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "MedicationFrequency.h"

@interface MedicationFrequency (CCDFunctionality)

+ (MedicationFrequency *)frequencyForCCDFrequencyHourString:(NSString *)frequencyHourString;

- (NSString *)frequencyStringForCCD;
- (NSString *)hourFrequencyStringForCCD;

@end
