//
//  MMLMedication.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MMLMedication.h"
#import "MMLCCDInfo.h"
#import "MMLConceptProperty.h"
#import "MMLIngredients.h"
#import "MMLMedicationAmount.h"
#import "MMLMedicationFrequency.h"
#import "MMLMedicationInstruction.h"
#import "MMLMedicationList.h"


@implementation MMLMedication

@dynamic stopDate;
@dynamic startDate;
@dynamic image;
@dynamic creationID;
@dynamic name;
@dynamic quantity;
@dynamic prescriberDate;
@dynamic prescriberFirstName;
@dynamic prescriberLastName;
@dynamic prescriberSuffix;
@dynamic repeats;
@dynamic conceptProperty;
@dynamic ccdInfo;
@dynamic medicationAmount;
@dynamic medicationFrequency;
@dynamic medicationInstruction;
@dynamic ingredientsArray;
@dynamic medicationList;

@end
