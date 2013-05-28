//
//  MedicationList.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "StorageDirectory.h"
#import "MedicationContainer.h"
#import "Medication.h"
#import "MedicationList.h"

@interface MedicationList() {
    // For implementing fast enumeration
    unsigned long _mutations;
}

@end

@implementation MedicationList
@synthesize archiveName = _archiveName;
@synthesize medicationList = _medicationList;

- (id)init
{
    return [self initWithArchiveName:nil];
}

- (id)initWithArchiveName:(NSString *)archiveName
{
    self = [super init];
	if(self)
	{
        self.archiveName = archiveName;
		_medicationList = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc {
    NSLog(@"dealloc - MedicationList");
    self.archiveName = nil;
	[_medicationList release];
    _medicationList = nil;
    [super dealloc];
}

- (NSString *)archiveName
{
    return _archiveName;
}


- (void)clean
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *errorMedList;
	
	NSString *fullArchiveName = [NSString stringWithFormat:@"%@.archive",_archiveName];
	// Delete any left over personal data from the last person who downloaded the application
	[fileManager removeItemAtPath:[storageDirectory() stringByAppendingPathComponent:fullArchiveName] error:&errorMedList];
}

- (void)saveList
{
	[_medicationList saveMedicationList:_archiveName];
}

- (void)loadList
{
	[_medicationList loadMedicationList:_archiveName];
}

- (BOOL)isEmpty
{
	if([_medicationList count] == 0)
		return YES;
	else
		return NO;
}

- (NSUInteger)count
{
	return [_medicationList count];
}

- (void)addObject:(id)anObject
{
    NSLog(@"addObject - MedicationList");
	[_medicationList addObject:anObject];
}

- (void)addObjectsFromArray:(NSArray *)objects
{
    [_medicationList addObjectsFromArray:objects];
}

- (void)removeLastObject
{
    [_medicationList removeLastObject];
}

- (void)removeAllObjects
{
    [_medicationList removeAllObjects];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    NSLog(@"removeObjectAtIndex - MedicationList");    
	[_medicationList removeObjectAtIndex:index];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexSet
{
    [_medicationList removeObjectsAtIndexes:indexSet];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    NSLog(@"insertObject:atIndex - MedicationList");
	[_medicationList insertObject:anObject atIndex:index];
}

- (id)objectAtIndex:(NSUInteger)index
{
    NSLog(@"objectAtIndex - MedicationList");
	return [_medicationList objectAtIndex:index];
}

- (id)lastObject
{
	return [_medicationList lastObject];
}

//- (NSMutableArray *)medications{ return _medicationList; }
- (NSMutableArray *)medications
{
    NSMutableArray *medications = [[NSMutableArray alloc] init];
    
    for(MedicationContainer *medContainer in _medicationList)
    {
        if(medContainer.medication != nil)
            [medications addObject:medContainer.medication];
    }
    
	return [medications autorelease];
}

- (NSMutableArray *)prescriptions
{
    NSMutableArray *prescriptions = [[NSMutableArray alloc] init];
    
    for(MedicationContainer *medContainer in _medicationList)
    {
        if(medContainer.prescription != nil)
            [prescriptions addObject:medContainer.prescription];
    }
    
	return [prescriptions autorelease];
}

- (void)printMedicationList
{
    NSLog(@"printMedicationList");
	for(MedicationContainer *medContainer in _medicationList)
    {
		[medContainer.medication printMedication];
        [medContainer.prescription printMedication];
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    
    NSLog(@"len = %d",len);
    NSUInteger count = 0;
    
    if(state->state == 0)
    {
        state->mutationsPtr = &_mutations;
        state->itemsPtr = buffer;
    }

    if (len > [_medicationList count]-state->state)
        count = [_medicationList count]-state->state;
    else
        count = len;
    
    for (NSUInteger index = 0; index < count; index++) 
        state->itemsPtr[index] = [_medicationList objectAtIndex:(index+state->state)];
    
    state->state += count;
    
    NSLog(@"count = %d",count);
    return count;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSLog(@"MedicationList - encodeWithCoder");
	[aCoder encodeObject:_archiveName forKey:@"MMLmedicationListArchiveName"];
	[aCoder encodeObject:_medicationList forKey:@"MMLmedicationListMedicationList"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"MedicationList - initWithCoder");
    self = [super init];
	if(self)
	{
		_archiveName = [aDecoder decodeObjectForKey:@"MMLmedicationListArchiveName"];
        [_archiveName retain];
		_medicationList = [aDecoder decodeObjectForKey:@"MMLmedicationListMedicationList"];
        [_medicationList retain];
	}
	return self;
}



@end
