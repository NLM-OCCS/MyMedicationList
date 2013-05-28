//
//  CCDGenerator.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "MMLPersonData.h"
@interface CCDGenerator : NSObject{
    
}

+ (NSString *)CCDStringForPerson:(MMLPersonData *)person;
+ (NSString *)CCDTableForPerson:(MMLPersonData *)person;

@end
