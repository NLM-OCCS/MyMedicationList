//
//  CCDParser.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "DDXML.h"
#import "MedicationAmount+CCDFunctionality.h"
#import "MedicationFrequency+CCDFunctionality.h"
#import "Date+CCDFunctionality.h"
#import "MMLMedication.h"
#import "Medication+CCDFunctionality.h"
#import "MMLMedicationList.h"
#import "MMLPersonData.h"
#import "NSString+XMLDataAdditions.h"
#import "CCDParser.h"
#import "CoreDataManager.h"

@implementation CCDParser
@synthesize parseString = _parseString;
@synthesize delegate = _delegate;

static const NSString *LastNameKey = @"LastNameKey";
static const NSString *FirstNameKey = @"FirstNameKey";
static const NSString *DateOfBirthKey = @"DateOfBirthKey";
static const NSString *GenderKey = @"GenderKey";
static const NSString *AddresLine = @"AddressLine";
static const NSString *City = @"City";
static const NSString *State = @"State";
static const NSString *Zip = @"zip";
static const NSString *CurrentMedicationKey = @"CurrentMedicationsKey";
static const NSString *PreviousMedicationKey = @"PreviousMedicationsKey";

- (id)init
{
    return [self initWithParseString:nil];
}

- (id)initWithParseString:(NSString *)parseString
{
    self = [super init];
    if(self){
        
        self.parseString = parseString;
        
    }
    
    return self;
}

- (void)dealloc {
    
    self.parseString = nil;
    self.delegate = nil;
    [super dealloc];
}


- (void)parseFailed
{
    if([_delegate respondsToSelector:@selector(ccdParserDidFail:)])
        [_delegate ccdParserDidFail:self];
}

- (DDXMLElement *)getElementForElementPath:(NSString *)xpath startingFromElement:(DDXMLElement *)rootElement
{
    
    NSError *error = nil;
    NSArray *foundElements = [rootElement nodesForXPath:[NSString stringWithFormat:@"./%@",xpath] error:&error];

    if(error)
    {
        NSLog(@"XPath: ./%@",xpath);
        return nil;
    }
    else if ([foundElements count] == 0)
        return nil;
    
    return [foundElements objectAtIndex:0];
}

- (NSArray *)getElementsForName:(NSString *)name startingFromElement:(DDXMLElement *)rootElement
{
    NSError *error = nil;
    NSArray *foundElements = [rootElement nodesForXPath:[NSString stringWithFormat:@".//%@",name] error:&error];
    if(error)
    {
        NSLog(@"Name: %@",name);
        return nil;
    }
    else if ([foundElements count] == 0)
        return nil;
    
    return foundElements;
}

- (DDXMLElement *)getElementForName:(NSString *)name startingFromElement:(DDXMLElement *)rootElement
{
    return [[self getElementsForName:name startingFromElement:rootElement] objectAtIndex:0];
}

- (NSString *)stringValueForElementPath:(NSString *)xpath fromElement:(DDXMLElement *)rootElement
{    
    return [[self getElementForElementPath:xpath startingFromElement:rootElement] stringValue];
}

- (NSString *)stringValueForElementPath:(NSString *)xpath forAttribute:(NSString *)attribute fromElement:(DDXMLElement *)rootElement
{
    DDXMLElement *foundElement = [self getElementForElementPath:xpath startingFromElement:rootElement];
    
    return [[foundElement attributeForName:attribute] stringValue];
}

- (NSString *)stringValueForElementName:(NSString *)name startingFromElement:(DDXMLElement *)rootElement
{
    return [[self getElementForName:name startingFromElement:rootElement] stringValue];
}

- (NSString *)stringValueForAttributeName:(NSString *)attribute inElement:(NSString *)namedElement startingFromElement:(DDXMLElement *)rootElement
{
    DDXMLElement *foundElement = [self getElementForName:namedElement startingFromElement:rootElement];
    
    return [[foundElement attributeForName:attribute] stringValue];    
}

- (NSDictionary *)parsePersonalInfoForRecord:(DDXMLElement *)record
{
    
    NSMutableDictionary *personalInfo = [NSMutableDictionary dictionary];
    
    NSString *familyName = [self stringValueForElementName:@"family" startingFromElement:record];
    
    if(familyName != nil)
        [personalInfo setObject:familyName forKey:LastNameKey];
    else
        return nil;
    
    NSString *givenName = [self stringValueForElementName:@"given" startingFromElement:record];
    
    if(givenName != nil)
        [personalInfo setObject:givenName forKey:FirstNameKey];
    else 
        return nil;
    
    
    NSString *dateOfBirthString = [self stringValueForAttributeName:@"value" inElement:@"birthTime" startingFromElement:record];
    if(dateOfBirthString != nil)
    {
        Date *dateOfBirth = [Date dateForCCDDateString:dateOfBirthString];
        [personalInfo setObject:dateOfBirth forKey:DateOfBirthKey];
    }
    DDXMLElement *foundElement = [self getElementForName:@"addr" startingFromElement:record];

    NSString *streetAdressLine = [self stringValueForElementPath:@"streetAddressLine" fromElement:foundElement];
    if (streetAdressLine != nil) {
        [personalInfo setObject:streetAdressLine forKey:AddresLine];
    }
    NSString *city = [self stringValueForElementPath:@"city" fromElement:foundElement];
    if (city != nil) {
        [personalInfo setObject:city forKey:City];
    }
    NSString *state = [self stringValueForElementPath:@"state" fromElement:foundElement];
    if (state != nil) {
        [personalInfo setObject:state forKey:State];
    }
    NSString *zip = [self stringValueForElementPath:@"postalCode" fromElement:foundElement];
    if (zip != nil) {
        [personalInfo setObject:zip forKey:Zip];
    }
    
    NSString *gender = [self stringValueForAttributeName:@"displayName" inElement:@"administrativeGenderCode" startingFromElement:record];
    
    if(gender != nil)
        [personalInfo setObject:gender forKey:GenderKey];
    else
        return nil;
    
    return personalInfo;
}

- (void)initializePerson:(MMLPersonData *)personData withPersonalInfo:(NSDictionary *)personalInfo
{
    personData.firstName = [personalInfo objectForKey:FirstNameKey];
    personData.lastName = [personalInfo objectForKey:LastNameKey];
    Date *dobDate = [personalInfo objectForKey:DateOfBirthKey];
    if (dobDate != nil) {
        personData.dateOfBirth = [Date getNSDateForDay:dobDate.day forMonth:dobDate.month forYear:dobDate.year];
    } else {
        personData.dateOfBirth = nil;
    }
    NSString *genderString = [personalInfo objectForKey:GenderKey];
    personData.streetAddress1 = [personalInfo objectForKey:AddresLine];
    personData.city = [personalInfo objectForKey:City];
    personData.state = [personalInfo objectForKey:State];
    personData.zip = [personalInfo objectForKey:Zip];
    
    
    if([genderString compare:@"Male" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        personData.gender = [NSNumber numberWithInt:0];
    else
        personData.gender = [NSNumber numberWithInt:1];
    if (personData.dateOfBirth == nil)
        personData.userId = [NSString stringWithFormat:@"%@%@%@",personData.lastName,personData.firstName,@"NoDOB"];
    else
        personData.userId = [NSString stringWithFormat:@"%@%@%@",personData.lastName,personData.firstName, [Date dateValueForCCD:personData.dateOfBirth ]];
}


- (NSString *)getIDNum:(NSString *)instructionString
{

    if ([instructionString length] > 20) {
        return [instructionString substringFromIndex:20];
    } else {
        return nil;
    }
}


- (void)setCurrentMedications:(MMLMedicationList *)currentMedications previousMedications:(MMLMedicationList *)previousMedications forEntries:(NSArray *)medicationEntries withInstructions:(NSDictionary *)patientInstructions
{
    NSLog(@"setCurrentMedications:previousMediations:forEntries:");
    
    for(DDXMLElement *entry in medicationEntries)
    {
        MMLMedication *medication = nil;
        
              
        medication = [[CoreDataManager coreDataManager] newMedication];
        
                NSString * startDateString = [self stringValueForElementPath:@"substanceAdministration/effectiveTime/low" forAttribute:@"value" fromElement:entry];
        
        Date *startDate = [Date dateForCCDDateString:startDateString];
        medication.startDate = [Date getNSDateForDay:startDate.day forMonth:startDate.month forYear:startDate.year];
        NSString *stopDateString = [self stringValueForElementPath:@"substanceAdministration/effectiveTime/high" forAttribute:@"value" fromElement:entry];
        
        if (stopDateString != nil && ![stopDateString isEqualToString:@""]) {
            Date *stopDate = [Date dateForCCDDateString:stopDateString];
            medication.stopDate = [Date getNSDateForDay:stopDate.day forMonth:stopDate.month forYear:stopDate.year];
        }
        NSString *frequencyString = nil;
        frequencyString = [self stringValueForElementPath:@"substanceAdministration/effectiveTime/period" forAttribute:@"value" fromElement:entry];
        
        if(frequencyString != nil)
        {
            MedicationFrequency *frequency = [MedicationFrequency frequencyForCCDFrequencyHourString:frequencyString];
            MMLMedicationFrequency *medFrequency = [[CoreDataManager coreDataManager] newFrequency];
            medFrequency.frequency = [NSNumber numberWithUnsignedInt:(unsigned int)frequency.frequency];
            medication.medicationFrequency = medFrequency;
        }
        NSString *amountQuantityString = nil;
        amountQuantityString = [self stringValueForElementPath:@"substanceAdministration/doseQuantity" forAttribute:@"value" fromElement:entry];
        
        if(amountQuantityString != nil)
        {
            NSString *amountTypeString = nil;
            amountTypeString = [self stringValueForElementPath:@"substanceAdministration/doseQuantity" forAttribute:@"unit" fromElement:entry];
            
            if(amountTypeString != nil)
            {
                MedicationAmount *amount = [MedicationAmount amountForCCDQuantityString:amountQuantityString typeString:amountTypeString];
                MMLMedicationAmount *medAmount = [[CoreDataManager coreDataManager] newamount];
                medAmount.amountType = [NSNumber numberWithInt:amount.amountType];
                medAmount.quantity = [NSNumber numberWithInt:amount.quantity];
                medication.medicationAmount = medAmount;
            }
        }
        NSString *instructionString = nil;
        instructionString = [self stringValueForElementPath:@"substanceAdministration/entryRelationship/act/text/reference" forAttribute:@"value" fromElement:entry];
        
        if((instructionString != nil)||(![instructionString isEqualToString:@""]))
        {
            NSString *instructionID = [self getIDNum:instructionString];
            
            NSString *referencedInstruction = [patientInstructions objectForKey:instructionID];
            
            MedicationInstruction *instruction = [[MedicationInstruction alloc] initWithInstruction:referencedInstruction];
            MMLMedicationInstruction *medInstruction = [[CoreDataManager coreDataManager]newInstruction];
            medInstruction.instruction = [instruction printInstruction];
            medication.medicationInstruction = medInstruction;
                
        }
        
        NSString *rxcuiString = [self stringValueForElementPath:@"substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code" forAttribute:@"code" fromElement:entry];
        if(rxcuiString != nil)
        {
            
            NSString *nameString = [self stringValueForElementPath:@"substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code" forAttribute:@"displayName" fromElement:entry];
            NSString *synonymString = [self stringValueForElementPath:@"substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code/translation" forAttribute:@"displayName" fromElement:entry];
            
            //ConceptProperty *conceptProperty = [[[ConceptProperty alloc] init] autorelease];
            MMLConceptProperty *conceptProperty = [[CoreDataManager coreDataManager]newConceptProperty];
            conceptProperty.name = nameString;
            conceptProperty.synonym = synonymString;
            conceptProperty.rxcui = rxcuiString;
            medication.conceptProperty = conceptProperty;
            if(([conceptProperty.synonym isEqualToString:@""])||(conceptProperty.synonym == nil)) {
                [medication setValue:[conceptProperty name] forKey:@"name"];
            } else {
                if ([conceptProperty.synonym length] > [conceptProperty.name length]) {
                    [medication setValue:[conceptProperty name] forKey:@"name"];
                }
                else {
                    [medication setValue:[conceptProperty synonym] forKey:@"name"];
                }
            }

        }
        // We have a free text entry
        else
        {
            NSLog(@"Free text entry parsing...");
            
            //ConceptProperty *conceptProperty = [[[ConceptProperty alloc] init] autorelease];
            MMLConceptProperty *conceptProperty = [[CoreDataManager coreDataManager]newConceptProperty];

            NSString *nameString = [self stringValueForElementPath:@"substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code/originalText" fromElement:entry];
            medication.name = nameString;
            conceptProperty.name = nameString;
            conceptProperty.synonym = conceptProperty.name;
            conceptProperty.rxcui = nil; // There is no rxcui for a free text medication, One consequence of this is the inability to download 
            medication.conceptProperty = conceptProperty;
            [[CoreDataManager coreDataManager] setMMLIngedients:nameString forMedication:medication];
           // medication.ingredients = [Medication parseIngredientString:nameString];
        }
        ////////////////////////////////////////////////////////////////////
        // Only proceed if we do not have a free text medication
        if (medication.conceptProperty.rxcui != nil) 
        {
            NSString *translationDisplayNameString = [self stringValueForElementPath:@"substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code/translation" forAttribute:@"displayName" fromElement:entry];
            
            MMLCCDInfo *ccdInfo = nil;
            
            // If we have a translation display name then we have a branded drug
            if(translationDisplayNameString != nil)
            {
                
                NSString *translationDisplayNameRxcuiString = [self stringValueForElementPath:@"substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code/translation" forAttribute:@"code" fromElement:entry];
                
                NSString *brandNameString = [self stringValueForElementPath:@"substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/name" fromElement:entry];
                
               // ccdInfo = [[CCDInfo alloc] initWithIsClinicalDrug:NO];
                ccdInfo = [[CoreDataManager coreDataManager]newCCDInfo];
                ccdInfo.isClinicalDrug = [NSNumber numberWithBool:NO];
                ccdInfo.translationDisplayName = translationDisplayNameString;
                ccdInfo.translationDisplayNameRxCUI = translationDisplayNameRxcuiString;
                ccdInfo.brandName = brandNameString;
            }
            else {
                //ccdInfo = [[CCDInfo alloc] initWithIsClinicalDrug:YES];
                ccdInfo = [[CoreDataManager coreDataManager]newCCDInfo];
                ccdInfo.isClinicalDrug = [NSNumber numberWithBool:YES];

            }
            
            NSString *codeDisplayNameString = [self stringValueForElementPath:@"substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code" forAttribute:@"displayName" fromElement:entry];
            
            NSString *codeDisplayNameRxcuiString = [self stringValueForElementPath:@"substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code" forAttribute:@"code" fromElement:entry];
            
            NSString *ingredientNameString = [self stringValueForElementPath:@"substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/originalText" fromElement:entry];
            ccdInfo.codeDisplayName = codeDisplayNameString;
            ccdInfo.codeDisplayNameRxCUI = codeDisplayNameRxcuiString;
            ccdInfo.ingredientName = ingredientNameString;
            
            medication.ccdInfo = ccdInfo;
            
            [[CoreDataManager coreDataManager] setMMLIngedients:ingredientNameString forMedication:medication];
        }
        medication.repeats = [NSNumber numberWithInt:[[self stringValueForElementPath:@"substanceAdministration/entryRelationship/supply/repeatNumber" forAttribute:@"value" fromElement:entry] intValue]];
        medication.quantity = [NSNumber numberWithInt:[[self stringValueForElementPath:@"substanceAdministration/entryRelationship/supply/quantity" forAttribute:@"value" fromElement:entry] intValue]];
        ///////
           // Prescription *prescription = (Prescription *)medication;
            medication.prescriberLastName = [self stringValueForElementPath:@"substanceAdministration/entryRelationship/supply/author/assignedAuthor/assignedPerson/name/family" fromElement:entry];
            medication.prescriberFirstName = [self stringValueForElementPath:@"substanceAdministration/entryRelationship/supply/author/assignedAuthor/assignedPerson/name/given" fromElement:entry];
            medication.prescriberSuffix = [self stringValueForElementPath:@"substanceAdministration/entryRelationship/supply/author/assignedAuthor/assignedPerson/name/suffix" fromElement:entry];
//////////            medication.telephoneNumber = [self stringValueForElementPath:@"substanceAdministration/entryRelationship/supply/author/assignedAuthor/telecom" forAttribute:@"value" fromElement:entry];
            
            NSString *prescribeDateString = [self stringValueForElementPath:@"substanceAdministration/entryRelationship/supply/author/time" forAttribute:@"value" fromElement:entry];
            NSLog(@"prescribeDateString = %@",prescribeDateString);
          //  Date *prescribeDate = [Date dateForCCDDateString:prescribeDateString];
/////            medication.prescribeDate = prescribeDate;
            
        /////           [medication printMedication];

        
        if(medication.stopDate != nil)
        {
            if([medication.stopDate compare:[NSDate date]] == NSOrderedDescending) {
                [currentMedications addMedicationListObject:medication];
            } else {
                [previousMedications addMedicationListObject:medication];
            }
        }
        else// if(medication.stopDate == nil)
            [currentMedications addMedicationListObject:medication];
    }
}

- (NSUInteger)entryCount:(MMLMedicationList *)medicationList
{
        
    return [medicationList.medicationList count];
}

- (NSDictionary *)parseMedicationInfoForComponent:(DDXMLElement *)component
{
    NSMutableDictionary *medicationInfo = [NSMutableDictionary dictionary];
    
    DDXMLElement *textElement = [self getElementForElementPath:@"structuredBody/component/section/text" startingFromElement:component];
    NSArray *componenetArray = [self getElementsForName:@"structuredBody/component/section" startingFromElement:component];
    DDXMLElement *medElement;
    if ([componenetArray count] > 1) {
        //1 first one is Insurance second one is medications
        textElement = [self getElementForElementPath:@"text" startingFromElement:[componenetArray objectAtIndex:1]];
        medElement = [componenetArray objectAtIndex:1];

    } else {
        textElement = [self getElementForElementPath:@"text" startingFromElement:[componenetArray objectAtIndex:0]];

     medElement = [componenetArray objectAtIndex:0];
    }
    NSArray *instructionElements = [self getElementsForName:@"content" startingFromElement:textElement];
    
    NSMutableDictionary *patientInstructions = [NSMutableDictionary dictionaryWithCapacity:[instructionElements count]];
    
    for(DDXMLElement *instructionElement in instructionElements)
        [patientInstructions setObject:[instructionElement stringValue] forKey:[self getIDNum:[[instructionElement attributeForName:@"ID"] stringValue]]];
    
    for(NSString *key in patientInstructions)
        NSLog(@"Instruction ID:%@   Value:%@",key,[patientInstructions objectForKey:key]);
    
    
    NSArray *medicationDataEntries = [self getElementsForName:@"entry" startingFromElement:medElement];
    
    //for(DDXMLElement *entry in medicationDataEntries)
    //    NSLog(@"Name of element: %@",[entry name]);
    
    if([medicationDataEntries count] == 0)
        return medicationInfo;
    
    
    MMLMedicationList *currentMedications =  [[CoreDataManager coreDataManager] newMedicationList];//[[[MedicationList alloc] init] autorelease];
    MMLMedicationList *previousMedications = [[CoreDataManager coreDataManager] newMedicationList];//[[[MedicationList alloc] init] autorelease];

    [self setCurrentMedications:currentMedications previousMedications:previousMedications forEntries:medicationDataEntries withInstructions:patientInstructions];    
    
    
    // Total number of medications and prescriptions must equal the number of entries in the CCD otherwise
    // we had a failure parsing one of the medications/prescriptions
    if([self entryCount:currentMedications]+[self entryCount:previousMedications] != [medicationDataEntries count])
        return nil;
    else
    {
        if([currentMedications.medicationList count] != 0)
            [medicationInfo setObject:currentMedications forKey:CurrentMedicationKey];
        if([previousMedications.medicationList count] != 0)
            [medicationInfo setObject:previousMedications forKey:PreviousMedicationKey];
    }
    
    return medicationInfo;
}

- (void)initializePerson:(MMLPersonData *)personData withMedicationInfo:(NSDictionary *)medicationInfo
{
    NSLog(@"initializePerson:withMedicationInfo:");
    MMLMedicationList *currentMedications =  [medicationInfo objectForKey:CurrentMedicationKey];
    MMLMedicationList *previousMedications =  [medicationInfo objectForKey:PreviousMedicationKey];
    
        
   personData.currentMedicationList = currentMedications;
   personData.discontinuedMedicationList = previousMedications;
}
- (void) parseInsuranceInfoForComponent:(DDXMLElement *) component withPersonData:(MMLPersonData *)personData{
    
    DDXMLElement *insuranceElement = [self getElementForElementPath:@"structuredBody/component/section/entry/act/entryRelationship/act" startingFromElement:component];
    NSString *pcn = [self stringValueForElementPath:@"id" forAttribute:@"extension" fromElement:insuranceElement];
    NSArray *elementsPath =  [self getElementsForName:@"performer/assignedEntity/id" startingFromElement:insuranceElement];
    NSString *bin;
    NSString *group;
    if (elementsPath != nil && [elementsPath count] > 0) {
        for (int i=0; i < [elementsPath count ];i++ ) {
            NSString *root = [[[elementsPath objectAtIndex:i] attributeForName:@"root"] stringValue];
            // [self stringValueForElementPath:@"id" forAttribute:@"root" fromElement:[elementsPath objectAtIndex:i] ];
            if ([root isEqualToString:@"2.16.840.1.113883.3.88.3.1"]) {
                bin = [[[elementsPath objectAtIndex:i] attributeForName:@"extension"] stringValue];
                //[self stringValueForElementPath:@"id" forAttribute:@"extension" fromElement:[elementsPath objectAtIndex:i] ];
            } else {
                group = [[[elementsPath objectAtIndex:i] attributeForName:@"extension"] stringValue];
                //[self stringValueForElementPath:@"id" forAttribute:@"extension" fromElement:[elementsPath objectAtIndex:i] ];
            }
        }
    }
    NSString *insuranceName =     [self stringValueForElementName:@"performer/assignedEntity/representedOrganization/name" startingFromElement:insuranceElement];
    //NSString *effectiveDate = [self stringValueForElementPath:@"participant/time/low" forAttribute:@"value" fromElement:insuranceElement ];
    
    
    
    NSString *memberID = [self stringValueForElementPath:@"participant/participantRole/id" forAttribute:@"extension" fromElement:insuranceElement ];
    
    NSString *giveName = [self stringValueForElementName:@"participant/participantRole/playingEntity/name/given"  startingFromElement:insuranceElement ];
    
    NSString *lastName = [self stringValueForElementName:@"participant/participantRole/playingEntity/name/family"  startingFromElement:insuranceElement ];
    MMLInsurance *insurance = [[CoreDataManager coreDataManager] newInsurance];
    if (insuranceName != nil) 
        [insurance setCarrier:insuranceName];
    if (giveName != nil) 
        //       [ setMemberFirstName:giveName];
        if (lastName != nil) {
            //     [insuranceInfo setMemberLastName:lastName];
        }
    if (pcn != nil) {
        [insurance setRxPCN:pcn];
    }
    if (group !=nil) {
        [insurance setRxGroup:group];
    }
    if (bin !=nil) {
        [insurance setRxIN:bin];
    }
    
     if (memberID !=nil) {
        [insurance setMemberNumber:memberID];
    }
    personData.insurance = insurance;
    
}


- (void)parse
{
    NSLog(@"Parsing...");
    if(_parseString == nil){
        NSLog(@"Parse string was nil...");
        [self parseFailed];
        return;
    }
    
    // Remove the default namespace from the string before processing happens
    // This avoids the errors associated with using XPath on document with a default namespace
    NSString *processXMLString = [_parseString removeDefaultNamespace];
    
    // Replace the current string with the cleaned string
    self.parseString = processXMLString;
    
    // Holds the parsed data about the person
    MMLPersonData *personData = [[CoreDataManager coreDataManager] newPersonData];
    
    NSLog(@"XML:\n%@",processXMLString);
    
    NSError *error = nil;
    
    // Initialize the document with the sanitized input string (see above comment about removing default namespace)
    DDXMLDocument *doc = [[[DDXMLDocument alloc] initWithXMLString:_parseString options:0 error:&error] autorelease];
    
    // If there is a problem parsing the string into a document there is nothing more that can be done
    if(error)
    {
        NSLog(@"Reading into DDXMLDocument failed...");
        [self parseFailed];
        return;
    }
    
    // We will perform all queries relative to the top level element, in this case this is <ClinicalDocument>
    DDXMLElement *root = [doc rootElement];
    
    // The recordTarget is the patient, the children of this node contain the personal information
    // about the patient
    DDXMLElement *recordTarget = [self getElementForName:@"recordTarget" startingFromElement:root];
    
    // Get the personal data contained in the CCD, currently this includes the first name, last name and the gender of the patient
    NSDictionary *personalInfo = [self parsePersonalInfoForRecord:recordTarget];
    
    if(personalInfo == nil)
    {
        NSLog(@"Could not parse the personal info...");
        [self parseFailed];
        return;
    }
    else 
        [self initializePerson:personData withPersonalInfo:personalInfo];
    
    // The 'component' part of the CCD contains the medication 'entry's and some data about the instructions they contain
    NSArray *componenetArray = [self getElementsForName:@"component" startingFromElement:root];
    DDXMLElement *component;
   // NSDictionary *insDictionary = nil;
    if (componenetArray!= nil && [componenetArray count ] > 0) {
        // Check the first section if the section is of type 
        DDXMLElement *component1 = [componenetArray objectAtIndex:0];
        NSString *title = [self stringValueForElementName:@"title" startingFromElement:component1];;
        if ([title isEqualToString:@"Insurance"]) {
            // This is a insurance  
            [self parseInsuranceInfoForComponent:[componenetArray objectAtIndex:0] withPersonData:personData];
            
            component = [componenetArray objectAtIndex:1];
        } else {
            component = [componenetArray objectAtIndex:0];
        }
        
    }

    component = [self getElementForName:@"component" startingFromElement:root];
    
    NSDictionary *medicationInfo = [self parseMedicationInfoForComponent:component];
    
    if(medicationInfo == nil)
    {
        NSLog(@"The medicationInfo came back nil.");
        NSLog(@"Could not parse the medical info...");
        [self parseFailed];
        return;
    }
    else 
        [self initializePerson:personData withMedicationInfo:medicationInfo];
    
    // Return the parsed data in person object
    if([_delegate respondsToSelector:@selector(ccdParser:didParsePerson:)])
        [_delegate ccdParser:self didParsePerson:personData];
    
}
@end
