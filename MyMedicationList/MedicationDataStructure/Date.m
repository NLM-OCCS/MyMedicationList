//
//  Date.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "Date.h"

static NSString *const monthStrings[] = {   @"Jan.",
                                            @"Feb.",  
                                            @"Mar.",
                                            @"Apr.",
                                            @"May",
                                            @"Jun.",
                                            @"Jul.",
                                            @"Aug.",
                                            @"Sep.",    
                                            @"Oct.",    
                                            @"Nov.",        
                                            @"Dec."  };

@implementation Date
@synthesize day = _day;
@synthesize month = _month;
@synthesize year = _year;

+ (Date *)today
{
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDate *date = [NSDate date];
    
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
    
    unsigned int currentDay = [comps day];
    unsigned int currentMonth = [comps month];
    unsigned int currentYear = [comps year];
    
    Date *today = [[Date alloc] initWithDay:currentDay Month:currentMonth Year:currentYear];
    
    return [today autorelease];
}

- (id) initWithDay:(unsigned int)aDay Month:(unsigned int)aMonth Year:(unsigned int)aYear
{
    self = [super init];
	if(self)
	{
        self.day = aDay;
        self.month = aMonth;
        self.year = aYear;
	}
	
	return self;
}

+ (NSArray *)componentsFromString:(NSString *)string
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSMutableCharacterSet *space = [[[NSMutableCharacterSet alloc] init] autorelease];
    [space formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    [space addCharactersInString:@",."];
    
    NSCharacterSet *alphaNumeric = [NSCharacterSet alphanumericCharacterSet];
    
    // Tracks the current position in the string
    NSUInteger currentIndex = 0;
    
    // Tracks the beginning of a new component
    NSUInteger startIndex;
    
    NSLog(@"string:%@",string);
    while (currentIndex != string.length) 
    {
        // Eat whitespace
        while((currentIndex != string.length) &&
              ([space characterIsMember:[string characterAtIndex:currentIndex]]))
            currentIndex++;
        
        NSLog(@"currentIndex = %d",currentIndex);
        // Hold the starting position of the alpha numeric part
        startIndex = currentIndex;
        
        // Find the end of the alphanumeric part of the component
        
        while ((string.length != currentIndex)&&
               ([alphaNumeric characterIsMember:[string characterAtIndex:currentIndex]]))
            currentIndex++;
        
        NSLog(@"component = %@", [string substringWithRange:NSMakeRange(startIndex, currentIndex-startIndex)]);
        // Add the component
        if(currentIndex - startIndex != 0)
            [array addObject:[string substringWithRange:NSMakeRange(startIndex, currentIndex-startIndex)]];
    }
    
    // Print the components
    for(NSString *component in array)
        NSLog(@"Component: %@",component);
    
    return [array autorelease];
}


- (id)initWithString:(NSString *)dateString
{

    self = [super init];
    if(self)
    {
        
        //NSArray *dateComponents = [NSArray arrayWithObjects:@"",@"",@"",nil];
        
        
        //NSLog(@"Before replacement: %@",dateString);
        //dateString = [dateString stringByReplacingOccurrencesOfString:@"," withString:@""];
        //NSLog(@"After replacement: %@",dateString);
        
        //NSArray *dateStringComponents = [dateString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *dateStringComponents = [Date componentsFromString:dateString];
        int monthIndex;
        for (monthIndex = 0; monthIndex < 12; monthIndex++)
            if([[dateStringComponents objectAtIndex:0] compare:[monthStrings[monthIndex] substringToIndex:3] options:NSCaseInsensitiveSearch range:NSMakeRange(0, 3)] == NSOrderedSame)
                break;
        
        
        NSLog(@"first date component: %@",[dateStringComponents objectAtIndex:0]);
        NSLog(@"The month index found: %d",monthIndex);
        NSLog(@"second date component: %@",[dateStringComponents objectAtIndex:1]);
        NSLog(@"The day index found: %d",[[dateStringComponents objectAtIndex:1] intValue]);
        NSLog(@"third date component: %@",[dateStringComponents objectAtIndex:2]);
        NSLog(@"The year index found: %d",[[dateStringComponents objectAtIndex:2] intValue]);
        
        self.month = monthIndex+1;
        self.day = [[dateStringComponents objectAtIndex:1] intValue];
        self.year = [[dateStringComponents objectAtIndex:2] intValue];
    }
    
    return self;
    
}

- (NSComparisonResult) compare:(Date *)anotherDate
{
    NSLog(@"_self Date print: %@",[self printDate]);
    NSLog(@"_self Date print: %@",[anotherDate printDate]);
    
	// Check the order of the years first
	if(_year < anotherDate.year)
		return NSOrderedAscending;
	else if(_year > anotherDate.year)
		return NSOrderedDescending;
	// Check the other of the months since the years are equal
	else
	{
		if(_month < anotherDate.month)
			return NSOrderedAscending;
		else if(_month > anotherDate.month)
			return NSOrderedDescending;
		// Check the order of the days since the years and months are equal
		else
		{
			if(_day < anotherDate.day)
				return NSOrderedAscending;
			else if(_day > anotherDate.day)
				return NSOrderedDescending;
			else // The year, month and day are the same, the dates are equal
				return NSOrderedSame;
		}
	}
}

- (NSString *)monthString
{
    return monthStrings[_month-1];
}

- (NSString *)printDate
{
    return [NSString stringWithFormat:@"%@ %d %d",[self monthString],_day,_year];
}

// Previous Name
//- (NSString *)displayMedicationDate
- (NSString *)displayDate
{
	NSMutableString *dateString = [NSMutableString string];
	
    NSLog(@"displayDate - Date");
    NSLog(@"month %@",[self monthString]);
    NSLog(@"day %d",_day);
    NSLog(@"year %d",_year);
    [dateString appendString:[self monthString]];
	[dateString appendString:[NSString stringWithFormat:@"%2i, ",_day]];
	[dateString appendString:[NSString stringWithFormat:@"%4i", _year]];
	
	return dateString;
}

- (id) mutableCopy
{
	return [self mutableCopyWithZone:nil];
}

- (id) mutableCopyWithZone:(NSZone *)zone
{
	Date *newDate = [[Date alloc] initWithDay:_day Month:_month Year:_year];	
	return newDate;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeInt:_day forKey:@"DateDay"];
	[aCoder encodeInt:_month forKey:@"DateMonth"];
	[aCoder encodeInt:_year forKey:@"DateYear"];	
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if(self)
	{
		_day = [aDecoder decodeIntForKey:@"DateDay"];
		_month = [aDecoder decodeIntForKey:@"DateMonth"];
		_year = [aDecoder decodeIntForKey:@"DateYear"];
	}
	
	return self;
}

- (void) dealloc {
    NSLog(@"Dealloc - Date");
    [super dealloc];
}

+ (NSDate *)getNSDate:(NSString *)dateString

{
    
    
    NSArray *dateStringComponents = [Date componentsFromString:dateString];
    
    int monthIndex;
    
    for (monthIndex = 0; monthIndex < 12; monthIndex++)
        if([[dateStringComponents objectAtIndex:0] compare:[[Date monthString:monthIndex ] substringToIndex:3] options:NSCaseInsensitiveSearch range:NSMakeRange(0, 3)] == NSOrderedSame)
            break;
    
    int month = monthIndex;
    
    int day = [[dateStringComponents objectAtIndex:1] intValue];
    
    int year = [[dateStringComponents objectAtIndex:2] intValue];
    
    return [Date getNSDateForDay:(int)day forMonth:(int)month forYear:(int)year];
    
    
    //return [NSString stringWithFormat:@"%4d%02d%02d", year,month,day];
    
}
+ (NSString *)monthString:(int) monthNum
{
    if(monthNum == 1)
		return @"Jan ";
	else if(monthNum == 2)
		return @"Feb ";
	else if(monthNum == 3)
		return @"Mar ";
	else if(monthNum == 4)
		return @"Apr ";
	else if(monthNum == 5)
		return @"May ";
	else if(monthNum == 6)
		return @"Jun ";
	else if(monthNum == 7)
		return @"Jul ";
	else if(monthNum == 8)
		return @"Aug ";
	else if(monthNum == 9)
		return @"Sep ";
	else if(monthNum == 10)
		return @"Oct ";
	else if(monthNum == 11)
		return @"Nov ";
	else
		return @"Dec ";
}
+ (NSDate *) getNSDateForDay:(int)day forMonth:(int)month forYear:(int)year {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:comps];
    [comps release];
    [gregorian release];
    return date;
    
}
+ (NSString *)dateValueForCCD:(NSDate *)date
{
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    if (date == nil)
        return @"";
    
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
    
    unsigned int day = [comps day];
    unsigned int month = [comps month];
    unsigned int year = [comps year];
    
	NSMutableString *dateString = [NSMutableString stringWithCapacity:8];
	
	[dateString appendFormat:@"%4d",year];
	[dateString appendFormat:@"%02d",month];
	[dateString appendFormat:@"%02d",day];
	
	return dateString;
}
+ (NSString *)dateStringForCCD:(NSDate *)date
{
	NSMutableString *dateString = [NSMutableString stringWithCapacity:10];
	NSCalendar *gregorian = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    if (date == nil)
        return @"";
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
    
    unsigned int month = [comps month];
    unsigned int day = [comps day];
    unsigned int year = [comps year];
    
	[dateString appendFormat:@"%02d/",month];
	[dateString appendFormat:@"%02d/",day];
	[dateString appendFormat:@"%4d",year];
    
	return dateString;
}
@end