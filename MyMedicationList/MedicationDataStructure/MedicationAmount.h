//
//  MedicationAmount.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import <Foundation/Foundation.h>

enum MedicationAmountType
{	
    Tablet,
	Capsule,
    ML,
    Teaspoon,
    Drops,
	Inhalation,
	Units,
	NumberOfAmountTypes
};
typedef enum MedicationAmountType MedicationAmountType;

@interface MedicationAmount : NSObject<NSCoding,NSMutableCopying> {
	
}

@property (assign,nonatomic) MedicationAmountType amountType;
@property (assign,nonatomic) unsigned int quantity;

+ (NSString *)amountTypeStringForAmountType:(MedicationAmountType)amountType;

- (id)initWithAmountType:(MedicationAmountType)amountType Quantity:(NSUInteger)quantity;

- (NSString *)printAmount;

- (NSString *)displayAmount;

- (id) mutableCopy;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end
