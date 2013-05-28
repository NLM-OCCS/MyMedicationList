//
//  MedicationList.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "NSMutableArray+MedicationFunctionality.h"

 
@interface MedicationList : NSObject<NSCoding,NSFastEnumeration> {

}

@property (copy,nonatomic) NSString *archiveName;
@property (readonly,nonatomic) NSMutableArray *medicationList;

- (id)initWithArchiveName:(NSString *)archiveName;

- (void)saveList;
- (void)loadList;

- (BOOL)isEmpty;
- (NSUInteger)count;
- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)objects;
- (void)removeLastObject;
- (void)removeAllObjects;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexSet;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (id)objectAtIndex:(NSUInteger)index;
- (id)lastObject;



//- (NSMutableArray *)medications;
//- (NSMutableArray *)prescriptions;

// TODO: This is temporary until it is decided that this can be delete
//- (void)clean;

- (void)printMedicationList;

// !!!: You may be able to delete these since you are using only 'saveList' and 'loadList'
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
