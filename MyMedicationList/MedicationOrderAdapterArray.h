//
//  MedicationOrderAdapterArray.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//
#import <Foundation/Foundation.h>

@class MedicationList;

@interface MedicationOrderAdapterArray : NSObject

- (id)initWithMedicationList:(MedicationList *)medicationList;

// In the prescription viewer add a medication directly to the list
// which by passes this interface. The reorder operation 
- (void)reorder;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;

- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeLastObject;

@end
