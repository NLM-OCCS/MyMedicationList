//
//  NSMutableArray+MedicationFunctionality.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "StorageDirectory.h"
#import "NSMutableArray+MedicationFunctionality.h"

/*
@implementation NSMutableArray_MedicationFunctionality

@end
*/

@implementation NSMutableArray(MedicationFunctionality)

- (BOOL)saveMedicationList: (NSString *)archiveName
{
	NSString *fullArchiveName = [NSString stringWithFormat:@"%@.archive",archiveName];
	NSString *archivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
	NSLog(@"Saving at archive path: %@",archivePath);
	return [NSKeyedArchiver archiveRootObject:self toFile:archivePath]; 
}

- (void)loadMedicationList: (NSString *)archiveName
{
	NSMutableArray *tempMedications = nil;
	
    NSString *fullArchiveName = [NSString stringWithFormat:@"%@.archive",archiveName];
	NSString *archivePath = [storageDirectory() stringByAppendingPathComponent:fullArchiveName];
	NSLog(@"Loading at archive path: %@",archivePath);
    
	tempMedications = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
	if (tempMedications == nil) 
		printf("The medications haven't been saved so the file should be nil.\n");
	else 
		[self addObjectsFromArray:tempMedications];
}

@end