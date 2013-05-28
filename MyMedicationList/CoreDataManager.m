//
//  CoreDataManager.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "CoreDataManager.h"


@implementation CoreDataManager
static CoreDataManager *instance = nil;

+ (CoreDataManager *)coreDataManager
{
	if(instance == nil)
	{
		instance = [[super allocWithZone:NULL] init];
        
	}
	return instance;
}



- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (NSUInteger)profileCount {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    NSEntityDescription *persons = [NSEntityDescription entityForName:@"MMLPersonData" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:persons];
    NSError *fetchError = nil;
    NSArray *personsArray = [context executeFetchRequest:request error:&fetchError];
    [request release];
    if (personsArray == nil || [personsArray count] == 0) {
        return 0;
    }
    return [personsArray count];
}
- (MMLPersonData *)profileAtIndex:(NSUInteger)index
{
	AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    NSEntityDescription *persons = [NSEntityDescription entityForName:@"MMLPersonData" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:persons];
    NSSortDescriptor *sortDescriptor1 = [[[NSSortDescriptor alloc]
                                        initWithKey:@"firstName" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor2 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"lastName" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor3 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"dateOfBirth" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor4 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"gender" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor5 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"userId" ascending:YES] autorelease];
    [request setSortDescriptors:@[sortDescriptor1,sortDescriptor2,sortDescriptor3,sortDescriptor4,sortDescriptor5]];
    NSError *fetchError = nil;
    NSArray *personsArray = [context executeFetchRequest:request error:&fetchError];
    [request release];
    if (personsArray == nil || [personsArray count] == 0) {
        return nil;
    } else if ([personsArray count] > index) {
        return [personsArray objectAtIndex:index];
    } else {
        return nil;
    }
}
- (NSString *) getPersonNameByIndex:(NSUInteger)index {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    NSEntityDescription *persons = [NSEntityDescription entityForName:@"MMLPersonData" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:persons];
    NSSortDescriptor *sortDescriptor1 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"firstName" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor2 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"lastName" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor3 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"dateOfBirth" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor4 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"gender" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor5 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"userId" ascending:YES] autorelease];
    [request setSortDescriptors:@[sortDescriptor1,sortDescriptor2,sortDescriptor3,sortDescriptor4,sortDescriptor5]];
    NSError *fetchError = nil;
    NSArray *personsArray = [context executeFetchRequest:request error:&fetchError];
    [request release];
    if (personsArray == nil || [personsArray count] == 0) {
        return nil;
    } else if ([personsArray count] > index) {
        MMLPersonData *person= [personsArray objectAtIndex:index];
        return [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName ];
    }
    return nil;
}

- (UIImage *) getPersonImageByIndex:(NSUInteger)index {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    NSEntityDescription *persons = [NSEntityDescription entityForName:@"MMLPersonData" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:persons];
    NSSortDescriptor *sortDescriptor1 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"firstName" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor2 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"lastName" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor3 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"dateOfBirth" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor4 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"gender" ascending:YES] autorelease];
    NSSortDescriptor *sortDescriptor5 = [[[NSSortDescriptor alloc]
                                         initWithKey:@"userId" ascending:YES] autorelease];
    [request setSortDescriptors:@[sortDescriptor1,sortDescriptor2,sortDescriptor3,sortDescriptor4,sortDescriptor5]];
    NSError *fetchError = nil;
    NSArray *personsArray = [context executeFetchRequest:request error:&fetchError];
    [request release];
    if (personsArray == nil || [personsArray count] == 0) {
        return nil;
    } else if ([personsArray count] > index) {
        MMLPersonData *person= [personsArray objectAtIndex:index];
        return [UIImage imageWithData:person.personImage];
    }
    return nil;
}

-(MMLPersonData *) newPersonData {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    return (MMLPersonData *)[NSEntityDescription insertNewObjectForEntityForName:@"MMLPersonData" inManagedObjectContext:context];
}
-(MMLMedication *) newMedication {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    return (MMLMedication *)[NSEntityDescription insertNewObjectForEntityForName:@"MMLMedication" inManagedObjectContext:context];
}
-(MMLInsurance *) newInsurance {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    return (MMLInsurance *)[NSEntityDescription insertNewObjectForEntityForName:@"MMLInsurance" inManagedObjectContext:context];
}
-(MMLMedicationInstruction *) newInstruction {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    return (MMLMedicationInstruction *)[NSEntityDescription insertNewObjectForEntityForName:@"MMLMedicationInstruction" inManagedObjectContext:context];
}
-(MMLMedicationFrequency *) newFrequency {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    return (MMLMedicationFrequency *)[NSEntityDescription insertNewObjectForEntityForName:@"MMLMedicationFrequency" inManagedObjectContext:context];
}
-(MMLMedicationAmount *) newamount {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    return (MMLMedicationAmount *)[NSEntityDescription insertNewObjectForEntityForName:@"MMLMedicationAmount" inManagedObjectContext:context];
}
- (MMLCCDInfo *) newCCDInfo {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    return (MMLCCDInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"MMLCCDInfo" inManagedObjectContext:context];
}

- (MMLConceptProperty *) newConceptProperty {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    return (MMLConceptProperty *)[NSEntityDescription insertNewObjectForEntityForName:@"MMLConceptProperty" inManagedObjectContext:context];
}
- (MMLMedicationList *) newMedicationList {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    return (MMLMedicationList *)[NSEntityDescription insertNewObjectForEntityForName:@"MMLMedicationList" inManagedObjectContext:context];
}
- (MMLIngredients *) newIngredients {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    return (MMLIngredients *)[NSEntityDescription insertNewObjectForEntityForName:@"MMLIngredients" inManagedObjectContext:context];
}
- (void)saveContext
{
    NSError *error = nil;
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    if (context != nil)
    {
        if ([context hasChanges]) {
        if ([context hasChanges] && ![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        }
    }
}
- (void) rollBack
{
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    if (context != nil)
    {
        [context rollback];
    }
}

- (void) deleteManagedObject:(NSManagedObject *)nsObject {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    if (context != nil)
    {
        [context deleteObject:nsObject];
    }
}

- (void) deletePersonAtIndex:(NSUInteger)index {
    MMLPersonData *person = [self profileAtIndex:index];
    if (person != nil) {
        [self deleteManagedObject:person];
    }
}

- (NSString *)duplicateIngredient:(NSSet *)ingredientSet ForPerson:(MMLPersonData *) personData
{
    MMLMedicationList *currentMedList = personData.currentMedicationList;
    NSSet *medications = currentMedList.medicationList;
    
    for(MMLMedication *medication in medications)
    {
        if(medication != nil)
        {
            NSSet *ingredSet = medication.ingredientsArray;
            if (medication.ingredientsArray != nil)
            {
                for(MMLIngredients *mmlIngredient in ingredSet)
                {
                    for (MMLIngredients *inputIngredient in ingredientSet) {
                        if([inputIngredient.ingredient compare:mmlIngredient.ingredient options:NSCaseInsensitiveSearch] == NSOrderedSame)
                            return inputIngredient.ingredient;
                    }
                }
            }
        }
    }
    
    return nil;
}
- (void) setMMLIngedients:(NSString *)ingredientString forMedication:(MMLMedication *)med
{
    
    NSArray *components = [ingredientString componentsSeparatedByString:@" / "];
    for (NSString *component in components) {
        NSLog(@"component = %@",component);
        NSLog(@"component length = %d",[component length]);
    }
        for (NSString *component in components) {
        MMLIngredients *ingredient = [self newIngredients];
        ingredient.ingredient = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [med addIngredientsArrayObject:ingredient];
    }

}

- (NSString *) getExpiredMedicationNames:(MMLPersonData *)person {
    AppDelegate *aDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [aDelegate managedObjectContext];
    NSManagedObjectModel* model = [[context persistentStoreCoordinator] managedObjectModel];
    NSDate *startDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    startDate = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:startDate]];
    NSDictionary *substituteVariable = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:startDate,person.userId,nil] forKeys:[NSArray arrayWithObjects:@"todayDate",@"personId", nil]];
    NSFetchRequest* request = [model fetchRequestFromTemplateWithName:@"FetchRequest"
                                                substitutionVariables:substituteVariable];
    NSError* error = nil;
    NSArray* results = [context executeFetchRequest:request error:&error];
    if (error != nil || results == nil || (results != nil && [results count] ==0 )) {
        return nil;
    }
    NSLog(@"Count is %d", [results count]);
    NSMutableString *message = [[[NSMutableString alloc] init] autorelease];
    [message appendString:@"Check following medicines:\n"];
    for (int i=0; i < [results count]; i++) {
        MMLMedication *med = [results objectAtIndex:i];
        [message appendString:@"\n"];
        [message appendString:med.name];
        
    }
    
    return message;
}
- (void) printMedication:(MMLMedication *)medication {
    NSLog(@"Med Name is %@", medication.name);
    MMLConceptProperty *_conceptProperty = medication.conceptProperty;
    if (medication.conceptProperty != nil) {
    NSLog(@"++++++++++++++++++++++++++++++++++++++++");
    NSLog(@"Concept Property");
    NSLog(@"++++++++++++++++++++++++++++++++++++++++");
    NSLog(@"rxcui: %@",_conceptProperty.rxcui);
    NSLog(@"name: %@",_conceptProperty.name);
    NSLog(@"synonym: %@",_conceptProperty.synonym);
    NSLog(@"termtype: %@",_conceptProperty.termtype);
    NSLog(@"language: %@",_conceptProperty.language);
    NSLog(@"suppressflag: %@",_conceptProperty.suppressflag);
    NSLog(@"UMLSCUI: %@",_conceptProperty.umlsCUI);
    NSLog(@"========================================");
    }
    NSLog(@"User Data");
    NSLog(@"========================================");
    NSLog(@"Start date: %@",medication.startDate );
    NSLog(@"Stop date: %@",medication.stopDate );
    NSLog(@"Medication Amount: %@ %@", medication.medicationAmount.quantity, medication.medicationAmount.amountType);
    NSLog(@"Medication Frequency: %@", medication.medicationFrequency.frequency);
    NSLog(@"Medication Instruction: %@",medication.medicationInstruction.instruction);
    
        NSLog(@"++++++++++++++++++++++++++++++++++++++++");
}
- (void) printMedication:(MMLMedicationList *)medList  type:(NSString *) type{
    if (medList == nil || medList.medicationList == nil)
        NSLog(@"No %@ medications !!!!",type);
    
    NSLog(@"\tPrinting %@ medications!!!",type);
    NSSet *medSet = medList.medicationList;
    for (MMLMedication *medication in medSet) {
        NSLog(@"********  Medication Details **************");
        NSLog(@"\t\tMed Name:[%@]", medication.name);
        NSLog(@"\t\tStart date:[%@]",medication.startDate );
        NSLog(@"\t\tStop date:[%@]",medication.stopDate );
        NSLog(@"\t\tMedication Amount:[%@ %@]", medication.medicationAmount.quantity, medication.medicationAmount.amountType);
        NSLog(@"\t\tMedication Frequency:[%@]", medication.medicationFrequency.frequency);
        NSLog(@"\t\tMedication Instruction:[%@]",medication.medicationInstruction.instruction);
        NSLog(@"\t\tCreation ID:[%@]",medication.creationID);
        MMLConceptProperty *_conceptProperty = medication.conceptProperty;
        if (medication.conceptProperty != nil) {
            NSLog(@"\t\tConcept Property for the Medications:");
            NSLog(@"\t\t\trxcui:[%@]",_conceptProperty.rxcui);
            NSLog(@"\t\t\tname:[%@]",_conceptProperty.name);
            NSLog(@"\t\t\tsynonym:[%@]",_conceptProperty.synonym);
            NSLog(@"\t\t\ttermtype:[%@]",_conceptProperty.termtype);
            NSLog(@"\t\t\tlanguage:[%@]",_conceptProperty.language);
            NSLog(@"\t\t\tsuppressflag:[%@]",_conceptProperty.suppressflag);
            NSLog(@"\t\t\tUMLSCUI:[%@]",_conceptProperty.umlsCUI);
        }
        MMLCCDInfo *_ccdinfo = medication.ccdInfo;
        if (_ccdinfo != nil) {
            NSLog(@"\t\tCCD Info for the Medications:");
            NSLog(@"\t\t\tisClinicalDrug:[%@]",_ccdinfo.isClinicalDrug);
            NSLog(@"\t\t\tcodeDisplayName:[%@]",_ccdinfo.codeDisplayName);
            NSLog(@"\t\t\tcodeDisplayNameRxCUI:[%@]",_ccdinfo.codeDisplayNameRxCUI);
            NSLog(@"\t\t\ttranslationDisplayName:[%@]",_ccdinfo.translationDisplayName);
            NSLog(@"\t\t\tingredientName:[%@]",_ccdinfo.ingredientName);
            NSLog(@"\t\t\ttranslationDisplayNameRxCUI:[%@]",_ccdinfo.translationDisplayNameRxCUI);
            NSLog(@"\t\t\tBrandName:[%@]",_ccdinfo.brandName);
        } else {
            NSLog(@"\t\tNO CCD Info Property!!!!");

        }
        NSLog(@"\n");
    }
}


- (void) printInsurance:(MMLInsurance *)insurance type:(NSString *)type {
    if (insurance == nil) {
        NSLog(@" NO %@ insurance defined!!!!",type);
        return;
    }
     NSLog(@"\t%@ insurance",type);
     NSLog(@"\t\tCarrier:[%@]",insurance.carrier);
     NSLog(@"\t\tGrounp:[%@]",insurance.groupNumber);
     NSLog(@"\t\tRX IN:[%@]",insurance.rxIN);
     NSLog(@"\t\tRX PCN:[%@]",insurance.rxPCN);
     NSLog(@"\t\trx Group:[%@]",insurance.rxGroup);
     NSLog(@"\t\tmember Number:[%@]",insurance.memberNumber);
}
- (void) printPersonData:(MMLPersonData *)person{
    NSLog(@"User ID:[%@]",person.userId);
    NSLog(@"First Name:[%@]",person.firstName);
    NSLog(@"Last Name:[%@]",person.lastName);
    NSLog(@"Gender:[%@]",person.gender);
    NSLog(@"dateOfBirth:[%@]",person.dateOfBirth);
    NSLog(@"phoneNumber:[%@]",person.phoneNumer);
    NSLog(@"stree Addr1:[%@]",person.streetAddress1);
    NSLog(@"Stree Addr2:[%@]",person.streetAddress2);
    NSLog(@"city:[%@]",person.city);
    NSLog(@"state:[%@]",person.state);
    NSLog(@"zip:[%@]",person.zip);
    [self printInsurance:person.insurance type:@"Primary "];
    [self printInsurance:person.secondaryInsurance type:@"Secondary "];
    [self printMedication:person.currentMedicationList type:@"Current "];
    [self printMedication:person.discontinuedMedicationList type:@"Discontinued "];
}
@end
