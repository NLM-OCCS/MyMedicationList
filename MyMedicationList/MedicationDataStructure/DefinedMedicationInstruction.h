//
//  DefinedMedicationInstruction.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import <Foundation/Foundation.h>
#import "MedicationInstruction.h"

//@interface DefinedMedicationInstruction : MedicationInstruction<NSCoding,NSMutableCopying> {
@interface DefinedMedicationInstruction : NSObject <NSCoding,NSMutableCopying,MedicationInstructionProtocol> {    

}
@property (nonatomic, assign) MedicationDefinedInstruction definedInstruction;

+ (NSString *)stringForDefinedInstruction:(MedicationDefinedInstruction)definedInstruction;
+ (MedicationDefinedInstruction)definedInstructionForString:(NSString *)definedInstructionString;

+ (BOOL)isDefinedInstructionString:(NSString *)instructionString;

- (id)initWithDefinedInstruction:(MedicationDefinedInstruction)aDefinedInstruction;

- (NSString *)instruction;

- (id)mutableCopy;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
