//
//  Date+CCDFunctionality.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "Date+CCDFunctionality.h"

@implementation Date (CCDFunctionality)

+ (Date *)dateForCCDDateString:(NSString *)ccdDateString
{
    NSLog(@"ccdDateString: %@",ccdDateString);
    if (ccdDateString == nil || [ccdDateString isEqualToString:@""]) 
        return nil;
    
    unsigned int year = [[ccdDateString substringToIndex:4] intValue];
    unsigned int month = [[ccdDateString substringWithRange:NSMakeRange(4, 2)] intValue];
    unsigned int day = [[ccdDateString substringWithRange:NSMakeRange(6, 2)] intValue];
    
    Date *date = [[Date alloc] initWithDay:day Month:month Year:year];
    
    return [date autorelease];
}

- (NSString *)dateStringForCCD
{
	NSMutableString *dateString = [NSMutableString stringWithCapacity:10];
	
	[dateString appendFormat:@"%02d/",self.month];
	[dateString appendFormat:@"%02d/",self.day];
	[dateString appendFormat:@"%4d",self.year];	
	
	return dateString;
}

// Previous name
//- (NSString *)dateValueForCCD
- (NSString *)dateAttributeStringForCCD
{
    NSMutableString *dateString = [NSMutableString stringWithCapacity:8];
	
	[dateString appendFormat:@"%4d",self.year];	
	[dateString appendFormat:@"%02d",self.month];
	[dateString appendFormat:@"%02d",self.day];
	
	return dateString;
}


@end
