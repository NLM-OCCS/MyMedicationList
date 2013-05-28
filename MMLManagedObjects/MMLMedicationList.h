//
//  MMLMedicationList.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMLMedication, MMLPersonData;

@interface MMLMedicationList : NSManagedObject

@property (nonatomic, retain) NSSet *medicationList;
@property (nonatomic, retain) MMLPersonData *currentPerson;
@property (nonatomic, retain) MMLPersonData *discontinuedPerson;
@end

@interface MMLMedicationList (CoreDataGeneratedAccessors)

- (void)addMedicationListObject:(MMLMedication *)value;
- (void)removeMedicationListObject:(MMLMedication *)value;
- (void)addMedicationList:(NSSet *)values;
- (void)removeMedicationList:(NSSet *)values;

@end
