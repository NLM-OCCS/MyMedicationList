//
//  MMLCCDInfo.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMLMedication;

@interface MMLCCDInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * isClinicalDrug;
@property (nonatomic, retain) NSString * codeDisplayName;
@property (nonatomic, retain) NSString * codeDisplayNameRxCUI;
@property (nonatomic, retain) NSString * translationDisplayName;
@property (nonatomic, retain) NSString * ingredientName;
@property (nonatomic, retain) NSString * translationDisplayNameRxCUI;
@property (nonatomic, retain) NSString * brandName;
@property (nonatomic, retain) MMLMedication *medication;

@end
