//
//  MMLIngredients.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMLMedication;

@interface MMLIngredients : NSManagedObject

@property (nonatomic, retain) NSString * ingredient;
@property (nonatomic, retain) MMLMedication *medication;

@end
