//
//  MMLInsurance.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMLPersonData;

@interface MMLInsurance : NSManagedObject

@property (nonatomic, retain) NSData * backCardImage;
@property (nonatomic, retain) NSString * carrier;
@property (nonatomic, retain) NSData * frontCardImage;
@property (nonatomic, retain) NSString * groupNumber;
@property (nonatomic, retain) NSString * memberNumber;
@property (nonatomic, retain) NSString * rxGroup;
@property (nonatomic, retain) NSString * rxIN;
@property (nonatomic, retain) NSString * rxPCN;
@property (nonatomic, retain) NSData * originalFrontCardImage;
@property (nonatomic, retain) NSData * originalBackCardImage;
@property (nonatomic, retain) MMLPersonData *person;

@end
