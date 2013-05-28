//
//  MedicationFrequency+CCDFunctionality.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "MedicationFrequency+CCDFunctionality.h"

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

@implementation MedicationFrequency (CCDFunctionality)

+ (MedicationFrequency *)frequencyForCCDFrequencyHourString:(NSString *)frequencyHourString
{
    NSUInteger frequencyIndex;
    for(frequencyIndex = 0; frequencyIndex < NumberOfFrequencies; frequencyIndex++)
    {
        if([frequencyHourString compare:frequencyHourStrings[frequencyIndex]] == NSOrderedSame)
            break;
    }
    
    MedicationFrequency *frequency = [[MedicationFrequency alloc] initWithFrequency:(Frequency)frequencyIndex];
    
    return [frequency autorelease];
}

- (NSString *)frequencyStringForCCD
{
    return frequencyTypeStrings[self.frequency];
}

- (NSString *)hourFrequencyStringForCCD
{
    return frequencyHourStrings[self.frequency];
}

@end
