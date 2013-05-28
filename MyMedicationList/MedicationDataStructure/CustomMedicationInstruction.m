//
//  CustomMedicationInstruction.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "CustomMedicationInstruction.h"


@implementation CustomMedicationInstruction
@synthesize customInstruction = _customInstruction;

- (id)initWithCustomInstruction:(NSString *)customInstruction
{
    self = [super init];
    if(self)
    {
        self.customInstruction = customInstruction;
    }
    
    return self;
}

- (NSString *)instruction
{
    return [[_customInstruction mutableCopy] autorelease];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    CustomMedicationInstruction *newCustomMedicationInstruction = [[CustomMedicationInstruction alloc] initWithCustomInstruction:_customInstruction];
    return newCustomMedicationInstruction;
}

- (id)mutableCopy
{
    return [self mutableCopyWithZone:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_customInstruction forKey:@"MMLcustomInstruction"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
//    self = [super initWithCustomInstruction:nil];
    self = [super init];
    if(self)
    {
        _customInstruction = [aDecoder decodeObjectForKey:@"MMLcustomInstruction"];
        [_customInstruction retain];
    }

    return self;
}

@end
