//
//  ConceptProperty.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>


@interface ConceptProperty : NSObject<NSCoding,NSMutableCopying> {
}

@property (nonatomic,copy) NSString *rxcui;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *synonym;
@property (nonatomic,copy) NSString *termtype;
@property (nonatomic,copy) NSString *language;
@property (nonatomic,copy) NSString *suppressflag;
@property (nonatomic,copy) NSString *UMLSCUI;

- (id)init;

- (void)printConceptProperty;

- (id) mutableCopy;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
 
@end
