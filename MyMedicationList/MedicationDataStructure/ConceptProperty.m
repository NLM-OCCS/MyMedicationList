//
//  ConceptProperty.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "ConceptProperty.h"


@implementation ConceptProperty

@synthesize rxcui = _rxcui;
@synthesize name = _name;
@synthesize synonym = _synonym;
@synthesize termtype = _termtype;
@synthesize language = _language;
@synthesize suppressflag = _suppressflag;
@synthesize UMLSCUI = _UMLSCUI;

- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    
    return self;
}

- (void) dealloc
{
	self.rxcui = nil;
    self.name = nil;
    self.synonym = nil;
    self.termtype = nil;
    self.language = nil;
    self.suppressflag = nil;
    self.UMLSCUI = nil;
    NSLog(@"Dealloc Concept Property");
	[super dealloc];
}

- (void)printConceptProperty
{
	NSLog(@"RxCUI = %@",_rxcui);
	NSLog(@"Name = %@",_name);
	NSLog(@"Synonym = %@",_synonym);
	NSLog(@"Term type = %@",_termtype);
	NSLog(@"Language = %@",_language);
	NSLog(@"Suppression Flag = %@",_suppressflag);
	NSLog(@"UMLSCUI = %@",_UMLSCUI);	
}

- (id)mutableCopy
{
	return [self mutableCopyWithZone:nil];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    NSLog(@"ConceptProperty - mutableCopyWithZone");
    NSLog(@"ConceptProperty name = %@",self.name);
	ConceptProperty *newConceptProperty = [[ConceptProperty alloc] init];
	newConceptProperty.rxcui = [[self.rxcui copy] autorelease];
	newConceptProperty.name = [[self.name copy] autorelease];
	newConceptProperty.synonym = [[self.synonym copy] autorelease];
	newConceptProperty.termtype = [[self.termtype copy] autorelease];
	newConceptProperty.language = [[self.language copy] autorelease];
	newConceptProperty.suppressflag = [[self.suppressflag copy] autorelease];
	newConceptProperty.UMLSCUI = [[self.UMLSCUI copy] autorelease];	
	
	return newConceptProperty;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_rxcui forKey:@"MMLrxcui"];
	[aCoder encodeObject:_name forKey:@"MMLname"];
	[aCoder encodeObject:_synonym forKey:@"MMLsynonym"];
	[aCoder encodeObject:_termtype forKey:@"MMLtermtype"];
	[aCoder encodeObject:_language forKey:@"MMLlanguage"];
	[aCoder encodeObject:_suppressflag forKey:@"MMLsuppressflag"];
	[aCoder encodeObject:_UMLSCUI forKey:@"MMLumlscui"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	if (self)
	{
		_rxcui = [aDecoder decodeObjectForKey:@"MMLrxcui"];
        [_rxcui retain];
		_name = [aDecoder decodeObjectForKey:@"MMLname"];
        [_name retain];
		_synonym = [aDecoder decodeObjectForKey:@"MMLsynonym"];
        [_synonym retain];
		_termtype = [aDecoder decodeObjectForKey:@"MMLtermtype"];
        [_termtype retain];
		_language = [aDecoder decodeObjectForKey:@"MMLlanguage"];
        [_language retain];
		_suppressflag = [aDecoder decodeObjectForKey:@"MMLsuppressflag"];
        [_suppressflag retain];
		_UMLSCUI = [aDecoder decodeObjectForKey:@"MMLumlscui"];
        [_UMLSCUI retain];
	}
	
	return self;
	
}
- (BOOL)isEqual:(id)otherObject;
{
    if ([otherObject isKindOfClass:[ConceptProperty class]]) {
        ConceptProperty *otherConcept= (ConceptProperty *)otherObject;
        if (![self.rxcui isEqualToString:otherConcept.rxcui]) return NO;
        return YES;
    }
    return NO;
}

- (NSUInteger) hash;
{
    return [self.rxcui intValue];
}


@end
