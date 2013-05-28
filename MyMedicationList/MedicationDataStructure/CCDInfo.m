//
//  CCDInfo.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "CCDInfo.h"


@implementation CCDInfo

@synthesize isClinicalDrug;
@synthesize codeDisplayName;
@synthesize codeDisplayNameRxCUI;
@synthesize translationDisplayName;
@synthesize translationDisplayNameRxCUI;
@synthesize ingredientName;
@synthesize brandName;


- (id)initWithIsClinicalDrug:(BOOL)isClinical
{    
    self = [super init];
    
    if (self) 
	{
		isClinicalDrug = isClinical;
		codeDisplayName = nil;
		codeDisplayNameRxCUI = nil;
		translationDisplayName = nil;
		translationDisplayNameRxCUI = nil;
		ingredientName = nil;
		brandName = nil;
    }
    return self;
}


- (void)setClinicalInfoWithCodeDisplayName:(NSString *)thisCodeDisplayName 
					  CodeDisplayNameRxCUI:(NSString *)thisCodeDisplayNameRxCUI 
							IngredientName:(NSString *)thisIngredientName
{
	self.codeDisplayName = thisCodeDisplayName;
	self.codeDisplayNameRxCUI = thisCodeDisplayNameRxCUI;
	self.ingredientName = thisIngredientName;
}

- (void)setBrandInfoWithCodeDisplayName:(NSString *)thisCodeDisplayName 
				   CodeDisplayNameRxCUI:(NSString *)thisCodeDisplayNameRxCUI 
				 TranslationDisplayName:(NSString *)thisTranslationDisplayName 
			TranslationDisplayNameRxCUI:(NSString *)thisTranslationDisplayNameRxCUI 
						 IngredientName:(NSString *)thisIngredientName 
							  BrandName:(NSString *)thisBrandName							
{
	self.codeDisplayName = thisCodeDisplayName;
	self.codeDisplayNameRxCUI = thisCodeDisplayNameRxCUI;
	self.translationDisplayName = thisTranslationDisplayName;
	self.translationDisplayNameRxCUI = thisTranslationDisplayNameRxCUI;
	self.ingredientName = thisIngredientName;
	self.brandName = thisBrandName;
}

- (void)printCCD
{
	NSLog(@"%@",codeDisplayName);
	NSLog(@"%@",codeDisplayNameRxCUI);
	NSLog(@"%@",translationDisplayName);
	NSLog(@"%@",translationDisplayNameRxCUI);
	NSLog(@"%@",brandName);
	NSLog(@"%@",ingredientName);	
}


- (id) mutableCopy
{
	return [self mutableCopyWithZone:nil];
}

- (id) mutableCopyWithZone:(NSZone *)zone
{
	CCDInfo *newCCDInfo = [[CCDInfo alloc] initWithIsClinicalDrug:self.isClinicalDrug];
	
	if(isClinicalDrug)
		[newCCDInfo setClinicalInfoWithCodeDisplayName:self.codeDisplayName 
								  CodeDisplayNameRxCUI:self.codeDisplayNameRxCUI 
										IngredientName:self.ingredientName];
	else
		[newCCDInfo setBrandInfoWithCodeDisplayName:self.codeDisplayName 
							   CodeDisplayNameRxCUI:self.codeDisplayNameRxCUI 
							 TranslationDisplayName:self.translationDisplayName 
						TranslationDisplayNameRxCUI:self.translationDisplayNameRxCUI 
									 IngredientName:self.ingredientName
										  BrandName:self.brandName];

	return newCCDInfo;				   
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeBool:isClinicalDrug forKey:@"IsClinicalDrug"];
	[aCoder encodeObject:codeDisplayName forKey:@"CodeDisplayName"];
	[aCoder encodeObject:codeDisplayNameRxCUI forKey:@"CodeDisplayNameRxCUI"];
	[aCoder encodeObject:translationDisplayName forKey:@"TranslationDisplayName"];
	[aCoder encodeObject:translationDisplayNameRxCUI forKey:@"TranslationDisplayNameRxCUI"];
	[aCoder encodeObject:ingredientName forKey:@"IngredientName"];
	[aCoder encodeObject:brandName forKey:@"BrandName"];	
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	
	self = [super init];
	
	if (self != nil)
	{
		isClinicalDrug = [aDecoder decodeBoolForKey:@"IsClinicalDrug"];
		codeDisplayName = [aDecoder decodeObjectForKey:@"CodeDisplayName"];
		[codeDisplayName retain];
		codeDisplayNameRxCUI = [aDecoder decodeObjectForKey:@"CodeDisplayNameRxCUI"];
		[codeDisplayNameRxCUI retain];
		translationDisplayName = [aDecoder decodeObjectForKey:@"TranslationDisplayName"];
		[translationDisplayName retain];
		translationDisplayNameRxCUI = [aDecoder decodeObjectForKey:@"TranslationDisplayNameRxCUI"];
		[translationDisplayNameRxCUI retain];
		ingredientName = [aDecoder decodeObjectForKey:@"IngredientName"];
		[ingredientName retain];
		brandName = [aDecoder decodeObjectForKey:@"BrandName"];
		[brandName retain];
	}
	return self;
}

- (void)dealloc 
{
    [brandName release];
    [ingredientName release];
    [translationDisplayName release];
    [translationDisplayNameRxCUI release];
    [codeDisplayName release];
    [codeDisplayNameRxCUI release];
    NSLog(@"Dealloc - CCDInfo");
    [super dealloc];
}


@end
