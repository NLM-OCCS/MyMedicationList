//
//  MedicationAmount+CCDFunctionality.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "MedicationAmount+CCDFunctionality.h"

static NSString * const amountTypeStrings[] = {@"Tablet",
                                               @"Capsule",
                                               @"ML",
                                               @"Teaspoon",
                                               @"Drop",
                                               @"Inhalation",
                                               @"Unit"
};

static NSString * const amountTypeStringsForCCD[] = {@"TABLET",
                                                     @"CAPSULE",
                                                     @"ML",
                                                     @"TEASPOON",
                                                     @"DROPS",
                                                     @"INHALATION",
                                                     @"UNITS"
};


@implementation MedicationAmount (CCDFunctionality)

+ (MedicationAmount *)amountForCCDQuantityString:(NSString *)quantityString typeString:(NSString *)typeString;
{
    NSLog(@"amountForCCDQuantityString:typeString:");
    NSLog(@"typeString = %@",typeString);
    NSLog(@"quantityString = %@",quantityString);
    
    NSUInteger quantity = [quantityString intValue];
    
    NSUInteger amountIndex;
    
    if ([typeString compare:@"TABLET" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        amountIndex = 0;
    else if(typeString != nil)
            for(amountIndex = 0; amountIndex < NumberOfAmountTypes; amountIndex++)
                if ([typeString compare:amountTypeStringsForCCD[amountIndex] options:NSCaseInsensitiveSearch] == NSOrderedSame)
                    break;
    
    NSLog(@"amountIndex = %d",amountIndex);
    MedicationAmount *medicationAmount = [[MedicationAmount alloc] initWithAmountType:(MedicationAmountType)amountIndex Quantity:quantity];
    
    NSLog(@"Print medicationAmount...");
    NSLog(@"%@",[medicationAmount printAmount]);
    return [medicationAmount autorelease];
}

- (NSString *)amountStringForCCD
{
	if([self amountTypeStringForCCD] == nil)
		return [NSString stringWithFormat:@"%d",self.quantity];
	else
		return [NSString stringWithFormat:@"%d %@",self.quantity,[self amountTypeStringForCCD]];
}

- (NSString *)amountQuantityStringForCCD
{
    return [NSString stringWithFormat:@"%d",self.quantity];
}

- (NSString *)amountTypeStringForCCD
{
    return amountTypeStringsForCCD[self.amountType];
}

- (BOOL)hasUnitStringForCCD
{
        return YES;
}

- (NSString *)NCIThesaurusCodeForAmountType
{
	if(self.amountType == Drops)
		return @"C48491";
	else if(self.amountType == Inhalation)
		return @"C48501";
	else if(self.amountType == ML)
		return @"C28254";
	else if(self.amountType == Teaspoon)
		return @"C48544";
    else if (self.amountType == Tablet) 
        return @"C48542";
    else if (self.amountType == Capsule) 
        return @"C48480";
	else //if(thisAmount == Units)
		return @"C44278";

}

@end
