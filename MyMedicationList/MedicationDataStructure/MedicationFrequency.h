//
//  MedicationFrequency.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import <Foundation/Foundation.h>

enum Frequency
{
	Once_A_Day,
	Twice_A_Day,
	Three_Times_A_Day,
	Four_Times_A_Day,
    Six_Times_A_Day,
    Every_Other_Day,
    Weekly,
    Monthly,
	Every_24_Hours,
	Every_12_Hours,
	Every_8_Hours,
	Every_6_Hours,
    Every_4_Hours,
	NumberOfFrequencies
};

typedef enum Frequency Frequency;

@interface MedicationFrequency : NSObject<NSCoding,NSMutableCopying> {
    
}

@property (assign,nonatomic) Frequency frequency;

// Get the string representation for a given frequency
+ (NSString *)frequencyStringForFrequency:(Frequency)frequency;

// Setup a Frequency objection with the frequency
- (id)initWithFrequency:(Frequency)frequency;

// TODO: make all of the 'print' functions for the data structure void and do an NSLog so
// it is differentiated from the 'display' functions which are meant to return a string
- (NSString *)printFrequency;

- (NSString *)displayFrequency;

// NSMutableCopying Protocol methods for copying the medication
- (id)mutableCopy;

// NSCoding protocol methods for saving a medication
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (NSString *)hourFrequencyString;
@end
