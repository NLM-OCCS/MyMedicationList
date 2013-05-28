//
//  CustomMedicationInstruction.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import "MedicationInstruction.h"

@interface CustomMedicationInstruction : NSObject <NSCoding,NSMutableCopying,MedicationInstructionProtocol> {    

}

@property (nonatomic, copy) NSString *customInstruction;

- (id)initWithCustomInstruction:(NSString *)customInstuction;

- (NSString *)instruction;

- (id)mutableCopy;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
