//
//  RxNormWebDataObject.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "RxNormWebDataObject.h"
#import "JSON.h"
#import "sqlite3.h"
#import "CCDInfo.h"
#import "ConceptProperty.h"
#import "WebDataOperation.h"

enum TERMTYPE {
	IN,
	PIN,
	MIN,
	BN,
	SBD,
	SBDC,
	SCD,
	SCDC,
	SCDF,
	DF,
	BPCK,
	GPCK
};
typedef enum TERMTYPE TERMTYPE;


@interface RxNormWebDataObject (){
	NSString *displayNames; // This is unnecessary, an attempt to get around a data issue, should be deleted
	NSURL *url;
	NSMutableURLRequest *request;
	NSURLConnection *theConnection;
	NSMutableData *receivedData;
	
	id <RxNormWebDataDelegate> delegate;
@private
	BOOL isCancelled;
}

@end

@implementation RxNormWebDataObject
@synthesize delegate;

static NSString * const rxnavBase = @"http://rxnav.nlm.nih.gov/REST/Prescribe/";
static NSOperationQueue *queue = nil;
static RxNormWebDataObject *instance = nil;

// Implementation of Singleton design pattern
+ (RxNormWebDataObject *)webDataObject
{
	/* TODO, this singleton pattern needs to be fixed, the implementation below is functional but not complete
	*/
	if(instance == nil)
	{
		instance = [[super allocWithZone:NULL] init];
		queue = [[NSOperationQueue alloc] init];
	}
		 
	return instance;
}


- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax;
}

- (oneway void)release
{
	NSLog(@"We will do nothing");
}

- (id)autorelease
{
	return self;
}

- (void)cancel
{
	isCancelled = YES;
	[queue cancelAllOperations];
}
 
- (void)returnFailed
{
    NSLog(@"returnFailed");
    [delegate rxNormWebDataObjectDidFail:self];
}

- (void)returnResult:(id)result
{
    NSLog(@"returnResult:");
    [delegate rxNormWebDataObject:self didReturnResult:result];
}

-(void) returnWarn:(id)result
{
    [delegate rxNormWebDataObjectDidWarn:self warningMessage:result];
}

- (void)getConceptPropertiesDataHandler:(NSMutableData *)data context:(id)contextObject
{
	NSLog(@"getConceptPropertiesDataHandler");
	
	if(data == nil)
    {
		//[delegate rxNormWebDataObjectDidFail:self];
        [self performSelectorOnMainThread:@selector(returnFailed) withObject:nil waitUntilDone:NO]; return;
    }
	   
	NSError *jsonParsingError = nil;
    NSDictionary *drugProperties = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
	
    NSDictionary *related = [drugProperties objectForKey:@"relatedGroup"];
    NSMutableArray *conceptPropertiesArray = [NSMutableArray array];

    NSMutableArray *bpckConceptPropertiesArray = [NSMutableArray array];
    NSMutableArray *scdConceptPropertiesArray = [NSMutableArray array];
    NSMutableArray *sbdConceptPropertiesArray = [NSMutableArray array];
    NSMutableArray *gpckConceptPropertiesArray = [NSMutableArray array];
	NSArray *conceptGroup = [related objectForKey:@"conceptGroup"];
	
	//NSDictionary *groups = [conceptGroup objectAtIndex:0];
    for (NSDictionary *groups in conceptGroup) {
	
        NSArray *conceptProperties = [groups objectForKey:@"conceptProperties"];		
	
        ConceptProperty *concept;
        for(NSDictionary *conceptDictionary in conceptProperties)
        {
            concept = [[[ConceptProperty alloc] init] autorelease];
            concept.rxcui = [conceptDictionary objectForKey:@"rxcui"];
            concept.name = [conceptDictionary objectForKey:@"name"];
            concept.synonym = [conceptDictionary objectForKey:@"synonym"];
            concept.termtype = [conceptDictionary objectForKey:@"tty"];
            concept.language = [conceptDictionary objectForKey:@"language"];
            concept.suppressflag = [conceptDictionary objectForKey:@"suppress"];
            concept.UMLSCUI = [conceptDictionary objectForKey:@"umlscui"];
            if ([self isPrescribable:concept.rxcui]) {
                if ([[conceptDictionary objectForKey:@"tty"] isEqualToString:@"SBD"]) {
                    [sbdConceptPropertiesArray addObject:concept ];
                } else if ([[conceptDictionary objectForKey:@"tty"] isEqualToString:@"SCD"]) {
                    [scdConceptPropertiesArray addObject:concept];
                } else if ([[conceptDictionary objectForKey:@"tty"] isEqualToString:@"BPCK"]) {
                   [gpckConceptPropertiesArray addObject:concept];
                } else if ([[conceptDictionary objectForKey:@"tty"] isEqualToString:@"GPCK"]) {
                    [bpckConceptPropertiesArray addObject:concept];

                }
                //[conceptPropertiesArray addObject:[concept autorelease]];
            }
	}
    }
    if ([sbdConceptPropertiesArray count] != 0) {
        [conceptPropertiesArray addObjectsFromArray:sbdConceptPropertiesArray];
    }
    if ([scdConceptPropertiesArray count] != 0) {
        [conceptPropertiesArray addObjectsFromArray:scdConceptPropertiesArray];
    }
    if ([bpckConceptPropertiesArray count] != 0) {
        [conceptPropertiesArray addObjectsFromArray:bpckConceptPropertiesArray];
    }
    if ([gpckConceptPropertiesArray count] != 0) {
        [conceptPropertiesArray addObjectsFromArray:gpckConceptPropertiesArray];
    }
    if ([conceptPropertiesArray count] == 0) {
        if ([(NSString *)contextObject isEqualToString:@"MIN"] || [(NSString *) contextObject isEqualToString:@"PIN"] ||[(NSString *) contextObject isEqualToString:@"IN"]) {
            if(!isCancelled)
                [self performSelectorOnMainThread:@selector(returnWarn:) withObject:@"Unable to find prescribable drugs that have the selected search ingredients!!" waitUntilDone:NO];
        } else {
            if(!isCancelled)
                [self performSelectorOnMainThread:@selector(returnWarn:) withObject:@"Unable to find prescribable drugs that have the selected search criteria!!" waitUntilDone:NO];   
        }
        
    } else {
        if(!isCancelled)
            [self performSelectorOnMainThread:@selector(returnResult:) withObject:conceptPropertiesArray waitUntilDone:NO];
    }
}

- (void)addWebDataOperationForURL:(NSString *)urlString usesJSON:(BOOL)usesJSON dataHandler:(SEL)handler context:(id)context
{
    // Setup the web data operation with JSON option and the handler which receives the return value. 
    // If not nil, the context will be passed along to the data handler 
    WebDataOperation *webDataOperation = [[WebDataOperation alloc] initWithURLString:urlString usesJSON:usesJSON withDataHandler:handler withContext:context forError:@selector(errorHandler:)];
    webDataOperation.dataHandlerDelegate = self;
    
    // We are running a new operation that has not been cancelled yet
    isCancelled = NO;
    
    // Run the operation
    [queue addOperation:webDataOperation];
    [webDataOperation release];
}

- (void)addWebDataOperationForURL:(NSString *)urlString usesJSON:(BOOL)usesJSON dataHandler:(SEL)handler
{
    [self addWebDataOperationForURL:urlString usesJSON:usesJSON dataHandler:handler context:nil];
}

- (void) errorHandler:(NSString *) errorMessage {
    [self performSelectorOnMainThread:@selector(returnWarn:) withObject:errorMessage waitUntilDone:NO]; }
- (void)getDrugPropertiesDataHandler:(NSMutableData *)data
{
	NSLog(@"getDrugPropertiesDataHandler");
	NSString *drugPropertiesString = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];

	if(drugPropertiesString == nil)
    {
		//[delegate rxNormWebDataObjectDidFail:self];
        //return;
        [self performSelectorOnMainThread:@selector(returnFailed) withObject:nil waitUntilDone:NO]; return;
    }
	
    NSLog(@"drugPropertiesString = %@",drugPropertiesString);
    
    NSError *jsonParsingError = nil;
    NSDictionary *properties = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
	NSDictionary *propertyDict = [properties objectForKey:@"properties"];
	
	
	NSLog(@"Here are all the keys returned from the JSON string");
	for(NSString *key in [propertyDict allKeys])
		NSLog(@"%@",key);
	
	ConceptProperty *drugInformation = [[[ConceptProperty alloc] init] autorelease];
	drugInformation.rxcui = [propertyDict objectForKey:@"rxcui"];
	drugInformation.name = [propertyDict objectForKey:@"name"];
	drugInformation.synonym = [propertyDict objectForKey:@"synonym"];
	drugInformation.termtype = [propertyDict objectForKey:@"tty"];
	drugInformation.language = [propertyDict objectForKey:@"language"];
	drugInformation.suppressflag = [propertyDict objectForKey:@"suppress"];
	drugInformation.UMLSCUI = [propertyDict objectForKey:@"umlscui"];
	
	
	NSString *termtype = [drugInformation termtype];
	NSString *urlString = nil;
	if(([termtype isEqualToString:@"BN"])||([termtype isEqualToString:@"SBD"]))
	    urlString = [NSString stringWithFormat:@"%@rxcui/%@/related?tty=SBD+BPCK",rxnavBase,[drugInformation rxcui]];
	else if(([termtype isEqualToString:@"IN"])||([termtype isEqualToString:@"PIN"])||([termtype isEqualToString:@"MIN"])||([termtype isEqualToString:@"SCD"]))
   	    urlString = [NSString stringWithFormat:@"%@rxcui/%@/related?tty=SCD+GPCK",rxnavBase,[drugInformation rxcui]];
	else if([termtype isEqualToString:@"BPCK"])
   	    urlString = [NSString stringWithFormat:@"%@rxcui/%@/related?tty=BPCK",rxnavBase,[drugInformation rxcui]];
	else if([termtype isEqualToString:@"GPCK"])
   	    urlString = [NSString stringWithFormat:@"%@rxcui/%@/related?tty=GPCK",rxnavBase,[drugInformation rxcui]];
	else
		NSLog(@"We missed one of the term type cases.");
	
	
	if(!isCancelled)
        [self addWebDataOperationForURL:urlString usesJSON:YES dataHandler:@selector(getConceptPropertiesDataHandler:context:) context:termtype];

}

- (void)getRxcuiWithDisplayNameDataHandler:(NSMutableData *)data
{
	NSLog(@"getRxcuiWithDisplayNameDataHandler");
	if(data == nil)
    {
        [self performSelectorOnMainThread:@selector(returnFailed) withObject:nil waitUntilDone:NO]; return;
    }
	
	NSString *rxcuiString = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	
    NSLog(@"rxcuiString = %@",rxcuiString);
    
	if((rxcuiString == nil)||([rxcuiString length] == 0))
    {
        [self performSelectorOnMainThread:@selector(returnFailed) withObject:nil waitUntilDone:NO]; return;
    }

	else{
            
        NSError *jsonParsingError = nil;
        NSDictionary *rxcuiObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        NSString *rxcui = (NSString *)[[[rxcuiObject objectForKey:@"idGroup"] objectForKey:@"rxnormId"] objectAtIndex:0];
        
        if(rxcui == nil)
        {
            [self performSelectorOnMainThread:@selector(returnFailed) withObject:nil waitUntilDone:NO]; return;
        }
            
        if(!isCancelled)
        {
            NSString *urlString = [NSString stringWithFormat:@"%@rxcui/%@/properties",rxnavBase,rxcui];
            [self addWebDataOperationForURL:urlString usesJSON:YES dataHandler:@selector(getDrugPropertiesDataHandler:)];
        }
    }
}

- (void)getConceptPropertiesWithDisplayName:(NSString *)displayName
{
	NSLog(@"getConceptPropertiesWithDisplayName");
    NSString *encoded_string = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)displayName,
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[] ",
                                                                                  kCFStringEncodingUTF8 );
    // Construct url from the displayname whose RxCUI we need
	NSString *urlString = [NSString stringWithFormat:@"%@rxcui?name=%@",rxnavBase,encoded_string];

    // Use the percent escaped version of the string for the call. Otherwise we get a 'Bad URL' error
    [self addWebDataOperationForURL:urlString usesJSON:YES dataHandler:@selector(getRxcuiWithDisplayNameDataHandler:)];
      CFRelease(encoded_string);
}

- (void)getCCDInfoForConceptPropertyDataHandler:(NSMutableData *)data context:(id)contextObject
{
    
    //NSLog(@"Start here....");
    
    CCDInfo *newCCD = nil;
    ConceptProperty *conceptProperty = (ConceptProperty *)contextObject;

    [conceptProperty printConceptProperty];
    
    BOOL isClinicalDrug = YES;
    
    if([conceptProperty.termtype isEqualToString:@"SCD"])
        isClinicalDrug = YES;
    else if([conceptProperty.termtype isEqualToString:@"IN"])
        isClinicalDrug = YES;
    else if([conceptProperty.termtype isEqualToString:@"SBD"])
        isClinicalDrug = NO;
    else if([conceptProperty.termtype isEqualToString:@"BPCK"])
        isClinicalDrug = NO;
    else 
        isClinicalDrug = YES;
    
    newCCD = [[[CCDInfo alloc] initWithIsClinicalDrug:isClinicalDrug] autorelease];    
    
    if(data == nil)
    {
        [self performSelectorOnMainThread:@selector(returnFailed) withObject:nil waitUntilDone:NO]; 
        return;
    }
    
	NSString *propertiesString = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
    
    if(propertiesString == nil)
    {
        [self performSelectorOnMainThread:@selector(returnFailed) withObject:nil waitUntilDone:NO]; 
        return;
    }
    
    NSLog(@"propertiesString = %@",propertiesString);
    
    NSError *jsonParsingError = nil;
    NSDictionary *drugProperties = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    if(drugProperties == nil)
    {
        [self performSelectorOnMainThread:@selector(returnFailed) withObject:nil waitUntilDone:NO]; 
        return;
    }
    
	if(isClinicalDrug)
	{
		
		NSDictionary *related = [drugProperties objectForKey:@"relatedGroup"];
		
		NSArray *conceptGroup = [related objectForKey:@"conceptGroup"];
		
		NSDictionary *INgroup = [conceptGroup objectAtIndex:0];
		
		NSArray *INconceptProperties = [INgroup objectForKey:@"conceptProperties"];		
        
        
        NSMutableString *ingredientName = nil;
        for (NSDictionary *ingredientDict in INconceptProperties) {
            if(ingredientName == nil) {
                ingredientName = [[[NSMutableString alloc]init] autorelease];
                [ingredientName appendString:[NSString stringWithFormat:@"%@",[ingredientDict objectForKey:@"name"]]];
            } else
                [ingredientName appendString:[NSString stringWithFormat:@" / %@",[ingredientDict objectForKey:@"name"]]];
        }

        
        
        NSLog(@"THE clinical ingredient name = %@",ingredientName);
        NSLog(@"length = %d",[ingredientName length]);
        
		[newCCD setClinicalInfoWithCodeDisplayName:[conceptProperty name] 
							  CodeDisplayNameRxCUI:[conceptProperty rxcui] 
									IngredientName:ingredientName];
        
        
        
	}
	else// if([conceptProperty.termtype isEqualToString:@"SBD"])
	{
		
		NSDictionary *related = [drugProperties objectForKey:@"relatedGroup"];
		
		NSArray *conceptGroups = [related objectForKey:@"conceptGroup"];
		
        NSArray *SCDconceptProperties = nil;    
        NSArray *BNconceptProperties = nil;
        NSMutableArray *INconceptProperties = nil;
        
        NSString *ttyString = nil;
        for (NSDictionary *conceptGroup in conceptGroups) {
            ttyString = [conceptGroup objectForKey:@"tty"];
            if([ttyString compare:@"SCD" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                SCDconceptProperties = [conceptGroup objectForKey:@"conceptProperties"];

            }
            else if([ttyString compare:@"BN" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                BNconceptProperties = [conceptGroup objectForKey:@"conceptProperties"];

            }
            else if([ttyString compare:@"IN" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                INconceptProperties = [conceptGroup objectForKey:@"conceptProperties"];
            }
        }

        NSMutableString *ingredientName = nil;
        for (NSDictionary *ingredientDict in INconceptProperties) {
            if(ingredientName == nil) {
                ingredientName = [[[NSMutableString alloc]init] autorelease];
                [ingredientName appendString:[NSString stringWithFormat:@"%@",[ingredientDict objectForKey:@"name"]]];
            } else 
            [ingredientName appendString:[NSString stringWithFormat:@" / %@",[ingredientDict objectForKey:@"name"]]];
        }
        
        NSLog(@"THE brand ingredient name = %@",ingredientName);
        NSLog(@"length = %d",[ingredientName length]);
        
		[newCCD setBrandInfoWithCodeDisplayName:[[SCDconceptProperties objectAtIndex:0] objectForKey:@"name"]
						   CodeDisplayNameRxCUI:[[SCDconceptProperties objectAtIndex:0] objectForKey:@"rxcui"]
						 TranslationDisplayName:(([conceptProperty synonym] == nil)|| ([[conceptProperty synonym] isEqualToString:@""]))? [conceptProperty name] : [conceptProperty synonym] 
					TranslationDisplayNameRxCUI:[conceptProperty rxcui] 
								 IngredientName:ingredientName//[[INconceptProperties objectAtIndex:0] objectForKey:@"name"]
									  BrandName:[[BNconceptProperties objectAtIndex:0] objectForKey:@"name"]];
        
	}   
    
    if(!isCancelled)
        [self performSelectorOnMainThread:@selector(returnResult:) withObject:newCCD waitUntilDone:NO];
    
}

- (void)getCCDInfo:(ConceptProperty *)conceptProperty
{

    NSString *urlString = nil;
    
	if(([conceptProperty.termtype isEqualToString:@"SCD"])||([conceptProperty.termtype isEqualToString:@"IN"]))
        urlString = [NSString stringWithFormat:@"%@rxcui/%@/related?tty=IN",rxnavBase,conceptProperty.rxcui];
    else if([conceptProperty.termtype isEqualToString:@"BPCK"])
        urlString = [NSString stringWithFormat:@"%@rxcui/%@/related?tty=BPCK",rxnavBase,conceptProperty.rxcui];
	else// if([conceptProperty.termtype isEqualToString:@"SBD"])
        urlString = [NSString stringWithFormat:@"%@rxcui/%@/related?tty=SCD+BN+IN",rxnavBase,conceptProperty.rxcui];
    
	[self addWebDataOperationForURL:urlString usesJSON:YES dataHandler:@selector(getCCDInfoForConceptPropertyDataHandler:context:) context:conceptProperty];
}

- (void)getDisplayNamesDataHandler:(NSMutableData *)data
{

   // NSString *displayNamesString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    if(data == nil)
    {
        NSLog(@"There was a problem downloading and converting the display names data");
        NSNotification *notification = [NSNotification notificationWithName:MMLDisplayNamesUpdatingFailedNotification 
                                                                     object:self
                                                                   userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
        
        return;
    }
    
    
    
    NSError *jsonParsingError = nil;
    NSDictionary *displayTerms = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    if(displayTerms == nil)
    {
        NSLog(@"There was a problem parsing the displaynames JSON"); // Replace this with a failure notification later
        NSNotification *notification = [NSNotification notificationWithName:MMLDisplayNamesUpdatingFailedNotification 
                                                                     object:self
                                                                   userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    NSDictionary *displayTermsList = [displayTerms objectForKey:@"displayTermsList"];    
    

    //NSArray *terms = [NSArray arrayWithObjects:@"adrucil",@"adsorbocarpine",@"adsorbonac", nil];
    //NSArray *terms = [NSArray arrayWithObjects:@"ar",@"ee",@"f",@"nelly", nil];
    
    //NSDictionary *displayTermsList = [NSDictionary dictionaryWithObject:terms forKey:@"term"];

    NSNotification *notification = [NSNotification notificationWithName:MMLDisplayNamesFinishedDownloadingNotification 
                                                                 object:self
                                                               userInfo:displayTermsList];

    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
    
}

- (void)getDisplayNames
{
    // http://rxnav.nlm.nih.gov/REST/displaynames
    NSString *urlString = [NSString stringWithFormat:@"%@displaynames",rxnavBase];

    [self addWebDataOperationForURL:urlString usesJSON:YES dataHandler:@selector(getDisplayNamesDataHandler:)];
}

- (UIImage *)getMedicationImage:(NSString *)rxcuiString
{
	//url = [NSURL URLWithString:[NSString stringWithFormat:@"%@rxcui/%@/properties",rxnavBase,rxcui]];
	//url = [NSURL URLWithString:@"http://images.mirror.co.uk/upl/m4/nov2009/1/0/heroin-user-pic-getty-573408488.jpg"];
	//url = [NSURL URLWithString:@"http://dailymed.nlm.nih.gov/dailymed/images/products/000512a_s.jpg"];
	//<img src="./images/products/000035a_l.jpg" />
	//http://dailymed.nlm.nih.gov/dailymed/images/products/000035a_l.jpg
	
	NSString *dailymedBase = @"http://dailymed.nlm.nih.gov/dailymed";
	NSString *urlString = [NSString stringWithFormat:@"%@/rxcuiDrugImage.cfm?key=42263e5c3f&rxcui=%@&size=large",dailymedBase,rxcuiString];
	
	url = [NSURL URLWithString:urlString];
	request = [[NSMutableURLRequest alloc] initWithURL:url 
										   cachePolicy:NSURLRequestReloadIgnoringCacheData 
									   timeoutInterval:30.0];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	
	receivedData = nil;
	receivedData = (NSMutableData *)[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[request release];

	if(receivedData == nil)
		NSLog(@"No data for the image was returned");
	
	UIImage *medImage = nil;
	
	medImage = [UIImage imageWithData:receivedData];
	
	return medImage;
}

- (NSString *)getIngredient:(NSString *)rxcuiString
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@rxcui/%@/related?tty=IN",rxnavBase,rxcuiString];
    
    url = [NSURL URLWithString:urlString];
	request = [[NSMutableURLRequest alloc] initWithURL:url 
										   cachePolicy:NSURLRequestReloadIgnoringCacheData 
									   timeoutInterval:30.0];
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	NSURLResponse *response = nil;
	NSError *error = nil;
	
	receivedData = nil;
	receivedData = (NSMutableData *)[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[request release];
    
	if(receivedData == nil)
		NSLog(@"No data for the ingredient name was returned");
    
    NSString *propertiesString = [[[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding] autorelease];
    
    if(propertiesString == nil)
    {
        NSLog(@"The string with the ingredient data could not be created from the data");
        return nil;
    }
    
    NSError *jsonParsingError = nil;
    NSDictionary *drugProperties = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&jsonParsingError];
    
    NSDictionary *relatedGroup = [drugProperties objectForKey:@"relatedGroup"];
    
    NSArray *conceptGroup = [relatedGroup objectForKey:@"conceptGroup"];
    
    NSDictionary *INgroup = [conceptGroup objectAtIndex:0];
    
    NSArray *INconceptProperties = [INgroup objectForKey:@"conceptProperties"];	
    
    NSString *ingredient = [[INconceptProperties objectAtIndex:0] objectForKey:@"name"];
    
    return ingredient;
}


-(void) dealloc
{
	[receivedData release];
	[super dealloc];
}
-(NSMutableData *) callRxNavService:(NSString *)urlString {
    NSURL *urlStr = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
	NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] initWithURL:urlStr 
                                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                             timeoutInterval:30.0];
	[request1 addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	
	NSMutableData *rData = nil;
	rData = (NSMutableData *)[NSURLConnection sendSynchronousRequest:request1 returningResponse:&response error:&error];
	[request1 release];
    
    if(error != nil) {
        NSLog(@"%@",[error description]);
        return nil;
    }
    return rData;
}
- (BOOL)isPrescribable:(NSString *)rxcui
{
	return YES;
    NSLog(@"isPrescribable");
    // Construct url from the displayname whose RxCUI we need
    //http://rxnav.nlm.nih.gov/REST/rxcui/1049637/allProperties?prop=ATTRIBUTES
	NSString *urlString = [NSString stringWithFormat:@"%@rxcui/%@/allProperties?prop=ATTRIBUTES",rxnavBase,rxcui];
    
    // Use the percent escaped version of the string for the call. Otherwise we get a 'Bad URL' error
    NSMutableData *rData = [self callRxNavService:urlString];    
    NSString *rxcuiString = nil;
    rxcuiString = [[NSString alloc] initWithData:rData encoding:NSASCIIStringEncoding];
    NSError *jsonParsingError = nil;
    NSDictionary *rxcuiObject = [NSJSONSerialization JSONObjectWithData:rData options:0 error:&jsonParsingError];
    
    NSDictionary *related = [rxcuiObject objectForKey:@"propConceptGroup"];
    
    NSArray *conceptGroup = [related objectForKey:@"propConcept"];
    
    for (int i=0; i< [conceptGroup count];i++) {
        if ([[[conceptGroup objectAtIndex:i] objectForKey:@"propName"] isEqualToString:@"PRESCRIBABLE"]) {
            if ([[[conceptGroup objectAtIndex:i] objectForKey:@"propValue"] isEqualToString:@"Y"]) {
                return YES;
            }
        }
    }
    return NO;
}


-(NSMutableArray *) getDrugConcepts:(NSString *) rxcui forTTY:(NSString *) ttyString {
    NSString *urlString = [NSString stringWithFormat:@"%@rxcui/%@/related?tty=%@",rxnavBase,rxcui,ttyString];
    NSMutableData *data = [self callRxNavService:urlString];
    NSMutableArray *rArray = [[[NSMutableArray alloc] init] autorelease];
    NSError *jsonParsingError = nil;
    NSDictionary *properties = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
	NSDictionary *propertyDict = [properties objectForKey:@"relatedGroup"];
	
    NSArray *conceptGroup = [propertyDict objectForKey:@"conceptGroup"];
    
	NSLog(@"Here are all the keys returned from the JSON string");
	for(NSString *key in [propertyDict allKeys])
		NSLog(@"%@",key);
	BOOL sbdBool = NO;
    for (int i=0; i < [conceptGroup count]; i++ ) {
        NSString *tty = [[conceptGroup objectAtIndex:i] objectForKey:@"tty"];
        NSArray *conceptProps = [[conceptGroup objectAtIndex:i] objectForKey:@"conceptProperties"];
        if ([conceptProps count] > 0 && [tty isEqualToString:@"SBD"]) {
            sbdBool = YES; 
        }
        if (sbdBool) {
            if ([tty isEqualToString:@"SCD"] || [tty isEqualToString:@"GPCK"]) {
                continue;
            }
        }
        // Read the conceptProperties Array
        
        
        for (int j=0; j < [conceptProps count]; j++) {
            NSString *rxcui = [[conceptProps objectAtIndex:j] objectForKey:@"rxcui"];
            NSString *name = [[conceptProps objectAtIndex:j] objectForKey:@"name"];
            NSString *tty = [[conceptProps objectAtIndex:j] objectForKey:@"tty"];
            
            NSString *synonym = [[conceptProps objectAtIndex:j] objectForKey:@"synonym"];
            
            NSString *language = [[conceptProps objectAtIndex:j] objectForKey:@"language"];
            
            NSString *suppress = [[conceptProps objectAtIndex:j] objectForKey:@"suppress"];
            NSString *umlscui = [[conceptProps objectAtIndex:j] objectForKey:@"umlscui"];
            if (rxcui != nil && ![rxcui isEqualToString:@""] && suppress != nil && ![suppress isEqualToString:@"Y"]) {
                if ([self isPrescribable:rxcui]) {
                    ConceptProperty *drugInformation = [[[ConceptProperty alloc] init] autorelease];
                    drugInformation.rxcui = rxcui;
                    drugInformation.name = name;
                    drugInformation.synonym = synonym;
                    drugInformation.termtype = tty;
                    drugInformation.language = language;
                    drugInformation.suppressflag = suppress;
                    drugInformation.UMLSCUI = umlscui;
                    [rArray addObject:drugInformation];
                }
            }
            
        }
        
    }
    return rArray;
}
- (void)getConceptPropertiesUsingApproxMatchWithDisplayName:(NSString *)displayName {
    isCancelled = NO;
    
    NSString *encoded_string = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                   NULL,
                                                                                   (CFStringRef)displayName,
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8 );
    NSInvocationOperation *inv = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(getApproximateMatch:) object:encoded_string];
    [queue addOperation:inv];
    CFRelease(encoded_string);
}
- (void) getApproximateMatch:(NSString *) term {
    NSString *encoded_string = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                   NULL,
                                                                                   (CFStringRef)term,
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8 );
    term = [term stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    term = [term stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
    NSString *urlString = [NSString stringWithFormat:@"%@approx?term=%@",rxnavBase,encoded_string];
    NSMutableData *rData = [self callRxNavService:urlString];
      CFRelease(encoded_string);
    if(rData == nil)
    {
		//[delegate rxNormWebDataObjectDidFail:self];
        [self performSelectorOnMainThread:@selector(returnFailed) withObject:nil waitUntilDone:NO]; return;
    }
    
    NSError *jsonParsingError = nil;
    NSMutableArray *processedDataArray = [[[NSMutableArray alloc]init] autorelease];
    NSDictionary *rxcuiObject = [NSJSONSerialization JSONObjectWithData:rData options:0 error:&jsonParsingError];
    NSDictionary *related = [rxcuiObject objectForKey:@"approxGroup"];
    
    NSArray *candidates = [related objectForKey:@"candidate"];
	NSMutableSet *conceptPropertiesArray = [NSMutableSet set];
    
    for (int i =0; i< [candidates count] && !isCancelled; i++) {
        if ([[candidates objectAtIndex:i] objectForKey:@"rxcui"]) {
            NSString *rxcui = [[candidates objectAtIndex:i] objectForKey:@"rxcui" ];
            if (![processedDataArray containsObject:rxcui]) {
                [processedDataArray addObject:rxcui];
                // Get SBD, SCD, GPCK, BPCK now for this rxcui
                // Write a small method that retuns an array of concepts
                // add them to some new array and finally return them.
                
                
                NSString *score = [[candidates objectAtIndex:i] objectForKey:@"score"];
                if ((score !=nil && ![score isEqualToString:@""] &&
                     [score intValue] < 67 ) || [conceptPropertiesArray count] == 0) {
                    NSMutableArray *array = [self getDrugConcepts:rxcui forTTY:@"SBD+BPCK"];
                    if (array != nil && [array count] > 0) {
                        [conceptPropertiesArray addObjectsFromArray:array];
                    }
                }
            }
        }
    }
    [processedDataArray removeAllObjects];
    for (int i =0; i< [candidates count] && !isCancelled && [conceptPropertiesArray count] == 0; i++) {
        if ([[candidates objectAtIndex:i] objectForKey:@"rxcui"]) {
            NSString *rxcui = [[candidates objectAtIndex:i] objectForKey:@"rxcui"];
            if (![processedDataArray containsObject:rxcui]) {
                [processedDataArray addObject:rxcui];
                // Get SBD, SCD, GPCK, BPCK now for this rxcui
                // Write a small method that retuns an array of concepts
                // add them to some new array and finally return them.
                NSString *score = [[candidates objectAtIndex:i] objectForKey:@"score"];
                if ((score !=nil && ![score isEqualToString:@""] &&
                     [score intValue] < 67 ) || [conceptPropertiesArray count] == 0) {
                    NSMutableArray *array = [self getDrugConcepts:rxcui forTTY:@"SCD+GPCK"];
                    if (array != nil && [array count] > 0) {
                        for (int i=0; i < [array count]; i++) {
                            [conceptPropertiesArray addObjectsFromArray:array];
                        }
                    }
                }
            }
        }
    }
    if(!isCancelled)
    {
        [self performSelectorOnMainThread:@selector(returnResult:) withObject:[NSMutableArray arrayWithArray:[conceptPropertiesArray allObjects]]  waitUntilDone:NO];
        //[delegate rxNormWebDataObject:self didReturnResult:conceptPropertiesArray];
    }
}


- (void)getPrescribableData:(NSMutableData *)data
{
	NSLog(@"getRxcuiWithDisplayNameDataHandler");
	if(data == nil)
    {
        // May be rxnav is down.
    }
	
	
}

- (void) getSplSetIdFromRxNav:(NSMutableData *)data {
    if(data == nil)
    {
		//[delegate rxNormWebDataObjectDidFail:self];
        [self performSelectorOnMainThread:@selector(returnFailed) withObject:nil waitUntilDone:NO]; return;
    }
	
	NSError *jsonParsingError = nil;
    NSDictionary *drugProperties = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    if (jsonParsingError != nil) {
        NSLog(@"The Error Value: %@", [jsonParsingError userInfo]);
    }
    
	NSDictionary *related = [drugProperties objectForKey:@"splSetIdGroup"];
	
	NSArray *conceptGroup = [related objectForKey:@"splSetId"];
	
    if ([conceptGroup count] > 0) {
        NSString *firstSplId = [conceptGroup objectAtIndex:0];
        if (firstSplId != nil || ![firstSplId isEqualToString:@""]) {
            if(!isCancelled)
            {
                [self performSelectorOnMainThread:@selector(returnResult:) withObject:firstSplId waitUntilDone:NO];
                return;
                //[delegate rxNormWebDataObject:self didReturnResult:conceptPropertiesArray];
            }
            
        }
    }
    
    // Final check This is crazy but that is how the data is coming from RXNAV
    
    NSString *firstSplId = [related objectForKey:@"splSetId"];
    if (firstSplId != nil || ![firstSplId isEqualToString:@""]) {
        if(!isCancelled)
        {
            [self performSelectorOnMainThread:@selector(returnResult:) withObject:firstSplId waitUntilDone:NO];
            return;
            //[delegate rxNormWebDataObject:self didReturnResult:conceptPropertiesArray];
        }
        
    }
    [self performSelectorOnMainThread:@selector(returnFailed) withObject:nil waitUntilDone:NO]; 
    return;
	
}

- (void)getSPLSetId:(NSString *)rxcuiValue
{
    NSLog(@"getConceptPropertiesWithDisplayName");
    // Construct url from the displayname whose RxCUI we need
    NSString *urlString = [NSString stringWithFormat:@"%@rxcui/%@/splsetid",rxnavBase,rxcuiValue];
    // Use the percent escaped version of the string for the call. Otherwise we get a 'Bad URL' error
    NSLog(@"URLSTRING IS %@",urlString);
    [self addWebDataOperationForURL:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] usesJSON:YES dataHandler:@selector(getSplSetIdFromRxNav:)];
    
    
    // We are running a new operation that has not been cancelled yet
    isCancelled = NO;
    
}
@end
