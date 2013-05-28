//
//  MedicationContainer.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//



#import "Medication.h"
#import "Prescription.h"
#import "MedicationContainer.h"

@implementation MedicationContainer
@synthesize medication = _medication;
@synthesize prescription = _prescription;

- (id)init
{
    return [self initWithMedication:nil prescription:nil];
}

- (id)initWithMedication:(Medication*)medication
{
    return [self initWithMedication:medication prescription:nil];
}

- (id)initWithPrescription:(Prescription*)prescription
{
    return [self initWithMedication:nil prescription:prescription];
}

- (id)initWithMedication:(Medication *)medication prescription:(Prescription *)prescription
{
    self = [super init];
    if(self){
        _medication = medication;
        _prescription = prescription;
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc - MedicationContainer");
    NSLog(@"DEALLOC MEDICATIONCONTAINER is %d", [self.medication retainCount]);

    [_medication release];
    [_prescription release];
    [super dealloc];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    MedicationContainer *newMedContainer = [[MedicationContainer alloc] initWithMedication:[[_medication mutableCopy] autorelease] prescription:[[self.prescription mutableCopy] autorelease]];
    
    return newMedContainer;
}

- (id)mutableCopy
{
    return [self mutableCopyWithZone:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSLog(@"encoding MedicationContainer");
    [aCoder encodeObject:_medication forKey:@"MMLMedication"];
    [aCoder encodeObject:_prescription forKey:@"MMLPrescription"];
    NSLog(@"RetainCount is %d", [_medication retainCount]);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder - MedicationContainer");
    self = [self init];
    if(self)
    {
        _medication = [aDecoder decodeObjectForKey:@"MMLMedication"];
        [_medication retain];
        _prescription = [aDecoder decodeObjectForKey:@"MMLPrescription"];
        [_prescription retain];
    }
    
    return self;
}

@end
