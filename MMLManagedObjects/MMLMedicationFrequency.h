//
//  MMLMedicationFrequency.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMLMedication;

@interface MMLMedicationFrequency : NSManagedObject

@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) MMLMedication *medication;

@end
