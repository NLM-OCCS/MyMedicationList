//
//  MMLMedication.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMLCCDInfo, MMLConceptProperty, MMLIngredients, MMLMedicationAmount, MMLMedicationFrequency, MMLMedicationInstruction, MMLMedicationList;

@interface MMLMedication : NSManagedObject

@property (nonatomic, retain) NSDate * stopDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * creationID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSDate * prescriberDate;
@property (nonatomic, retain) NSString * prescriberFirstName;
@property (nonatomic, retain) NSString * prescriberLastName;
@property (nonatomic, retain) NSString * prescriberSuffix;
@property (nonatomic, retain) NSNumber * repeats;
@property (nonatomic, retain) MMLConceptProperty *conceptProperty;
@property (nonatomic, retain) MMLCCDInfo *ccdInfo;
@property (nonatomic, retain) MMLMedicationAmount *medicationAmount;
@property (nonatomic, retain) MMLMedicationFrequency *medicationFrequency;
@property (nonatomic, retain) MMLMedicationInstruction *medicationInstruction;
@property (nonatomic, retain) NSSet *ingredientsArray;
@property (nonatomic, retain) MMLMedicationList *medicationList;
@end

@interface MMLMedication (CoreDataGeneratedAccessors)

- (void)addIngredientsArrayObject:(MMLIngredients *)value;
- (void)removeIngredientsArrayObject:(MMLIngredients *)value;
- (void)addIngredientsArray:(NSSet *)values;
- (void)removeIngredientsArray:(NSSet *)values;

@end
