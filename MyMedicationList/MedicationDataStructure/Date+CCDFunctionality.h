//
//  Date+CCDFunctionality.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "Date.h"

@interface Date (CCDFunctionality)

+ (Date *)dateForCCDDateString:(NSString *)ccdDateString;

- (NSString *)dateStringForCCD;
- (NSString *)dateAttributeStringForCCD;
@end
