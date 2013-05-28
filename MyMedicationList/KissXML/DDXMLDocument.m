/**
 * Welcome to KissXML.
 *
 * The project page has documentation if you have questions.
 * https://github.com/robbiehanson/KissXML
 *
 * If you're new to the project you may wish to read the "Getting Started" wiki.
 * https://github.com/robbiehanson/KissXML/wiki/GettingStarted
 *
 * KissXML provides a drop-in replacement for Apple's NSXML class cluster.
 * The goal is to get the exact same behavior as the NSXML classes.
 *
 * For API Reference, see Apple's excellent documentation,
 * either via Xcode's Mac OS X documentation, or via the web:
 *
 * https://github.com/robbiehanson/KissXML/wiki/Reference
 Copyright (c) 2012, Robbie Hanson
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/
#import "DDXMLDocument.h"
#import "NSStringAdditions.h"
#import "DDXMLPrivate.h"


@implementation DDXMLDocument

+ (id)nodeWithPrimitive:(xmlKindPtr)nodePtr
{
	if(nodePtr == NULL || nodePtr->type != XML_DOCUMENT_NODE)
	{
		return nil;
	}
	
	xmlDocPtr doc = (xmlDocPtr)nodePtr;
	if(doc->_private == NULL)
		return [[[DDXMLDocument alloc] initWithCheckedPrimitive:nodePtr] autorelease];
	else
		return [[((DDXMLDocument *)(doc->_private)) retain] autorelease];
}

- (id)initWithUncheckedPrimitive:(xmlKindPtr)nodePtr
{
	if(nodePtr == NULL || nodePtr->type != XML_DOCUMENT_NODE)
	{
		[self release];
		return nil;
	}
	
	xmlDocPtr doc = (xmlDocPtr)nodePtr;
	if(doc->_private == NULL)
	{
		return [self initWithCheckedPrimitive:nodePtr];
	}
	else
	{
		[self release];
		return [((DDXMLDocument *)(doc->_private)) retain];
	}
}

- (id)initWithCheckedPrimitive:(xmlKindPtr)nodePtr
{
	self = [super initWithCheckedPrimitive:nodePtr];
	return self;
}

/**
 * Initializes and returns a DDXMLDocument object created from an NSData object.
 * 
 * Returns an initialized DDXMLDocument object, or nil if initialization fails
 * because of parsing errors or other reasons.
**/
- (id)initWithXMLString:(NSString *)string options:(NSUInteger)mask error:(NSError **)error
{
	return [self initWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:mask error:error];
}

/**
 * Initializes and returns a DDXMLDocument object created from an NSData object.
 * 
 * Returns an initialized DDXMLDocument object, or nil if initialization fails
 * because of parsing errors or other reasons.
**/
- (id)initWithData:(NSData *)data options:(NSUInteger)mask error:(NSError **)error
{
	if(data == nil || [data length] == 0)
	{
		if(error) *error = [NSError errorWithDomain:@"DDXMLErrorDomain" code:0 userInfo:nil];
		
		[self release];
		return nil;
	}
	
	// Even though xmlKeepBlanksDefault(0) is called in DDXMLNode's initialize method,
	// it has been documented that this call seems to get reset on the iPhone:
	// http://code.google.com/p/kissxml/issues/detail?id=8
	// 
	// Therefore, we call it again here just to be safe.
	xmlKeepBlanksDefault(0);
	
	xmlDocPtr doc = xmlParseMemory([data bytes], [data length]);
	if(doc == NULL)
	{
		if(error) *error = [NSError errorWithDomain:@"DDXMLErrorDomain" code:1 userInfo:nil];
		
		[self release];
		return nil;
	}
	
	return [self initWithCheckedPrimitive:(xmlKindPtr)doc];
}

/**
 * Returns the root element of the receiver.
**/
- (DDXMLElement *)rootElement
{
	xmlDocPtr doc = (xmlDocPtr)genericPtr;
	
	// doc->children is a list containing possibly comments, DTDs, etc...
	
	xmlNodePtr rootNode = xmlDocGetRootElement(doc);
	
	if(rootNode != NULL)
		return [DDXMLElement nodeWithPrimitive:(xmlKindPtr)(rootNode)];
	else
		return nil;
}

- (NSData *)XMLData
{
	return [[self XMLString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)XMLDataWithOptions:(NSUInteger)options
{
	return [[self XMLStringWithOptions:options] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
