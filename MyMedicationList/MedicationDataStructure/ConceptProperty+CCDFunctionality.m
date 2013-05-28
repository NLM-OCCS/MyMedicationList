//
//  ConceptProperty+CCDFunctionality.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "ConceptProperty+CCDFunctionality.h"

@implementation ConceptProperty (CCDFunctionality)

- (NSString *)conceptNameStringForCCD
{
    if(([self.synonym isEqualToString:@""])||(self.synonym == nil)) 
        return self.name;
    else 
        return self.synonym;
}

@end
