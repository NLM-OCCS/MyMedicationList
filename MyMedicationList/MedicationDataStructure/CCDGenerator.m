//
//  CCDGenerator.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "ConceptProperty+CCDFunctionality.h"
#import "Date+CCDFunctionality.h"
#import "MedicationAmount+CCDFunctionality.h"
#import "MedicationFrequency+CCDFunctionality.h"
#import "MedicationInstruction+CCDFunctionality.h"
#import "CCDInfo.h"
#import "MMLMedicationList.h"
#import "MMLMedication.h"
#import "MMLPersonData.h"
#import "CCDGenerator.h"

DDXMLElement *addNodeToTree(DDXMLElement *root, NSString *elementName, NSArray *attributeNames, NSArray *attributeValueStrings);
void addEntryToTree(DDXMLElement *entryRootElement, MMLMedication *medication);
void addContainerEntryToTree(DDXMLElement *entryRootElement, MMLMedication *medContainer);
DDXMLElement *addPreambleToDocument(DDXMLElement *root, MMLPersonData *person);
void addTableToTree(DDXMLElement *tableRootElement, NSSet *medicationList, NSString *tableName);
void addInsuranceElement(DDXMLElement *entryRootElement, MMLPersonData *person);
NSString *genderString(NSNumber *gender);
NSString *genderInitial(NSNumber *gender);
@implementation CCDGenerator

NSString *genderString(NSNumber *gender)
{
    if([gender intValue] == 0)
		return @"Male";
	else
		return @"Female";
}

NSString *genderInitial(NSNumber *gender)
{
    if([gender intValue]== 0)
		return @"M";
	else
		return @"F";
}
+ (NSString *)CCDStringForPerson:(MMLPersonData *)person
{

    
	DDXMLDocument* document = [[DDXMLDocument alloc] initWithXMLString:@"<ClinicalDocument xmlns=\"urn:hl7-org:v3\"/>" options:0 error:nil]; 
    
	DDXMLElement* root = [document rootElement];

    DDXMLElement *element = addPreambleToDocument(root, person);
    addInsuranceElement(element, person);
    DDXMLElement *sectionElement = addNodeToTree(element, @"section", nil, nil);
	addNodeToTree(sectionElement, @"templateId", [NSArray arrayWithObject:@"root"], [NSArray arrayWithObject:@"2.16.840.1.113883.10.20.1.8"]);
	addNodeToTree(sectionElement, @"code", [NSArray arrayWithObjects:@"displayName",@"codeSystem",@"code",nil],
				  [NSArray arrayWithObjects:@"History of medication use",@"2.16.840.1.113883.6.1",@"10160-0",nil]);
	[addNodeToTree(sectionElement, @"title", nil, nil) setStringValue:@"Medications"];
	DDXMLElement *tableElement = addNodeToTree(sectionElement, @"text", nil, nil);
    NSSet *currentMedications = person.currentMedicationList.medicationList;
    NSSet *discontinuedMedications = person.discontinuedMedicationList.medicationList;
    for(MMLMedication *medication in currentMedications)
    {
        if(medication.medicationInstruction != nil)
        {
            element = addNodeToTree(tableElement, @"content", [NSArray arrayWithObject:@"ID"],
                                    [NSArray arrayWithObject:[NSString stringWithFormat:@"patient_instruction-%d",[medication.creationID intValue]]]);
            [element setStringValue:[medication.medicationInstruction valueForKey:@"instruction" ]];
        }
	}
	
    for(MMLMedication *medication in  discontinuedMedications)
    {
        if(medication.medicationInstruction != nil)
        {
            element = addNodeToTree(tableElement, @"content", [NSArray arrayWithObject:@"ID"],
                                    [NSArray arrayWithObject:[NSString stringWithFormat:@"patient_instruction-%d",[medication.creationID intValue]]]);
            [element setStringValue:[medication.medicationInstruction valueForKey:@"instruction" ]];
        }
    }

	
	addTableToTree(tableElement,person.currentMedicationList.medicationList,@"Current Medications");
	addTableToTree(tableElement,person.discontinuedMedicationList.medicationList,@"Previous Medications");
    
	for(MMLMedication *medication in currentMedications)
		addContainerEntryToTree(sectionElement, medication);
    
	
	for(MMLMedication *medication in discontinuedMedications)
		addContainerEntryToTree(sectionElement, medication);

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Calling copy on after XMLStringWithOptions resulted in a 1 KB leak
    NSString *documentString = [document XMLStringWithOptions:(DDXMLNodePrettyPrint|DDXMLNodeCompactEmptyElement)];
    [document release]; 
    
    // Artificially adds stylesheet information
    NSRange endHeaderRange = [documentString rangeOfString:@"?>"];
	NSUInteger endHeaderIndex = endHeaderRange.location + endHeaderRange.length;
	return [NSString stringWithFormat:@"%@\n%@%@",[documentString substringToIndex:endHeaderIndex],
            @"<?xml-stylesheet type=\"text/xsl\" href=\"http://mml.nlm.nih.gov/styles/mml.xsl\"?>",
            [documentString substringFromIndex:endHeaderIndex]];    
}

+ (NSString *)CCDTableForPerson:(MMLPersonData *)person
{
    DDXMLDocument* document = [[DDXMLDocument alloc] initWithXMLString:@"<ClinicalDocument xmlns=\"urn:hl7-org:v3\"/>" options:0 error:nil]; 
    
	DDXMLElement* root = [document rootElement];
    
    DDXMLElement *element = addPreambleToDocument(root, person);
    
    DDXMLElement *sectionElement = addNodeToTree(element, @"section", nil, nil);
	addNodeToTree(sectionElement, @"templateId", [NSArray arrayWithObject:@"root"], [NSArray arrayWithObject:@"2.16.840.1.113883.10.20.1.8"]);
	addNodeToTree(sectionElement, @"code", [NSArray arrayWithObjects:@"displayName",@"codeSystem",@"code",nil],
				  [NSArray arrayWithObjects:@"History of medication use",@"2.16.840.1.113883.6.1",@"10160-0",nil]);
	[addNodeToTree(sectionElement, @"title", nil, nil) setStringValue:@"Medications"];
	DDXMLElement *tableElement = addNodeToTree(sectionElement, @"text", nil, nil);
    
    // Medication Containers are sent here so that both medications and prescriptions will be handled
	addTableToTree(tableElement,person.currentMedicationList.medicationList,@"Current Medications");
	addTableToTree(tableElement,person.discontinuedMedicationList.medicationList,@"Previous Medications");
    
    // Calling copy on after XMLStringWithOptions resulted in a 1 KB leak
    NSString *documentString = [document XMLStringWithOptions:(DDXMLNodePrettyPrint|DDXMLNodeCompactEmptyElement)];
    [document release]; 
    
    // Artificially adds stylesheet information
    NSRange endHeaderRange = [documentString rangeOfString:@"?>"];
	NSUInteger endHeaderIndex = endHeaderRange.location + endHeaderRange.length;
	return [NSString stringWithFormat:@"%@\n%@%@",[documentString substringToIndex:endHeaderIndex],
            @"<?xml-stylesheet type=\"text/xsl\" href=\"http://mml.nlm.nih.gov/styles/mml.xsl\"?>",
            [documentString substringFromIndex:endHeaderIndex]];
}

@end

DDXMLElement *addNodeToTree(DDXMLElement *root, NSString *elementName, NSArray *attributeNames, NSArray *attributeValueStrings)
{
 
    DDXMLElement *newElement = nil;
	if(elementName == nil)
		return nil;
	else {
		newElement = [[DDXMLElement alloc] initWithName:elementName];
        
		if((attributeNames!=nil)&&(attributeValueStrings!=nil))
		{
			// Loop through as many attribute - stringValue pairs as were passed in
			// If the user passes in more of either attributes or string values then
			// we only use the pairs that exist and ignore the rest
			for(int i = 0; i < MIN([attributeNames count],[attributeValueStrings count]); i++)
				[newElement addAttributeWithName:[attributeNames objectAtIndex:i] stringValue:[attributeValueStrings objectAtIndex:i]];
		}
		
		[root addChild:newElement];
        
        // This gets rid of the memory leaks but I think makes you vulnerable to bad access if the autorelease pool collects before
        // you are finished
        [newElement autorelease];
        // This caused the DDXMLElement class of root to spontaneously turn into NSArray which caused an exception
        //[newElement release];        
	}
	
	return newElement;
}

void addEntryToTree(DDXMLElement *entryRootElement, MMLMedication *medication)
{
    DDXMLElement *entryElement = addNodeToTree(entryRootElement, @"entry", nil, nil);
    
    DDXMLElement *substanceElement;
    if ([medication isMemberOfClass:[MMLMedication class]])
        substanceElement = addNodeToTree(entryElement, @"substanceAdministration", [NSArray arrayWithObject:@"moodCode"],[NSArray arrayWithObject:@"EVN"]);
    else
        substanceElement = addNodeToTree(entryElement, @"substanceAdministration", [NSArray arrayWithObject:@"moodCode"],[NSArray arrayWithObject:@"INT"]);
    
    addNodeToTree(substanceElement, @"templateId", [NSArray arrayWithObject:@"root"], [NSArray arrayWithObject:@"2.16.840.1.113883.10.20.1.24"]);
    DDXMLElement *element = addNodeToTree(substanceElement, @"effectiveTime", [NSArray arrayWithObjects:@"xmlns:xsi",@"xsi:type",nil], 
                                          [NSArray arrayWithObjects:@"http://www.w3.org/2001/XMLSchema-instance",@"IVL_TS",nil]);
    
    
    if(medication.startDate != nil)
        addNodeToTree(element, @"low", [NSArray arrayWithObject:@"value"], [NSArray arrayWithObject:[Date dateValueForCCD:medication.startDate]]);
    if(medication.stopDate != nil)
        addNodeToTree(element, @"high", [NSArray arrayWithObject:@"value"], [NSArray arrayWithObject:[Date dateValueForCCD:medication.stopDate]]);
    
    
    if(medication.medicationFrequency != nil)
    {
        element = addNodeToTree(substanceElement, @"effectiveTime", [NSArray arrayWithObjects:@"xmlns:xsi",@"xsi:type",@"institutionSpecified",nil], 
                                [NSArray arrayWithObjects:@"http://www.w3.org/2001/XMLSchema-instance",@"PIVL_TS",@"true",nil]);
        addNodeToTree(element, @"period", [NSArray arrayWithObjects:@"value",@"unit",nil], 
                      [NSArray arrayWithObjects:[[[[MedicationFrequency alloc] initWithFrequency:[[medication.medicationFrequency valueForKey:@"frequency" ] intValue]] autorelease] hourFrequencyStringForCCD],@"h",nil]);
    }
    
    if(medication.medicationAmount != nil)
    {
        MedicationAmount  *medAmount = [[[MedicationAmount alloc] initWithAmountType:[[medication.medicationAmount valueForKey:@"amountType"] intValue] Quantity:[[medication.medicationAmount valueForKey:@"quantity"] intValue]] autorelease];
        NSString *amountQuantityString = [medAmount amountQuantityStringForCCD];
        NSString *amountTypeString = [medAmount amountTypeStringForCCD];
        if([medAmount hasUnitStringForCCD])
        {
            NSString* typeCode = [medAmount NCIThesaurusCodeForAmountType];
            addNodeToTree(substanceElement, @"doseQuantity", [NSArray arrayWithObjects:@"value",@"unit",nil], 
                          [NSArray arrayWithObjects:amountQuantityString,amountTypeString,nil]);
            addNodeToTree(substanceElement, @"administrationUnitCode", [NSArray arrayWithObjects:@"displayName",@"codeSystemName",@"codeSystem",@"code",nil], 
                          [NSArray arrayWithObjects:amountTypeString,@"NCI Thesaurus",@"2.16.840.1.113883.3.26.1.1",typeCode,nil]);
        }
        else
            addNodeToTree(substanceElement, @"doseQuantity", [NSArray arrayWithObject:@"value"], 
                          [NSArray arrayWithObject:amountQuantityString]);
    }
    
    element = addNodeToTree(substanceElement, @"consumable", nil, nil);
    DDXMLElement *manufacturedProductElement = addNodeToTree(element, @"manufacturedProduct", nil, nil);
    addNodeToTree(manufacturedProductElement, @"templateId", [NSArray arrayWithObject:@"root"], 
                  [NSArray arrayWithObject:@"2.16.840.1.113883.10.20.1.53"]);
    
    DDXMLElement *manufacturedMaterialElement = addNodeToTree(manufacturedProductElement, @"manufacturedMaterial", nil, nil);
    
    // If there is not RXCUI then we have a free text medication
    if(medication.conceptProperty ==nil || [medication.conceptProperty valueForKey:@"rxcui"] == nil)
    {
        element = addNodeToTree(manufacturedMaterialElement, @"code", nil, nil);
        [addNodeToTree(element, @"originalText", nil, nil) setStringValue:[medication.conceptProperty valueForKey:@"name"]];
    }
    else
    {
        // This is where the information from the CCD info is handled
        NSLog(@"Medication Name is %@",medication.name);
        MMLCCDInfo *ccdInfo = medication.ccdInfo;
        element = addNodeToTree(manufacturedMaterialElement, @"code", [NSArray arrayWithObjects:@"displayName",@"codeSystemName",@"codeSystem",@"code",nil], 
                                [NSArray arrayWithObjects:[ccdInfo valueForKey:@"codeDisplayName"],@"RxNorm",@"2.16.840.1.113883.6.88",[ccdInfo valueForKey:@"codeDisplayNameRxCUI"],nil]);
        [addNodeToTree(element, @"originalText", nil, nil) setStringValue:[ccdInfo valueForKey:@"ingredientName"]];
        NSNumber *isClinicalDrug = [ccdInfo valueForKey:@"isClinicalDrug"];
        if(isClinicalDrug == nil || ([ccdInfo valueForKey:@"isClinicalDrug"] != nil && ![isClinicalDrug boolValue]))
        {
            // TODO: I believe this is a duplicate statement so you can erase it, not sure though.
            //[addNodeToTree(element, @"originalText", nil, nil) setStringValue:medication.ccdInfo.ingredientName];
            
            addNodeToTree(element, @"translation", [NSArray arrayWithObjects:@"displayName",@"codeSystemName",@"codeSystem",@"code",nil],
                          [NSArray arrayWithObjects:[ccdInfo valueForKey:@"translationDisplayName"],@"RxNorm",@"2.16.840.1.113883.6.88",[ccdInfo valueForKey:@"translationDisplayNameRxCUI"],nil]);
            
            [addNodeToTree(manufacturedMaterialElement, @"name",nil,nil) setStringValue:[ccdInfo valueForKey:@"brandName"]];
        }
    }
    
    if(medication.medicationInstruction != nil)
    {
        element = addNodeToTree(substanceElement, @"entryRelationship", [NSArray arrayWithObjects:@"typeCode",@"inversionInd",nil],
                                [NSArray arrayWithObjects:@"SUBJ",@"true",nil]);
        DDXMLElement *actElement = addNodeToTree(element, @"act", [NSArray arrayWithObjects:@"moodCode",@"classCode",nil], 
                                                 [NSArray arrayWithObjects:@"INT",@"ACT",nil]);
        
        addNodeToTree(actElement, @"templateId", [NSArray arrayWithObject:@"root"], 
                      [NSArray arrayWithObject:@"2.16.840.1.113883.10.20.1.49"]);
        element = addNodeToTree(actElement, @"text", nil, nil);
        addNodeToTree(element, @"reference",[NSArray arrayWithObject:@"value"], 
                      [NSArray arrayWithObject:[NSString stringWithFormat:@"patient_instruction-%d",[medication.creationID intValue]]]);
    }  
}

void addContainerEntryToTree(DDXMLElement *entryRootElement, MMLMedication *medication)
{
    if(medication != nil)
        addEntryToTree(entryRootElement, medication);
}

DDXMLElement *addPreambleToDocument(DDXMLElement *root, MMLPersonData *person)
{
    addNodeToTree(root,@"code",[NSArray arrayWithObjects:@"displayName",@"codeSystem",@"code",nil],
                  [NSArray arrayWithObjects:@"Summarization of episode note",@"2.16.840.1.113883.6.1",@"34133-9",nil]);

    DDXMLElement *element;

    element = addNodeToTree(root,@"recordTarget",nil,nil);
    element = addNodeToTree(element, @"patientRole", nil, nil);
    DDXMLElement *patientElement = addNodeToTree(element, @"patient", nil, nil);
    element = addNodeToTree(patientElement, @"name", nil, nil);
        
    [addNodeToTree(element, @"family", nil, nil) setStringValue:(person.lastName != nil) ? person.lastName : @""];

    [addNodeToTree(element, @"given", nil, nil) setStringValue:(person.firstName != nil) ? person.firstName : @""];

    addNodeToTree(patientElement, @"birthTime", [NSArray arrayWithObject:@"value"], 
                  [NSArray arrayWithObject:(person.dateOfBirth != nil) ? [Date dateValueForCCD:person.dateOfBirth ] : @""]);
    
    addNodeToTree(patientElement,@"administrativeGenderCode",[NSArray arrayWithObjects:@"displayName",@"codeSystem",@"code",nil],
                  [NSArray arrayWithObjects:genderString([person gender]),@"2.16.840.1.113883.5.1",genderInitial(person.gender),nil]);

    if ([person streetAddress1] != nil) {
        DDXMLElement *addr = addNodeToTree(element, @"addr", [NSArray arrayWithObject:@"use"], [NSArray arrayWithObject:@"HP"]);
        NSString *address;
        if ([person streetAddress2] != nil && ![[person streetAddress2] isEqualToString:@""]) {
            address = [NSString stringWithFormat:@"%@ %@",[person streetAddress1],[person streetAddress2] ];
        } else {
            address = [person streetAddress1];
        }
        [addNodeToTree(addr, @"streetAddressLine", nil,nil) setStringValue:address ];
        
        if ([person city]  != nil) {
            [addNodeToTree(addr, @"city", nil,nil) setStringValue:[person city] ];
        } else {
            [addNodeToTree(addr, @"city", nil,nil) setStringValue:@""];
        }
        if ([person state]  != nil) {
            [addNodeToTree(addr, @"state", nil,nil) setStringValue:[person state]];
        } else {
            [addNodeToTree(addr, @"state", nil,nil) setStringValue:@""];
        }
        if ([person zip] != nil) {
            [addNodeToTree(addr, @"postalCode", nil,nil) setStringValue:[person zip]];
        } else {
            [addNodeToTree(addr, @"postalCode", nil,nil) setStringValue:@""];
        }
        [addNodeToTree(addr, @"country", nil,nil) setStringValue:@"US"];
        
    }

    element = addNodeToTree(root,@"component",nil,nil);
    element = addNodeToTree(element, @"structuredBody", nil, nil);
    element = addNodeToTree(element, @"component", nil, nil);	
    return element;
}

void addTableToTree(DDXMLElement *tableRootElement, NSSet *medicationList, NSString *tableName)
{
    if([medicationList count] == 0)
		return;
	
	DDXMLElement *element;
	
	element = addNodeToTree(tableRootElement, @"paragraph", [NSArray arrayWithObject:@"styleCode"], [NSArray arrayWithObject:@"Bold"]);
	[element setStringValue:tableName];
	addNodeToTree(element, @"br", nil, nil);
	
	DDXMLElement *tableBaseElement = addNodeToTree(tableRootElement, @"table", [NSArray arrayWithObjects:@"width",@"border",nil], [NSArray arrayWithObjects:@"100%",@"1",nil]);
	addNodeToTree(tableBaseElement, @"col", [NSArray arrayWithObject:@"width"], [NSArray arrayWithObject:@"30%"]);
	addNodeToTree(tableBaseElement, @"col", [NSArray arrayWithObject:@"width"], [NSArray arrayWithObject:@"10%"]);
	addNodeToTree(tableBaseElement, @"col", [NSArray arrayWithObject:@"width"], [NSArray arrayWithObject:@"10%"]);
	addNodeToTree(tableBaseElement, @"col", [NSArray arrayWithObject:@"width"], [NSArray arrayWithObject:@"10%"]);
	addNodeToTree(tableBaseElement, @"col", [NSArray arrayWithObject:@"width"], [NSArray arrayWithObject:@"10%"]);
	addNodeToTree(tableBaseElement, @"col", [NSArray arrayWithObject:@"width"], [NSArray arrayWithObject:@"30%"]);
	
	DDXMLElement *tableHeadElement = addNodeToTree(tableBaseElement, @"thead",nil,nil);
	element = addNodeToTree(tableHeadElement, @"tr", nil, nil);
	[addNodeToTree(element, @"th", nil, nil) setStringValue:@"Name of Medication"];
	[addNodeToTree(element, @"th", nil, nil) setStringValue:@"Start Date"];
	[addNodeToTree(element, @"th", nil, nil) setStringValue:@"Stop Date"];
	[addNodeToTree(element, @"th", nil, nil) setStringValue:@"Amount Each Time"];
	[addNodeToTree(element, @"th", nil, nil) setStringValue:@"Frequency"];
	[addNodeToTree(element, @"th", nil, nil) setStringValue:@"Instruction"];
	
	DDXMLElement *tableBodyElement = addNodeToTree(tableBaseElement, @"tbody", nil, nil);
	
	for(MMLMedication *medication in medicationList)
	{
        if(medication != nil)
        {
            element = addNodeToTree(tableBodyElement, @"tr", nil, nil);
            [addNodeToTree(element, @"td", nil, nil) setStringValue:[medication name]];
            [addNodeToTree(element, @"td", nil, nil) setStringValue:[Date dateStringForCCD:medication.startDate]];
            [addNodeToTree(element, @"td", nil, nil) setStringValue:[Date dateStringForCCD:medication.stopDate ]];
            if (medication.medicationAmount != nil) {
                    MedicationAmount  *medAmount = [[[MedicationAmount alloc] initWithAmountType:[[medication.medicationAmount valueForKey:@"amountType"] intValue] Quantity:[[medication.medicationAmount valueForKey:@"quantity"] intValue]] autorelease];
                 [addNodeToTree(element, @"td", nil, nil) setStringValue:[medAmount amountStringForCCD]];
            } else {
                [addNodeToTree(element, @"td", nil, nil) setStringValue:@"" ];
            }
            if (medication.medicationFrequency != nil) {
                MedicationFrequency  *frequency = [[[MedicationFrequency alloc] initWithFrequency:[[medication.medicationFrequency valueForKey:@"frequency" ] intValue]] autorelease];
                [addNodeToTree(element, @"td", nil, nil) setStringValue:[frequency frequencyStringForCCD]];
            } else {
                [addNodeToTree(element, @"td", nil, nil) setStringValue:@""];
            }
            if (medication.medicationInstruction != nil) {
                MedicationInstruction *instruction = [[[MedicationInstruction alloc] initWithInstruction:[medication.medicationInstruction valueForKey:@"instruction"]] autorelease];
                 [addNodeToTree(element, @"td", nil, nil) setStringValue:[instruction instructionStringForCCD]];
                
            }else {
                [addNodeToTree(element, @"td", nil, nil) setStringValue:@"" ];
            }
        }
	}
	
	element = addNodeToTree(tableRootElement, @"paragraph", nil, nil);
	addNodeToTree(element, @"br", nil, nil);
	addNodeToTree(element, @"br", nil, nil);
	addNodeToTree(element, @"br", nil, nil);
}
void addInsuranceElement(DDXMLElement *entryRootElement, MMLPersonData *person) {
    
   
    MMLInsurance *insurance = person.insurance;
    
    if ([insurance valueForKey:@"carrier"] == nil || [[insurance valueForKey:@"carrier"] isEqualToString:@""] ||
        [insurance valueForKey:@"memberNumber"] == nil || [[insurance valueForKey:@"memberNumber"] isEqualToString:@""] || 
        [insurance valueForKey:@"rxIN"] == nil || [[insurance valueForKey:@"rxIN"] isEqualToString:@""] ||
        [insurance valueForKey:@"rxPCN"] == nil || [[insurance valueForKey:@"rxPCN"] isEqualToString:@""] || 
        [insurance valueForKey:@"rxGroup"] == nil || [[insurance valueForKey:@"rxGroup"] isEqualToString:@""] ) {
        return;
    }
    
	DDXMLElement *sectionElement = addNodeToTree(entryRootElement, @"section", nil, nil);
	
    addNodeToTree(sectionElement, @"templateId", [NSArray arrayWithObject:@"root"], [NSArray arrayWithObject:@"2.16.840.1.113883.10.20.1.9"]);
	addNodeToTree(sectionElement, @"code", [NSArray arrayWithObjects:@"displayName",@"codeSystem",@"code",nil],
				  [NSArray arrayWithObjects:@"Payers",@"2.16.840.1.113883.6.1",@"48768-6",nil]);
	[addNodeToTree(sectionElement, @"title", nil, nil) setStringValue:@"Insurance"];
    
    addNodeToTree(sectionElement, @"text", nil, nil);
	DDXMLElement *entryElement = addNodeToTree(sectionElement, @"entry", nil, nil);
	DDXMLElement *actElement = addNodeToTree(entryElement, @"act", [NSArray arrayWithObjects:@"moodCode",@"classCode",nil],[NSArray arrayWithObjects:@"DEF",@"ACT",nil]);
    addNodeToTree(actElement, @"templateId", [NSArray arrayWithObject:@"root"],[NSArray arrayWithObject:@"2.16.840.1.113883.10.20.1.20"] );
    addNodeToTree(actElement, @"templateId", [NSArray arrayWithObject:@"root"],[NSArray arrayWithObject:@"1.3.6.1.4.1.19376.1.5.3.1.4.17"] );
    addNodeToTree(actElement, @"id", [NSArray arrayWithObject:@"root"], [NSArray arrayWithObject:@""]);
    addNodeToTree(actElement, @"code", [NSArray arrayWithObjects:@"code",@"displayName", @"codeSystem", @"codeSystemName",nil],[NSArray arrayWithObjects:@"48768-6", @"Payment Sources", @"2.16.840.1.113883.6.1",@"LOINC",nil]) ;
    addNodeToTree(actElement, @"statusCode", [NSArray arrayWithObject:@"code"], [NSArray arrayWithObject:@"completed"]);
    
    
    
    
    
    DDXMLElement *entryRelationship =  addNodeToTree(actElement, @"entryRelationship", [NSArray arrayWithObject:@"typeCode"], [NSArray arrayWithObject:@"COMP"]);
        
        addNodeToTree(entryRelationship, @"sequenceNumber",[NSArray arrayWithObject:@"value"], [NSArray arrayWithObject:@"1"]);
        DDXMLElement *act2 = addNodeToTree(entryRelationship, @"act", [NSArray arrayWithObjects:@"classCode",@"moodCode",nil], [NSArray arrayWithObjects:@"ACT",@"EVN", nil]);
        addNodeToTree(act2, @"templateId", [NSArray arrayWithObject:@"root"],[NSArray arrayWithObject:@"2.16.840.1.113883.10.20.1.26"] );
        addNodeToTree(act2, @"templateId", [NSArray arrayWithObject:@"root"],[NSArray arrayWithObject:@"2.16.840.1.113883.3.88.11.83.5"] );
    
    // Assure a unique creationID
    unsigned int creationID = [[NSDate date] timeIntervalSince1970];
 //   if(creationID == previousCreationID)
  //      creationID++;
  
        addNodeToTree(act2, @"id", [NSArray arrayWithObjects:@"root",@"extension",nil],[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", creationID], [insurance valueForKey:@"rxGroup"],nil] );
        addNodeToTree(act2, @"code", [NSArray arrayWithObjects:@"code",@"displayName"@"codeSystem",@"codeSystemName",nil],[NSArray arrayWithObjects:@"IP",@"Indvidual Policy",@"2.16.840.1.113883.6.255.1336",@"X12N-1336",nil] ); 
        addNodeToTree(act2, @"statusCode", [NSArray arrayWithObject:@"code"], [NSArray arrayWithObject:@"completed"]);
        DDXMLElement *performer = addNodeToTree(act2,@"performer", [NSArray arrayWithObject:@"typeCode"], [NSArray arrayWithObject:@"PRF"]);
        DDXMLElement *participant1 = addNodeToTree(act2,@"participant", [NSArray arrayWithObject:@"typeCode"], [NSArray arrayWithObject:@"COV"]);
        DDXMLElement *assignedEntity = addNodeToTree(performer, @"assignedEntity", [NSArray arrayWithObject:@"classCode"], [NSArray arrayWithObject:@"ASSIGNED"]);
        addNodeToTree(assignedEntity, @"id", [NSArray arrayWithObjects:@"root",@"extension",nil],[NSArray arrayWithObjects:@"2.16.840.1.113883.3.88.3.1", [insurance valueForKey:@"rxIN"] ,nil] );
        addNodeToTree(assignedEntity, @"id", [NSArray arrayWithObjects:@"root",@"extension",nil],[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@%@",@"2.16.840.1.113883.3.88.3.1.", [insurance valueForKey:@"rxIN"]] , [insurance valueForKey:@"rxPCN"] ,nil] );
       
        
        DDXMLElement *representedOrganization = addNodeToTree(assignedEntity,@"representedOrganization", [NSArray arrayWithObject:@"classCode"], [NSArray arrayWithObject:@"ORG"]);
        [addNodeToTree(representedOrganization, @"name", nil, nil) setStringValue:[insurance valueForKey:@"carrier"]];
        DDXMLElement *time1 = addNodeToTree(participant1, @"time", nil,nil);
        addNodeToTree(time1, @"low", [NSArray arrayWithObject:@"value"], [NSArray arrayWithObject:@"20070101"]);
        DDXMLElement *participantRole  = addNodeToTree(participant1, @"participantRole", [NSArray arrayWithObject:@"classCode"], [NSArray arrayWithObject:@"PAT"]);
    unsigned int previousCreationID = creationID;
        creationID = [[NSDate date] timeIntervalSince1970];
        if(creationID == previousCreationID)
            creationID++;                                                                                       
        addNodeToTree(participantRole, @"id", [NSArray arrayWithObjects:@"root",@"extension",nil],[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", creationID],[insurance valueForKey:@"memberNumber"] ,nil] );
        
            addNodeToTree(participantRole, @"code", [NSArray arrayWithObjects:@"code",@"displayName",@"codeSystem",@"codeSystemName",nil],
                          [NSArray arrayWithObjects:@"SUBSCR",@"subscriber",@"2.16.840.1.113883.5.111",@"RoleCode" ,nil] );
            DDXMLElement *playingElement = addNodeToTree(participantRole, @"playingEntity", nil, nil);
            DDXMLElement *name = addNodeToTree(playingElement, @"name", nil, nil);
            [addNodeToTree(name, @"given", nil, nil) setStringValue:[person firstName]];
            [addNodeToTree(name, @"family", nil, nil) setStringValue:[person lastName]];
    [addNodeToTree(name, @"birthTime", nil, nil) setStringValue:(person.dateOfBirth != nil) ? [Date dateValueForCCD:person.dateOfBirth ]:@""];
    
    
    
    
    
    
    
    //
    insurance = person.secondaryInsurance;
    
    if ([insurance valueForKey:@"carrier"] == nil || [[insurance valueForKey:@"carrier"] isEqualToString:@""] ||
        [insurance valueForKey:@"memberNumber"] == nil || [[insurance valueForKey:@"memberNumber"] isEqualToString:@""] ||
        [insurance valueForKey:@"rxIN"] == nil || [[insurance valueForKey:@"rxIN"] isEqualToString:@""] ||
        [insurance valueForKey:@"rxPCN"] == nil || [[insurance valueForKey:@"rxPCN"] isEqualToString:@""] ||
        [insurance valueForKey:@"rxGroup"] == nil || [[insurance valueForKey:@"rxGroup"] isEqualToString:@""] ) {
        return;
    }

    DDXMLElement *entryRelationship2 =  addNodeToTree(actElement, @"entryRelationship", [NSArray arrayWithObject:@"typeCode"], [NSArray arrayWithObject:@"COMP"]);
    
    addNodeToTree(entryRelationship2, @"sequenceNumber",[NSArray arrayWithObject:@"value"], [NSArray arrayWithObject:@"2"]);
    DDXMLElement *act3 = addNodeToTree(entryRelationship2, @"act", [NSArray arrayWithObjects:@"classCode",@"moodCode",nil], [NSArray arrayWithObjects:@"ACT",@"EVN", nil]);
    addNodeToTree(act3, @"templateId", [NSArray arrayWithObject:@"root"],[NSArray arrayWithObject:@"2.16.840.1.113883.10.20.1.26"] );
    addNodeToTree(act3, @"templateId", [NSArray arrayWithObject:@"root"],[NSArray arrayWithObject:@"2.16.840.1.113883.3.88.11.83.5"] );
    
    // Assure a unique creationID
    unsigned int creationID2 = [[NSDate date] timeIntervalSince1970];
    //   if(creationID == previousCreationID)
    //      creationID++;
    
    addNodeToTree(act3, @"id", [NSArray arrayWithObjects:@"root",@"extension",nil],[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", creationID2], [insurance valueForKey:@"rxGroup"],nil] );
    addNodeToTree(act3, @"code", [NSArray arrayWithObjects:@"code",@"displayName"@"codeSystem",@"codeSystemName",nil],[NSArray arrayWithObjects:@"IP",@"Indvidual Policy",@"2.16.840.1.113883.6.255.1336",@"X12N-1336",nil] );
    addNodeToTree(act3, @"statusCode", [NSArray arrayWithObject:@"code"], [NSArray arrayWithObject:@"completed"]);
    DDXMLElement *performer1 = addNodeToTree(act3,@"performer", [NSArray arrayWithObject:@"typeCode"], [NSArray arrayWithObject:@"PRF"]);
    DDXMLElement *participant2 = addNodeToTree(act3,@"participant", [NSArray arrayWithObject:@"typeCode"], [NSArray arrayWithObject:@"COV"]);
    DDXMLElement *assignedEntity1 = addNodeToTree(performer1, @"assignedEntity", [NSArray arrayWithObject:@"classCode"], [NSArray arrayWithObject:@"ASSIGNED"]);
    addNodeToTree(assignedEntity1, @"id", [NSArray arrayWithObjects:@"root",@"extension",nil],[NSArray arrayWithObjects:@"2.16.840.1.113883.3.88.3.1", [insurance valueForKey:@"rxIN"] ,nil] );
    addNodeToTree(assignedEntity1, @"id", [NSArray arrayWithObjects:@"root",@"extension",nil],[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@%@",@"2.16.840.1.113883.3.88.3.1.", [insurance valueForKey:@"rxIN"]] , [insurance valueForKey:@"rxPCN"] ,nil] );
    
    
    DDXMLElement *representedOrganization1 = addNodeToTree(assignedEntity1,@"representedOrganization", [NSArray arrayWithObject:@"classCode"], [NSArray arrayWithObject:@"ORG"]);
    [addNodeToTree(representedOrganization1, @"name", nil, nil) setStringValue:[insurance valueForKey:@"carrier"]];
    DDXMLElement *time2 = addNodeToTree(participant2, @"time", nil,nil);
    addNodeToTree(time2, @"low", [NSArray arrayWithObject:@"value"], [NSArray arrayWithObject:@"20070101"]);
    DDXMLElement *participantRole1  = addNodeToTree(participant2, @"participantRole", [NSArray arrayWithObject:@"classCode"], [NSArray arrayWithObject:@"PAT"]);
    unsigned int previousCreationID2 = creationID2;
    creationID2 = [[NSDate date] timeIntervalSince1970];
    if(creationID2 == previousCreationID2)
        creationID2++;
    addNodeToTree(participantRole1, @"id", [NSArray arrayWithObjects:@"root",@"extension",nil],[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", creationID2],[insurance valueForKey:@"memberNumber"] ,nil] );
    
    addNodeToTree(participantRole1, @"code", [NSArray arrayWithObjects:@"code",@"displayName",@"codeSystem",@"codeSystemName",nil],
                  [NSArray arrayWithObjects:@"SUBSCR",@"subscriber",@"2.16.840.1.113883.5.111",@"RoleCode" ,nil] );
    DDXMLElement *playingElement1 = addNodeToTree(participantRole1, @"playingEntity", nil, nil);
    DDXMLElement *name1 = addNodeToTree(playingElement1, @"name", nil, nil);
    [addNodeToTree(name1, @"given", nil, nil) setStringValue:[person firstName]];
    [addNodeToTree(name1, @"family", nil, nil) setStringValue:[person lastName]];
    [addNodeToTree(name1, @"birthTime", nil, nil) setStringValue:(person.dateOfBirth != nil) ? [Date dateValueForCCD:person.dateOfBirth]:@""];
    
}

