//
//  MMLConceptProperty.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMLMedication;

@interface MMLConceptProperty : NSManagedObject

@property (nonatomic, retain) NSString * rxcui;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * synonym;
@property (nonatomic, retain) NSString * termtype;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * suppressflag;
@property (nonatomic, retain) NSString * umlsCUI;
@property (nonatomic, retain) MMLMedication *medication;

@end
