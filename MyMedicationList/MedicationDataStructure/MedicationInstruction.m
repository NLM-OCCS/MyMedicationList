//
//  MedicationInstruction.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MedicationInstruction.h"
#import "DefinedMedicationInstruction.h"
#import "CustomMedicationInstruction.h"

@interface MedicationInstruction () {

    BOOL _isDefinedInstruction;
    id<MedicationInstructionProtocol> _currentInstruction;
}

@end


@implementation MedicationInstruction

+ (NSString *)stringForDefinedInstruction:(MedicationDefinedInstruction)definedInstruction
{
    return [DefinedMedicationInstruction stringForDefinedInstruction:definedInstruction];
}

+ (MedicationDefinedInstruction)definedInstructionForString:(NSString *)definedInstructionString
{
    return [DefinedMedicationInstruction definedInstructionForString:definedInstructionString];
}

- (id)initWithInstruction:(NSString *)instruction
{
    self = [super init];
    if(self)
    {
        if([DefinedMedicationInstruction isDefinedInstructionString:instruction])
        {
            MedicationDefinedInstruction definedInstruction = [DefinedMedicationInstruction definedInstructionForString:instruction];
            
            _currentInstruction = [[DefinedMedicationInstruction alloc] initWithDefinedInstruction:definedInstruction];
            _isDefinedInstruction = YES;
        }
        else
        {
            _currentInstruction = [[CustomMedicationInstruction alloc] initWithCustomInstruction:instruction];
            _isDefinedInstruction = NO;
        }
    }
    
    return self;
}

- (id)initWithDefinedInstruction:(MedicationDefinedInstruction)definedInstruction
{
    self = [super init];
    if(self)
    {
        _currentInstruction = [[DefinedMedicationInstruction alloc] initWithDefinedInstruction:definedInstruction];
        _isDefinedInstruction = YES;
    }
    
    return self;
}

- (id)initWithCustomInstruction:(NSString *)customInstuction
{
    self = [super init];
    if(self)
    {
        _currentInstruction = [[CustomMedicationInstruction alloc] initWithCustomInstruction:customInstuction];
        _isDefinedInstruction = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [_currentInstruction release];
    _currentInstruction = nil;
    NSLog(@"Dealloc - MedicationInstruction");
    [super dealloc];
}

- (BOOL)isDefinedInstruction
{
    return _isDefinedInstruction;
}

- (BOOL)isCustomInstruction
{
    return !_isDefinedInstruction;
}

- (void)setDefinedInstruction:(MedicationDefinedInstruction)definedInstruction
{
    if([_currentInstruction isKindOfClass:[DefinedMedicationInstruction class]])
        ((DefinedMedicationInstruction *)_currentInstruction).definedInstruction = definedInstruction;
    else
    {
        [_currentInstruction release];
        _currentInstruction = nil;
        _currentInstruction = [[DefinedMedicationInstruction alloc] initWithDefinedInstruction:definedInstruction];
    }
    _isDefinedInstruction = YES;
}

- (void)setCustomInstruction:(NSString *)customInstruction
{
    if([_currentInstruction isKindOfClass:[CustomMedicationInstruction class]])
        ((CustomMedicationInstruction *)_currentInstruction).customInstruction = customInstruction;
    else
    {
        [_currentInstruction release];
        _currentInstruction = nil;
        _currentInstruction = [[CustomMedicationInstruction alloc] initWithCustomInstruction:customInstruction];
    }
    _isDefinedInstruction = NO;
}

- (NSString *)printInstruction
{
    return [_currentInstruction.instruction stringByReplacingOccurrencesOfString:@"|" withString:@" "];
}
- (NSString *)origInstruction
{
    return _currentInstruction.instruction;
}
- (NSString *)displayInstruction
{
    return [_currentInstruction.instruction stringByReplacingOccurrencesOfString:@"|" withString:@" "];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    MedicationInstruction *newMedicationInstruction;
    
    if(_isDefinedInstruction)
        newMedicationInstruction = [[MedicationInstruction alloc] initWithDefinedInstruction:((DefinedMedicationInstruction *)_currentInstruction).definedInstruction];
    else
        newMedicationInstruction = [[MedicationInstruction alloc] initWithCustomInstruction:((CustomMedicationInstruction *)_currentInstruction).customInstruction];
    
    return newMedicationInstruction;
}

- (id)mutableCopy
{
    return [self mutableCopyWithZone:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_isDefinedInstruction forKey:@"MMLisDefinedInstruction"];
    if(_isDefinedInstruction)
        [aCoder encodeObject:((DefinedMedicationInstruction *)_currentInstruction) forKey:@"MMLcurrentInstructionDefined"];
    else
        [aCoder encodeObject:((CustomMedicationInstruction *)_currentInstruction) forKey:@"MMLcurrentInstructionCustom"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{

    self = [super init];
    if(self)
    {
        
        _isDefinedInstruction =  [aDecoder decodeBoolForKey:@"MMLisDefinedInstruction"];
        if(_isDefinedInstruction)
            _currentInstruction = [aDecoder decodeObjectForKey:@"MMLcurrentInstructionDefined"];
        else
            _currentInstruction = [aDecoder decodeObjectForKey:@"MMLcurrentInstructionCustom"];
            
        [_currentInstruction retain];
    }
        
    return self;
}

@end
