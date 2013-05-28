//
//  Medication+CCDFunctionality.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "Medication.h"

@interface Medication (CCDFunctionality)

+ (NSArray *)parseIngredientString:(NSString *)ingredientString;

@end
