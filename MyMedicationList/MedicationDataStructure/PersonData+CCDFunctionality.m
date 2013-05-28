//
//  PersonData+CCDFunctionality.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "PersonData+CCDFunctionality.h"

@implementation PersonData (CCDFunctionality)

- (NSString *)genderString
{
    if(self.gender == Male)
		return @"Male";
	else 
		return @"Female";
}

- (NSString *)genderInitial
{
    if(self.gender == Male)
		return @"M";
	else 
		return @"F";
}

@end
