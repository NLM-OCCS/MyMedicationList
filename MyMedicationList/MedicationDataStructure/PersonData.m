//
//  PersonData.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#include "StorageDirectory.h"
#import "CCDGenerator.h"
#import "MedicationList.h"
#import "Date+CCDFunctionality.h"
#import "PersonData.h"
#import "MedicationContainer.h"
#import "Medication.h"

@implementation PersonData
@synthesize userID = _userID;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize gender = _gender;
@synthesize currentMedicationList = _currentMedicationList;
@synthesize discontinuedMedicationList = _discontinuedMedicationList;
@synthesize archiveName = _archiveName;

@synthesize dateOfBirth = _dateOfBirth;
@synthesize phoneNumber = _phoneNumber;
@synthesize streetAddress = _streetAddress;
@synthesize streetAddress2 = _streetAddress2;
@synthesize city = _city;
@synthesize state = _state;
@synthesize zip = _zip;

@synthesize carrier = _carrier;
@synthesize groupNumber = _groupNumber;
@synthesize memberNumber = _memberNumber;
@synthesize rxIN = _rxIN;
@synthesize rxPCN = _rxPCN;
@synthesize rxGroup = _rxGroup;
@synthesize cardImage = _cardImage;
@synthesize backCardImage = _backCardImage;
@synthesize carrier2 = _carrier2;
@synthesize groupNumber2 = _groupNumber2;
@synthesize memberNumber2 = _memberNumber2;
@synthesize rxIN2 = _rxIN2;
@synthesize rxPCN2 = _rxPCN2;
@synthesize rxGroup2 = _rxGroup2;
@synthesize cardImage2 = _cardImage2;
@synthesize backCardImage2 = _backCardImage2;
@synthesize personImage = _personImage;

- (id)init{
    return [self initWithArchiveName:@"tempPerson"];
}

- (id)initWithArchiveName:(NSString *)archiveName
{
    self = [super init];
    if(self)
    {
        self.archiveName = archiveName;
        self.firstName = nil;
        self.lastName = nil;
        self.gender = Male;
        self.personImage = nil;
        _currentMedicationList = [[MedicationList alloc] initWithArchiveName:[NSString stringWithFormat:@"%@CurrentMeds",_archiveName]];
        _discontinuedMedicationList = [[MedicationList alloc] initWithArchiveName:[NSString stringWithFormat:@"%@DiscontinuedMeds",_archiveName]];
        
        self.dateOfBirth = nil;
        self.phoneNumber = nil;
        self.streetAddress = nil;
        self.streetAddress2 = nil;
        self.city = nil;
        self.state = nil;
        self.zip = nil;
        
        self.carrier = nil;
        self.groupNumber = nil;
        self.memberNumber = nil;
        self.rxIN = nil;
        self.rxPCN = nil;
        self.rxGroup = nil;
        self.cardImage = nil;
        self.backCardImage = nil;
        
        self.carrier2 = nil;
        self.groupNumber2 = nil;
        self.memberNumber2 = nil;
        self.rxIN2 = nil;
        self.rxPCN2 = nil;
        self.rxGroup2 = nil;
        self.cardImage2 = nil;
        self.backCardImage2 = nil;
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc - PersonData");
    self.archiveName = nil;   
    self.firstName = nil;
    self.lastName = nil;
    self.personImage = nil;
    [_currentMedicationList release];
    _currentMedicationList = nil;
    [_discontinuedMedicationList release];
    _discontinuedMedicationList = nil;
    
    self.dateOfBirth = nil;
    self.phoneNumber = nil;
    self.streetAddress = nil;
    self.streetAddress2 = nil;
    self.city = nil;
    self.state = nil;
    self.zip = nil;
    
    self.carrier = nil;
    self.groupNumber = nil;
    self.memberNumber = nil;
    self.rxIN = nil;
    self.rxPCN = nil;
    self.rxGroup = nil;
    self.cardImage = nil;
    self.backCardImage = nil;
    
    self.carrier2 = nil;
    self.groupNumber2 = nil;
    self.memberNumber2 = nil;
    self.rxIN2 = nil;
    self.rxPCN2 = nil;
    self.rxGroup2 = nil;
    self.cardImage2 = nil;
    self.backCardImage2 = nil;
    
    [super dealloc];
}

- (NSString *)userID
{
    NSString *ID = nil;
    if (self.dateOfBirth == nil)
        ID = [NSString stringWithFormat:@"%@%@%@",self.lastName,self.firstName,@"NoDOB"];
    else
        ID = [NSString stringWithFormat:@"%@%@%@",self.lastName,self.firstName,[self.dateOfBirth dateAttributeStringForCCD]];
    
    return ID;
}

- (NSString *)ccdString
{
 //   return [CCDGenerator CCDStringForPerson:self];
    return nil;
}

- (NSString *)ccdStringTableOnly
{
  //  return [CCDGenerator CCDTableForPerson:self];
    return nil;
}


- (NSString *)duplicateIngredient:(NSArray *)ingredients
{
    for(MedicationContainer *medContainer in self.currentMedicationList)
    {
        if(medContainer.medication != nil)
        {
            if (medContainer.medication.ingredients != nil)
            {
                for(NSString *containerIngredient in medContainer.medication.ingredients)
                {
                    for (NSString *ingredient in ingredients) {
                        if([containerIngredient compare:ingredient options:NSCaseInsensitiveSearch] == NSOrderedSame)
                            return ingredient;
                    }
                }
            }
        }
    }
    
    return nil;
}

- (void)cleanPerson
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *errorPerson;
	
	NSString *fullArchiveName = [NSString stringWithFormat:@"%@.archive",_archiveName];
	// Delete any left over personal data from the last person who downloaded the application
	[fileManager removeItemAtPath:[storageDirectory() stringByAppendingPathComponent:fullArchiveName] error:&errorPerson];

}

- (void)printPerson
{
    NSLog(@"firstName: %@",_firstName);
    NSLog(@"lastName: %@",_lastName);
    NSLog(@"gender: %@",(_gender == Male) ? @"Male" : @"Female");
    NSLog(@"date of birth: %@",[_dateOfBirth displayDate]);
    NSLog(@"Printing the currentmedicationlist --");
    [_currentMedicationList printMedicationList];
    NSLog(@"Printing the discontinuedmedicationlist --");    
    [_discontinuedMedicationList printMedicationList];
    NSLog(@"Phone: %@",_phoneNumber) ;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSLog(@"PersonData - encodeWithCoder");
    // Do I need this?
    [aCoder encodeObject:_archiveName forKey:@"MMLarchiveName"];
    
    [aCoder encodeObject:_firstName forKey:@"MMLfirstName"];
    [aCoder encodeObject:_lastName forKey:@"MMLlastName"];
    [aCoder encodeInteger:_gender  forKey:@"MMLGender"];
    NSData *photoImage = UIImagePNGRepresentation(_personImage);
    [aCoder encodeObject:photoImage forKey:@"MMLPersonImage"];
    
    [aCoder encodeObject:_currentMedicationList forKey:@"MMLcurrentMedicationList"];
    [aCoder encodeObject:_discontinuedMedicationList forKey:@"MMLdiscontinuedMedicationList"];    
    
    [aCoder encodeObject:_dateOfBirth forKey:@"MMLdateOfBirth"];
    [aCoder encodeObject:_phoneNumber forKey:@"MMLphoneNumber"];    
    [aCoder encodeObject:_streetAddress forKey:@"MMLstreetNumber"];
    [aCoder encodeObject:_streetAddress2 forKey:@"MMLstreetNumber2"];
    [aCoder encodeObject:_city forKey:@"MMLcity"];
    [aCoder encodeObject:_state forKey:@"MMLstate"];
    [aCoder encodeObject:_zip forKey:@"MMLzip"];
    
    [aCoder encodeObject:_carrier forKey:@"MMLcarrier"];
    [aCoder encodeObject:_groupNumber forKey:@"MMLgroupNumber"];
    [aCoder encodeObject:_memberNumber forKey:@"MMLmemberNumber"];
    [aCoder encodeObject:_rxIN forKey:@"MMLrxIN"];
    [aCoder encodeObject:_rxPCN forKey:@"MMLrxPCN"];
    [aCoder encodeObject:_rxGroup forKey:@"MMLrxGroup"];
    NSData *imageData = UIImagePNGRepresentation(_cardImage);
    [aCoder encodeObject:imageData forKey:@"MMLcardImage"];
    NSData *imagebackData = UIImagePNGRepresentation(_backCardImage);
    [aCoder encodeObject:imagebackData forKey:@"MMLbackCardImage"];

    
    [aCoder encodeObject:_carrier2 forKey:@"MMLcarrier2"];
    [aCoder encodeObject:_groupNumber2 forKey:@"MMLgroupNumber2"];
    [aCoder encodeObject:_memberNumber2 forKey:@"MMLmemberNumber2"];
    [aCoder encodeObject:_rxIN2 forKey:@"MMLrxIN2"];
    [aCoder encodeObject:_rxPCN2 forKey:@"MMLrxPCN2"];
    [aCoder encodeObject:_rxGroup2 forKey:@"MMLrxGroup2"];
    NSData *imageData2 = UIImagePNGRepresentation(_cardImage2);
    [aCoder encodeObject:imageData2 forKey:@"MMLcardImage2"];
    NSData *imagebackData2 = UIImagePNGRepresentation(_backCardImage2);
    [aCoder encodeObject:imagebackData2 forKey:@"MMLbackCardImage2"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        NSLog(@"PersonData - initWithCoder");
        // Do I need this?
        self.archiveName = [aDecoder decodeObjectForKey:@"MMLarchiveName"];
        
        self.firstName = [aDecoder decodeObjectForKey:@"MMLfirstName"];
        self.lastName = [aDecoder decodeObjectForKey:@"MMLlastName"];
        self.gender = [aDecoder decodeIntForKey:@"MMLGender"];
        NSData *personPhotoImage = [aDecoder decodeObjectForKey:@"MMLPersonImage"];
        self.personImage = [UIImage imageWithData:personPhotoImage];
        
        _currentMedicationList = [aDecoder decodeObjectForKey:@"MMLcurrentMedicationList"];
        [_currentMedicationList retain];
        _discontinuedMedicationList = [aDecoder decodeObjectForKey:@"MMLdiscontinuedMedicationList"];        
        [_discontinuedMedicationList retain];
        
        self.dateOfBirth = [aDecoder decodeObjectForKey:@"MMLdateOfBirth"];
        self.phoneNumber = [aDecoder decodeObjectForKey:@"MMLphoneNumber"];
        self.streetAddress = [aDecoder decodeObjectForKey:@"MMLstreetNumber"];
        self.streetAddress2 = [aDecoder decodeObjectForKey:@"MMLstreetNumber2"];
        self.city = [aDecoder decodeObjectForKey:@"MMLcity"];
        self.state = [aDecoder decodeObjectForKey:@"MMLstate"];
        self.zip = [aDecoder decodeObjectForKey:@"MMLzip"];
        
        self.carrier = [aDecoder decodeObjectForKey:@"MMLcarrier"];
        self.groupNumber = [aDecoder decodeObjectForKey:@"MMLgroupNumber"];
        self.memberNumber = [aDecoder decodeObjectForKey:@"MMLmemberNumber"];
        self.rxIN = [aDecoder decodeObjectForKey:@"MMLrxIN"];
        self.rxPCN = [aDecoder decodeObjectForKey:@"MMLrxPCN"];
        self.rxGroup = [aDecoder decodeObjectForKey:@"MMLrxGroup"];
        NSData *cardImageData = [aDecoder decodeObjectForKey:@"MMLcardImage"];
        self.cardImage = [UIImage imageWithData:cardImageData];
        NSData *backCardImageData = [aDecoder decodeObjectForKey:@"MMLbackCardImage"];
        self.backCardImage = [UIImage imageWithData:backCardImageData];

        
        self.carrier2 = [aDecoder decodeObjectForKey:@"MMLcarrier2"];
        self.groupNumber2 = [aDecoder decodeObjectForKey:@"MMLgroupNumber2"];
        self.memberNumber2 = [aDecoder decodeObjectForKey:@"MMLmemberNumber2"];
        self.rxIN2 = [aDecoder decodeObjectForKey:@"MMLrxIN2"];
        self.rxPCN2 = [aDecoder decodeObjectForKey:@"MMLrxPCN2"];
        self.rxGroup2 = [aDecoder decodeObjectForKey:@"MMLrxGroup2"];
        NSData *cardImageData2 = [aDecoder decodeObjectForKey:@"MMLcardImage2"];
        self.cardImage2 = [UIImage imageWithData:cardImageData2];
        NSData *backCardImageData2 = [aDecoder decodeObjectForKey:@"MMLbackCardImage2"];
        self.backCardImage2 = [UIImage imageWithData:backCardImageData2];
    }
    
    return self;
}

@end
