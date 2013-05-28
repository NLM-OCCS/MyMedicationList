//
//  MedicationAmount.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "MedicationAmount.h"

@implementation MedicationAmount
@synthesize amountType = _amountType;
@synthesize quantity = _quantity;

/*
enum MedicationAmountType
{	
	Pills,
	Drops,
	Inhalation,
	ML,
	Teaspoon,
	Units,
	NumberOfAmountTypes
};
*/

static NSString * const amountTypeStrings[] = {@"TABLET",
                                               @"CAPSULE",
                                               @"ML",
                                               @"TEASPOON",
                                               @"DROPS",
                                               @"INHALATION",
                                               @"UNIT"
};

- (void) dealloc {
     NSLog(@"Dealloc - MedicationAmount");
    [super dealloc];
   
}
+ (NSString *)amountTypeStringForAmountType:(MedicationAmountType)amountType
{
	return amountTypeStrings[(int)amountType];
}


+ (MedicationAmountType)medicationAmountTypeFromInteger:(NSUInteger)type
{
	return (MedicationAmountType)type;
}



+ (NSString *)amountTypeStringSingular:(MedicationAmountType)amountType
{
    return amountTypeStrings[amountType];
}

+ (NSString *)amountTypeString:(MedicationAmountType)amountType
{
    if(amountType == ML)
        return amountTypeStrings[amountType];
    else
        return [NSString stringWithFormat:@"%@s",[self amountTypeStringSingular:amountType]];
}

+ (NSString *)amountTypeStringWithInteger:(NSUInteger)type
{
	MedicationAmountType thisAmountType = [self medicationAmountTypeFromInteger:type];
	return [self amountTypeString:thisAmountType];								   
}

/*
+ (NSString *)amountTypeStringForCCD:(MedicationAmountType)thisAmount
{
	if(thisAmount == Pills)
		return nil;
	else if(thisAmount == Drops)
		return @"DROPS";
	else if(thisAmount == Inhalation)
		return @"INHALATION";
	else if(thisAmount == ML)
		return @"ML";
	else if(thisAmount == Teaspoon)
		return @"TEASPOON";
	else
		return @"UNITS";
}
 */

+ (MedicationAmountType)amountTypeForTypeString:(NSString *)typeString
{
    if([typeString rangeOfString:@"Tablet" options:NSCaseInsensitiveSearch].length > 0)
        return Tablet;
    else if ([typeString rangeOfString:@"Drop" options:NSCaseInsensitiveSearch].length > 0)
        return Drops;
    else if ([typeString rangeOfString:@"Inhalation" options:NSCaseInsensitiveSearch].length > 0)
        return Inhalation;
    else if ([typeString rangeOfString:@"ML" options:NSCaseInsensitiveSearch].length > 0)
        return ML;
    else if ([typeString rangeOfString:@"Teaspoon" options:NSCaseInsensitiveSearch].length > 0)
        return Teaspoon;
    else //if ([typeString rangeOfString:@"Unit" options:NSCaseInsensitiveSearch].length > 0)
        return Units;
}

- (id)initWithAmountType:(MedicationAmountType)amountType Quantity:(NSUInteger)quantity
{
    self = [super init];
	if(self)
	{
		self.amountType = amountType;
        self.quantity = quantity;
	}
	
	return self;
}

/*
- (NSString *)completeAmountStringForCCD
{
	if([MedicationAmount amountTypeStringForCCD:_amountType] == nil)
		return [NSString stringWithFormat:@"%d",_quantity];
	else
		return [NSString stringWithFormat:@"%d %@",_quantity,[MedicationAmount amountTypeStringForCCD:_amountType]];
}
 */

- (int)numberAmountTypes
{
	return NumberOfAmountTypes;
}

- (BOOL)isEqual:(MedicationAmount *)anotherMedicationAmount
{
	if((_quantity != anotherMedicationAmount.quantity)||(_amountType != anotherMedicationAmount.amountType))
		return NO;
	else
		return YES;
}

- (NSString *)displayMedicationAmount
{
    NSString *amountTypeString = nil;
    if(_quantity == 1)
        amountTypeString = [MedicationAmount amountTypeStringSingular:_amountType];
    else
        amountTypeString = [MedicationAmount amountTypeString:_amountType];
    
    NSLog(@"amountTypeString: %@",amountTypeString);
	return [NSString stringWithFormat:@"%d %@", _quantity, amountTypeString];	
}

- (NSString *)printAmount
{
    NSLog(@"printAmount");
    NSString *amountTypeString = nil;
    if(_quantity == 1)
        amountTypeString = [MedicationAmount amountTypeStringSingular:_amountType];
    else
        amountTypeString = [MedicationAmount amountTypeString:_amountType];

    NSLog(@"amountTypeString: %@",amountTypeString);
    return [NSString stringWithFormat:@"%d %@", _quantity, amountTypeString];
}

- (NSString *)displayAmount
{
    return [self printAmount];
}

- (id) mutableCopyWithZone:(NSZone *)zone
{
	MedicationAmount *newMedicationAmount = [[MedicationAmount alloc] initWithAmountType:_amountType Quantity:_quantity];
	return newMedicationAmount;
}

- (id) mutableCopy
{
	return [self mutableCopyWithZone:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

	[aCoder encodeInt:_amountType forKey:@"MMLmedicationAmountType"];
	[aCoder encodeInt:_quantity forKey:@"MMLmedAmountQuantity"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{

	self = [super init];
	
	if (self != nil)
	{
		_amountType = [aDecoder decodeIntForKey:@"MMLmedicationAmountType"];
		_quantity = [aDecoder decodeIntForKey:@"MMLmedAmountQuantity"];
	}
	
	return self;
}

@end
