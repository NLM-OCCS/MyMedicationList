//
//  MMLMedicationInstruction.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMLMedication;

@interface MMLMedicationInstruction : NSManagedObject

@property (nonatomic, retain) NSString * instruction;
@property (nonatomic, retain) MMLMedication *medication;

@end
