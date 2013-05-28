//
//  Date.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import <Foundation/Foundation.h>


@interface Date : NSObject<NSCoding,NSMutableCopying> {
	
}

@property (nonatomic, assign) unsigned int day;
@property (nonatomic, assign) unsigned int month;
@property (nonatomic, assign) unsigned int year;

+ (Date *)today;

- (id)initWithDay:(unsigned int)aDay Month:(unsigned int)aMonth Year:(unsigned int)aYear;
- (id)initWithString:(NSString *)dateString;

- (NSComparisonResult)compare:(Date *)anotherDate;

- (NSString *)printDate;

- (NSString *)displayDate;

// Make a copy of this Date object
- (id)mutableCopy;

// Archive and Unarchive this Date object
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
+ (NSDate *)getNSDate:(NSString *)dateString;
+ (NSDate *) getNSDateForDay:(int)day forMonth:(int)month forYear:(int)year ;
+ (NSString *)monthString:(int) monthNum;
+ (NSString *)dateValueForCCD:(NSDate *)date;
+ (NSString *)dateStringForCCD:(NSDate *)date;

@end