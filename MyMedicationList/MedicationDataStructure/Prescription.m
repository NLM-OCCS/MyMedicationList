//
//  Prescription.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//
#import "Prescription.h"

@implementation Prescription


@synthesize isOnMedList = _isOnMedList;



- (id)init
{
    self = [super init];
    if(self)
    {
         
         self.isOnMedList = NO;
    }
    
    return self;
}

- (id)initWithMedication:(Medication *)medication
{
    NSLog(@"Prescription - initWithMedication");
    self = [super initWithMedication:medication];
    if(self)
    {
                self.isOnMedList = NO;
    }
    
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

- (void)printMedication
{
    [super printMedication];
    /*
    _prescribeDate;
    @synthesize telephoneNumber = _telephoneNumber;
    @synthesize prescriberFirstName = _prescriberFirstName;
    @synthesize prescriberLastName = _prescriberLastName;
    @synthesize prescriberSuffix = _prescriberSuffix;
     */
    
}

- (id)mutableCopyWithZone:(NSZone *)zone
{

    Prescription *newPrescription = [super mutableCopyWithZone:zone];

    // Initialize variables here
    
    newPrescription.isOnMedList = YES;
    return newPrescription;
}

- (id)mutableCopy
{
    return [self mutableCopyWithZone:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [super encodeWithCoder:aCoder];
    
    [aCoder encodeBool:_isOnMedList forKey:@"MMLisOnMedList"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
 
    if(self)
    {
               _isOnMedList = [aDecoder decodeBoolForKey:@"MMLisOnMedList"];
    }
    
    return self;
}

@end
