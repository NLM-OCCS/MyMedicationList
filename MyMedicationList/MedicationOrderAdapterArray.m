//
//  MedicationOrderAdapterArray.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MedicationOrderAdapterArray.h"
#import "MedicationContainer.h"
#import "MedicationList.h"

@interface MedicationOrderAdapterArray (){
    NSMutableArray *_orderArray;
}

@property (retain,nonatomic) MedicationList *medicationList;

@end

@implementation MedicationOrderAdapterArray
@synthesize medicationList = _medicationList;

- (id)initWithMedicationList:(MedicationList *)medicationList
{
    self = [super init];
    if(self)
    {
        self.medicationList = medicationList;
        
        _orderArray = [[NSMutableArray alloc] initWithCapacity:[_medicationList count]];
        
        for (NSUInteger index = 0; index < [_medicationList count]; index++) {
            if(((MedicationContainer *)[_medicationList objectAtIndex:index]).medication != nil)
                [_orderArray addObject:[NSNumber numberWithUnsignedInteger:index]];
        }

    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc - MedicationOrderAdapterArray");
    [_orderArray release];
    self.medicationList = nil;
    [super dealloc];
}

- (void)reorder
{
    [_orderArray removeAllObjects];
    for (NSUInteger index = 0; index < [_medicationList count]; index++) {
        if(((MedicationContainer *)[_medicationList objectAtIndex:index]).medication != nil)
            [_orderArray addObject:[NSNumber numberWithUnsignedInteger:index]];
    }
    
    NSLog(@"reorder - MedicationOrder, count = %d",[_orderArray count]);
}

- (NSUInteger)count
{
    NSLog(@"count - MedicationOrder, count = %d",[_orderArray count]);
    return [_orderArray count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    NSLog(@"objectAtIndex:%d - MedicationOrder",index);
    NSUInteger realIndex = [[_orderArray objectAtIndex:index] unsignedIntegerValue];    
    return [_medicationList objectAtIndex:realIndex];
}

- (void)addObject:(id)anObject
{
    NSLog(@"addObject - MedicationOrder");
    NSUInteger lastValueIndex;
    // When the order array is zero we must insert at 0 instead
    // of 1 because [[_orderArray lastObject] unsignedIntegerValue] returns 0 
    // and is then incremented
    if([_orderArray count] == 0)
        lastValueIndex = 0;
    else
    {
        lastValueIndex = [[_orderArray lastObject] unsignedIntegerValue];
        lastValueIndex++;
    }
    
    [_orderArray addObject:[NSNumber numberWithUnsignedInteger:lastValueIndex]];
    [_medicationList insertObject:anObject atIndex:lastValueIndex];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    NSLog(@"insertObject:atIndex: - MedicationOrder");
    if([_orderArray count] == 0)
        [self addObject:anObject];
    else
    {
        NSUInteger realIndex = [[_orderArray objectAtIndex:index] unsignedIntegerValue]; 
        [_orderArray insertObject:[NSNumber numberWithUnsignedInteger:realIndex] atIndex:index];
        [_medicationList insertObject:anObject atIndex:realIndex];
        
        // Adjust all of the order indices up by one since we have added a member of the array
        NSUInteger newIndex;
        for (NSUInteger i = (index+1); i < [_orderArray count]; i++) {
            newIndex = [[_orderArray objectAtIndex:i] unsignedIntegerValue]+1;
            [_orderArray replaceObjectAtIndex:i withObject:[NSNumber numberWithUnsignedInteger:newIndex]];
        }
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    // If we are removing the last object in the array then use the simpler 'removeLastObject'
    if(index == [[_orderArray lastObject] unsignedIntegerValue])
        [self removeLastObject];
    else
    {
        NSUInteger realIndex = [[_orderArray objectAtIndex:index] unsignedIntegerValue];    
        [_orderArray removeObjectAtIndex:index];
        [_medicationList removeObjectAtIndex:realIndex];
        
        // Adjust all of the order indices down by one since we have deleted a member of the array
        NSUInteger newIndex;
        for (NSUInteger i = index; i < [_orderArray count]; i++) {
            newIndex = [[_orderArray objectAtIndex:i] unsignedIntegerValue]-1;
            [_orderArray replaceObjectAtIndex:i withObject:[NSNumber numberWithUnsignedInteger:newIndex]];
        }
    }
    
    NSLog(@"removeObjectAtIndex:%d - MedicationOrder. Count = %d",index,[_orderArray count]);        
}

- (void)removeLastObject
{
    NSLog(@"removeLastObject - MedicationOrder. Count = %d",([_orderArray count] - 1));        
    NSUInteger lastValueIndex = [[_orderArray lastObject] unsignedIntegerValue];
    [_orderArray removeLastObject];
    [_medicationList removeObjectAtIndex:lastValueIndex];
}

@end
