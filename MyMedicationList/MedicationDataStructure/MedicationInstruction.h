//
//  MedicationInstruction.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import <Foundation/Foundation.h>

typedef enum {
	As_Needed,
	As_Directed,
	At_Bedtime,
	In_The_Morning,
	In_The_Evening,
	On_Empty_Stomach,
	With_Meals,
	NumberOfInstructions
} MedicationDefinedInstruction;

@protocol MedicationInstructionProtocol;

@interface MedicationInstruction : NSObject<NSCoding,NSMutableCopying>

+ (NSString *)stringForDefinedInstruction:(MedicationDefinedInstruction)definedInstruction;
+ (MedicationDefinedInstruction)definedInstructionForString:(NSString *)definedInstructionString;


// Will choose defined or custom instruction initialization as appropriate
- (id)initWithInstruction:(NSString *)instruction;

- (id)initWithDefinedInstruction:(MedicationDefinedInstruction)definedInstruction;
- (id)initWithCustomInstruction:(NSString *)customInstuction;

- (BOOL)isDefinedInstruction;
- (BOOL)isCustomInstruction;

- (void)setDefinedInstruction:(MedicationDefinedInstruction)definedInstruction;
- (void)setCustomInstruction:(NSString *)customInstruction;

- (NSString *)printInstruction;

//- (NSString *)instruction;
- (NSString *)displayInstruction;

- (NSString *)origInstruction;
- (id)mutableCopy;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

@protocol MedicationInstructionProtocol <NSObject>
@required
- (NSString *)instruction;
@end
