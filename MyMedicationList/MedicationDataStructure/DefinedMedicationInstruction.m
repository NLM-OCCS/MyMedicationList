//
//  DefinedMedicationInstruction.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "DefinedMedicationInstruction.h"


@implementation DefinedMedicationInstruction
@synthesize definedInstruction = _definedInstruction;

NSString * const definedInstructionStrings[] = {@"As Needed",
                                                @"As Directed",
                                                @"At Bedtime",
                                                @"In The Morning",
                                                @"In The Evening",
                                                @"On Empty Stomach",    
                                                @"With Meals"};

+ (NSString *)stringForDefinedInstruction:(MedicationDefinedInstruction)definedInstruction
{
    return definedInstructionStrings[(int)definedInstruction];
}

+ (MedicationDefinedInstruction)definedInstructionForString:(NSString *)definedInstructionString
{
    
    for(int index = 0; index < NumberOfInstructions; index++)
    {
        if([definedInstructionString isEqualToString:definedInstructionStrings[index]])
            return (MedicationDefinedInstruction)index;
    }
    
    // The default instruction for an unrecognized instruction string
    return As_Directed;
}

+ (BOOL)isDefinedInstructionString:(NSString *)instructionString{
    BOOL isDefined = NO;
    
    for (NSUInteger instructionIndex = 0; instructionIndex < NumberOfInstructions; instructionIndex++)
        if ([instructionString compare:definedInstructionStrings[instructionIndex] options:NSCaseInsensitiveSearch] == NSOrderedSame)
            isDefined = YES;
    
    return isDefined;
}

- (id)initWithDefinedInstruction:(MedicationDefinedInstruction)definedInstruction
{
    self = [super init];
    if(self)
    {
        self.definedInstruction = definedInstruction;
    }
    
    return self;
}

- (NSString *)instruction
{
    /*
    if(_definedInstruction == As_Needed)
		return @"As Needed";
	else if(_definedInstruction == As_Directed)
		return @"As Directed";
	else if(_definedInstruction == At_Bedtime)
		return @"At Bedtime";
	else if(_definedInstruction == In_The_Morning)
		return @"In The Morning";
	else if(_definedInstruction == In_The_Evening)
		return @"In The Evening";
	else if(_definedInstruction == On_Empty_Stomach)
		return @"On Empty Stomach";
	else
		return @"With Meals";	
     */
    return [[definedInstructionStrings[_definedInstruction] copy] autorelease];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    DefinedMedicationInstruction *newDefinedMedicationInstruction = [[DefinedMedicationInstruction alloc] initWithDefinedInstruction:_definedInstruction];
    return newDefinedMedicationInstruction;
}

- (id)mutableCopy
{
    return [self mutableCopyWithZone:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSLog(@"encodeWithCoder - DefinedMedicationInstruction");
    [aCoder encodeInt:_definedInstruction forKey:@"MMLdefinedInstruction"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder - DefinedMedicationInstruction");    
    
//    self = [super initWithDefinedInstruction:0];
    self = [super init];
    if(self)
    {
        _definedInstruction = [aDecoder decodeIntForKey:@"MMLdefinedInstruction"];
    }
    
    return self;
}

@end
