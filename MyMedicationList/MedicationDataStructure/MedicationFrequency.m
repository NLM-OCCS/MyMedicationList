//
//  MedicationFrequency.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "MedicationFrequency.h"


/*
 enum Frequency
 {
 Once_A_Day,
 Twice_A_Day,
 Three_Times_A_Day,
 Four_Times_A_Day,
 Every_4_Hours,
 Every_6_Hours,
 Every_8_Hours,
 Every_12_Hours,
 NumberOfFrequencies
 };
 */

// There is a copy of this array in the CCDFunctionality Category for this class
static NSString * const frequencyTypeStrings[] = {@"Daily",
                                                  @"Twice Daily",
                                                  @"Three Times Daily",
                                                  @"Four Times Daily",
                                                  @"Six Times Daily",
                                                  @"Every Other day",
                                                  @"Weekly",
                                                  @"Monthly",
                                                  @"Every 24 Hours",
                                                  @"Every 12 Hours",
                                                  @"Every 8 Hours",
                                                  @"Every 6 Hours",
                                                  @"Every 4 Hours",
};

// There is a copy of this array in the CCDFunctionality Category for this class
static NSString * const frequencyHourStrings[] = {@"24",
                                                  @"12",
                                                  @"8",
                                                  @"6",
                                                  @"4",
                                                  @"48",
                                                  @"7",
                                                  @"30",
                                                  @"24", @"12",@"8",@"6",@"4"   
};

@implementation MedicationFrequency
@synthesize frequency = _frequency;
- (void) dealloc {
    NSLog(@"Dealloc - MedicationFrequency");
    [super dealloc];
}

+ (Frequency)medicationFrequencyTypeFromInteger:(NSUInteger)type
{
	return (Frequency)type;
}

//+ (NSString *)frequencyStringWithInteger:(NSUInteger)type
+ (NSString *)frequencyTypeStringWithInteger:(NSUInteger)type
{
	return frequencyTypeStrings[type];
}

+ (NSString *)frequencyStringForFrequency:(Frequency)frequency
{
    NSLog(@"MedicationFrequency %d",frequency);

    return frequencyTypeStrings[(int)frequency];
}

- (NSString *)frequencyTypeString
{
	return frequencyTypeStrings[_frequency];
}

- (NSString *)hourFrequencyString
{
    return frequencyHourStrings[_frequency];
}

- (id)initWithFrequency:(Frequency)frequency;
{
    self = [super init];
    
	if(self)
	{
		self.frequency = frequency;
	}
	return self;
}

- (int)numberOfFrequencies
{
	return NumberOfFrequencies;
}

- (BOOL)isEqual:(MedicationFrequency *)anotherMedicationFrequency
{
	if(_frequency != anotherMedicationFrequency.frequency)
		return NO;
	else
		return YES;
}

- (NSString *)printFrequency
{
    return [self frequencyTypeString];
}

- (NSString *)displayFrequency
{
    return [self printFrequency];
}

- (id) mutableCopyWithZone:(NSZone *)zone
{
	MedicationFrequency *newFrequency = [[MedicationFrequency alloc] initWithFrequency:_frequency];
	return newFrequency;
}

- (id) mutableCopy
{
	return [self mutableCopyWithZone:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeInt:_frequency forKey:@"MMLfrequency"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	
	self = [super init];
	
	if (self != nil)
	{
		_frequency = [aDecoder decodeIntForKey:@"MMLfrequency"];
	}
	
	return self;
}

@end
