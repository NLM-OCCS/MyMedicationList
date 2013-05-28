//
//  MedicationAmount+CCDFunctionality.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MedicationAmount.h"

@interface MedicationAmount (CCDFunctionality)

+ (MedicationAmount *)amountForCCDQuantityString:(NSString *)quantityString typeString:(NSString *)typeString;

- (NSString *)amountStringForCCD;
- (NSString *)amountQuantityStringForCCD;
- (NSString *)amountTypeStringForCCD;
- (BOOL)hasUnitStringForCCD;
- (NSString *)NCIThesaurusCodeForAmountType;

@end
