//
//  CoreDataManager.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "MMLPersonData.h"
#import "MMLCCDInfo.h"
#import "MMLMedicationList.h"
#import "MMLMedicationFrequency.h"
#import "MMLInsurance.h"
#import "MMLConceptProperty.h"
#import "MMLMedicationAmount.h"
#import "MMLMedication.h"
#import "MMLIngredients.h"
#import "MMLMedicationInstruction.h"

@interface CoreDataManager : NSObject
+ (CoreDataManager *)coreDataManager;
- (NSUInteger)profileCount ;
- (MMLPersonData *)profileAtIndex:(NSUInteger)index;- (NSString *) getPersonNameByIndex:(NSUInteger)index ;
- (UIImage *) getPersonImageByIndex:(NSUInteger)index ;
-(MMLPersonData *) newPersonData ;
-(MMLMedication *) newMedication ;
-(MMLInsurance *) newInsurance ;
-(MMLMedicationInstruction *) newInstruction ;
-(MMLMedicationFrequency *) newFrequency ;
-(MMLMedicationAmount *) newamount ;
- (MMLCCDInfo *) newCCDInfo ;

- (MMLConceptProperty *) newConceptProperty ;
- (MMLMedicationList *) newMedicationList ;
- (MMLIngredients *) newIngredients ;
- (void) deleteManagedObject:(NSManagedObject *) nsObject;
- (void) deletePersonAtIndex:(NSUInteger)index;
- (NSString *)duplicateIngredient:(NSSet *)ingredientSet  ForPerson:(MMLPersonData *) personData;
- (void) setMMLIngedients:(NSString *)ingredientString forMedication:(MMLMedication *)med;
- (void)saveContext;
- (void) rollBack;
- (NSString *) getExpiredMedicationNames:(MMLPersonData *)person;
-(void) printPersonData:(MMLPersonData *)person;

@end
