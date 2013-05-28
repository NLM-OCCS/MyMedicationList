//
//  Medication.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "Medication.h"

@interface Medication ()
- (unsigned int)generateCreationID;
@end

@implementation Medication
@synthesize startDate = _startDate;
@synthesize stopDate = _stopDate;
@synthesize amount = _amount;
@synthesize frequency = _frequency;
@synthesize instruction = _instruction;
@synthesize image = _image;
@synthesize conceptProperty = _conceptProperty;
@synthesize ingredients = _ingredients;
@synthesize ccdInfo = _ccdInfo;
@synthesize creationID = _creationID;
@synthesize name;
@synthesize repeats = _repeats;
@synthesize quantity = _quantity;
@synthesize prescribeDate = _prescribeDate;
@synthesize telephoneNumber = _telephoneNumber;
@synthesize prescriberFirstName = _prescriberFirstName;
@synthesize prescriberLastName = _prescriberLastName;
@synthesize prescriberSuffix = _prescriberSuffix;



- (id)init
{
    self = [super init];
    if(self)
    {
        self.repeats = 0;
        self.quantity = 0;
        self.prescribeDate = nil;
        self.telephoneNumber = nil;
        self.prescriberFirstName = nil;
        self.prescriberLastName = nil;
        self.prescriberSuffix = nil;
        self.creationID = [self generateCreationID];
    }
    
    return self;
}

- (id)initWithMedication:(Medication *)medication
{
    NSLog(@"Medication - initWithMedication");
    self = [[[self class] allocWithZone:nil] init];
    NSLog(@"Medication class = %@",[[self class] description]);
    if(self)
    {
        NSLog(@"Medication starting to copy parameter values...");
        
        /*
        // The following should always be copied from mutableCopyWithZone
        self.startDate = [medication.startDate mutableCopy];
        self.stopDate = [medication.stopDate mutableCopy];
        self.amount = [medication.amount mutableCopy];
        self.frequency = [medication.frequency mutableCopy];
        self.instruction = [medication.instruction mutableCopy];
        // Copying the whole image when we are using a camera photo is to slow because the image is large
        // There is a noticeable slow down in pushing and popping the viewcontrollers
        // For now we just do a retain because we are only using this in the MedicationDataViewController
        // and changing the actual image from a seperate object is the correct behavior
        self.image = medication.image;
        self.conceptProperty = [medication.conceptProperty mutableCopy];
        self.ccdInfo = [medication.ccdInfo mutableCopy];
        self.creationID = [self generateCreationID];
         */
        
        self.startDate = [[medication.startDate mutableCopy] autorelease];
        self.stopDate = [[medication.stopDate mutableCopy] autorelease];
        self.amount = [[medication.amount mutableCopy] autorelease];
        self.frequency = [[medication.frequency mutableCopy] autorelease];
        self.instruction = [[medication.instruction mutableCopy] autorelease];
        
        // Copying the whole image when we are using a camera photo is to slow because the image is large
        // There is a noticeable slow down in pushing and popping the viewcontrollers
        // For now we just do a retain because we are only using this in the MedicationDataViewController
        // and changing the actual image from a seperate object is the correct behavior
        self.image = medication.image;
        self.conceptProperty = [[medication.conceptProperty mutableCopy] autorelease];
        self.ingredients = [[medication.ingredients mutableCopy] autorelease];
        self.ccdInfo = [[medication.ccdInfo mutableCopy] autorelease];
        self.creationID = [self generateCreationID];
        self.repeats = medication.repeats;
        self.quantity = medication.quantity;
        self.prescribeDate = [[medication.prescribeDate mutableCopy] autorelease];
        self.telephoneNumber = [[medication.telephoneNumber mutableCopy] autorelease];
        self.prescriberFirstName = [[medication.prescriberFirstName mutableCopy] autorelease];
        self.prescriberLastName = [[medication.prescriberLastName mutableCopy] autorelease];
        self.prescriberSuffix = [[medication.prescriberSuffix mutableCopy] autorelease];

    }
    
    return self;
}

- (void)dealloc{
    
    self.startDate = nil;
    self.stopDate = nil;
    self.amount = nil;
    self.frequency = nil;
    self.instruction = nil;
    self.image = nil;
    self.conceptProperty = nil;
    self.ingredients = nil;
    self.ccdInfo = nil;
    self.prescribeDate = nil;
    self.telephoneNumber = nil;
    self.prescriberFirstName = nil;
    self.prescriberLastName = nil;
    self.prescriberSuffix = nil;
    
    NSLog(@"Dealloc in Medication!!!!");
    [super dealloc];
}

- (NSString *)name{
    if(([_conceptProperty.synonym isEqualToString:@""])||(_conceptProperty.synonym == nil))
		return _conceptProperty.name;
	else {
        if ([_conceptProperty.synonym length] > [_conceptProperty.name length]) {
            return _conceptProperty.name;
        }
    }
		return _conceptProperty.synonym;
}

- (void)printMedication
{
    if([[[self class] description] isEqualToString:[[Medication class] description]])
    {
        NSLog(@" ");
        NSLog(@"Medication");
    }
    else
    {
        NSLog(@" ");        
        NSLog(@"Prescription");
    }
    
    NSLog(@"++++++++++++++++++++++++++++++++++++++++");
    NSLog(@"Concept Property");	
    NSLog(@"++++++++++++++++++++++++++++++++++++++++");
    NSLog(@"rxcui: %@",_conceptProperty.rxcui);
    NSLog(@"name: %@",_conceptProperty.name);
    NSLog(@"synonym: %@",_conceptProperty.synonym);
    NSLog(@"termtype: %@",_conceptProperty.termtype);	
    NSLog(@"language: %@",_conceptProperty.language);
    NSLog(@"suppressflag: %@",_conceptProperty.suppressflag);
    NSLog(@"UMLSCUI: %@",_conceptProperty.UMLSCUI);
    NSLog(@"========================================");
    
    NSLog(@"User Data");
    NSLog(@"========================================");
    NSLog(@"Start date: %@",[_startDate printDate]);
    NSLog(@"Stop date: %@",[_stopDate printDate]);
    NSLog(@"Medication Amount: %@", [_amount printAmount]);
    NSLog(@"Medication Frequency: %@", [_frequency printFrequency]);	
    NSLog(@"Medication Instruction: %@", [_instruction printInstruction]);
    NSLog(@"repeats: %d",_repeats);
    NSLog(@"quantity: %d",_quantity);
    NSLog(@"Prescribe Date: %@",[_prescribeDate printDate]);
    NSLog(@"Prescriber First Name: %@",_prescriberFirstName);
    NSLog(@"Prescriber Last Name: %@",_prescriberLastName);
    NSLog(@"Prescriber Suffix: %@",_prescriberSuffix);    
    NSLog(@"++++++++++++++++++++++++++++++++++++++++");
    if([[[self class] description] isEqualToString:[[Medication class] description]])
        NSLog(@"++++++++++++++++++++++++++++++++++++++++");
     
}

- (unsigned int)generateCreationID
{
    
    /* This is the previous implmentation that was located in the -(id)init method
     static int previousCreationID = 0;
     
     // Assure a unique creationID
     self.creationID = (int)[[NSDate date] timeIntervalSince1970];
     if(self.creationID == previousCreationID)
     _creationID++;
     previousCreationID = self.creationID;
     */
    
   // static int previousCreationID = 0;
    
    // Assure a unique creationID
    unsigned int creationID = [[NSDate date] timeIntervalSince1970];
    //if(creationID == previousCreationID)
   //     creationID++;
  //  previousCreationID = creationID;
    return creationID;
}


- (id)mutableCopyWithZone:(NSZone *)zone
{

    Medication *newMedication = [[[self class] allocWithZone:zone] init];
    
    newMedication.startDate = [[_startDate mutableCopy] autorelease];
    newMedication.stopDate = [[_stopDate mutableCopy] autorelease];
    newMedication.amount = [[_amount mutableCopy] autorelease];
    newMedication.frequency = [[_frequency mutableCopy] autorelease];
    newMedication.instruction = [[_instruction mutableCopy] autorelease];
    // Copying the whole image when we are using a camera photo is to slow because the image is large
	// There is a noticeable slow down in pushing and popping the viewcontrollers
    // For now we just do a retain because we are only using this in the MedicationDataViewController
    // and changing the actual image from a seperate object is the correct behavior
    newMedication.image = _image;
    newMedication.conceptProperty = [[_conceptProperty mutableCopy] autorelease];
    newMedication.ingredients = [[_ingredients mutableCopy] autorelease];
    newMedication.ccdInfo = [[_ccdInfo mutableCopy] autorelease];
    newMedication.creationID = _creationID;
    newMedication.repeats = self.repeats;
    newMedication.quantity = self.quantity;
    newMedication.prescribeDate = self.prescribeDate;
    newMedication.telephoneNumber = self.telephoneNumber;
    newMedication.prescriberFirstName = self.prescriberFirstName;
    newMedication.prescriberLastName = self.prescriberLastName;
    newMedication.prescriberSuffix = self.prescriberSuffix;
    return newMedication;
}

- (id)mutableCopy
{
    return [self mutableCopyWithZone:nil];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_startDate forKey:@"MMLMedstartDate"];
    [aCoder encodeObject:_stopDate forKey:@"MMLMedstopDate"];
    [aCoder encodeObject:_amount forKey:@"MMLMedamount"];
    [aCoder encodeObject:_frequency forKey:@"MMLMedfrequency"];
    [aCoder encodeObject:_instruction forKey:@"MMLMedinstruction"];
    
    NSData *imageData = UIImageJPEGRepresentation(_image,1.0f);
    [aCoder encodeObject:imageData forKey:@"MMLMedimage"];
    
    [aCoder encodeObject:_conceptProperty forKey:@"MMLMedconceptProperty"];
    [aCoder encodeObject:_ingredients forKey:@"MMLMedingredients"];
    [aCoder encodeObject:_ccdInfo forKey:@"MMLMedccdInfo"];    
    [aCoder encodeInt:_creationID forKey:@"MMLMedcreationID"];
    [aCoder encodeInt:_repeats forKey:@"MMLrepeats"];
    [aCoder encodeInt:_quantity forKey:@"MMLquantity"];
    [aCoder encodeObject:_prescribeDate forKey:@"MMLprescribeDate"];
    [aCoder encodeObject:_telephoneNumber forKey:@"MMLtelephoneNumber"];
    [aCoder encodeObject:_prescriberFirstName forKey:@"MMLprescriberFirstName"];
    [aCoder encodeObject:_prescriberLastName forKey:@"MMLprescriberLastName"];
    [aCoder encodeObject:_prescriberSuffix forKey:@"MMLprescriberSuffix"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder in Medication for class: %@",[[self class] description]);
    //self = [[[self class] alloc] init];
    [self init];
    if(self)
    {
        _startDate = [aDecoder decodeObjectForKey:@"MMLMedstartDate"];
        [_startDate retain];
        _stopDate = [aDecoder decodeObjectForKey:@"MMLMedstopDate"];
        [_stopDate retain];
        _amount = [aDecoder decodeObjectForKey:@"MMLMedamount"];
        [_amount retain];
        _frequency = [aDecoder decodeObjectForKey:@"MMLMedfrequency"];
        [_frequency retain];
        _instruction = [aDecoder decodeObjectForKey:@"MMLMedinstruction"];
        [_instruction retain];
        
        NSData *imageData = [aDecoder decodeObjectForKey:@"MMLMedimage"];
        _image = [UIImage imageWithData:imageData];
        [_image retain];
        
        _conceptProperty = [aDecoder decodeObjectForKey:@"MMLMedconceptProperty"];
        [_conceptProperty retain];
        _ingredients = [aDecoder decodeObjectForKey:@"MMLMedingredients"];
        [_ingredients retain];
        _ccdInfo = [aDecoder decodeObjectForKey:@"MMLMedccdInfo"];
        [_ccdInfo retain];
        _creationID = [aDecoder decodeIntForKey:@"MMLMedcreationID"];
        _repeats = [aDecoder decodeIntForKey:@"MMLrepeats"];
        _quantity = [aDecoder decodeIntForKey:@"MMLquantity"];
        _prescribeDate = [aDecoder decodeObjectForKey:@"MMLprescribeDate"];
        [_prescribeDate retain];
        _telephoneNumber = [aDecoder decodeObjectForKey:@"MMLtelephoneNumber"];
        [_telephoneNumber retain];
        _prescriberFirstName = [aDecoder decodeObjectForKey:@"MMLprescriberFirstName"];
        [_prescriberFirstName retain];
        _prescriberLastName = [aDecoder decodeObjectForKey:@"MMLprescriberLastName"];
        [_prescriberLastName retain];
        _prescriberSuffix = [aDecoder decodeObjectForKey:@"MMLprescriberSuffix"];
        [_prescriberSuffix retain];

    }
    
    return self;
}

@end
