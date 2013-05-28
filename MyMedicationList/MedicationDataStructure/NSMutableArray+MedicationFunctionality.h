//
//  NSMutableArray+MedicationFunctionality.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
 
// Category of methods on the NSMutableArray class which you use to store medication data.
// These methods make load and saving from a file convenient.
@interface NSMutableArray(MedicationFunctionality)

// Save the contents of your current medication list to file in the iphone
- (BOOL)saveMedicationList: (NSString *)archiveName;
// Load the contents of your current medication list from a file in the iphone
- (void)loadMedicationList: (NSString *)archiveName;

@end