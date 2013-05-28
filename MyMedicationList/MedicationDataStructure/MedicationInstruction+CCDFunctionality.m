//
//  MedicationInstruction+CCDFunctionality.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MedicationInstruction+CCDFunctionality.h"

@implementation MedicationInstruction (CCDFunctionality)

- (NSString *)instructionStringForCCD
{
    return [self displayInstruction];
}

@end
