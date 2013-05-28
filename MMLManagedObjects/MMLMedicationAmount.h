//
//  MMLMedicationAmount.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMLMedication;

@interface MMLMedicationAmount : NSManagedObject

@property (nonatomic, retain) NSNumber * amountType;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) MMLMedication *medication;

@end
