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
#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@class DDXMLDocument;


enum {
	DDXMLInvalidKind                = 0,
	DDXMLDocumentKind               = XML_DOCUMENT_NODE,
	DDXMLElementKind                = XML_ELEMENT_NODE,
	DDXMLAttributeKind              = XML_ATTRIBUTE_NODE,
	DDXMLNamespaceKind              = XML_NAMESPACE_DECL,
	DDXMLProcessingInstructionKind  = XML_PI_NODE,
	DDXMLCommentKind                = XML_COMMENT_NODE,
	DDXMLTextKind                   = XML_TEXT_NODE,
	DDXMLDTDKind                    = XML_DTD_NODE,
	DDXMLEntityDeclarationKind      = XML_ENTITY_DECL,
	DDXMLAttributeDeclarationKind   = XML_ATTRIBUTE_DECL,
	DDXMLElementDeclarationKind     = XML_ELEMENT_DECL,
	DDXMLNotationDeclarationKind    = XML_NOTATION_NODE
};
typedef NSUInteger DDXMLNodeKind;

enum {
	DDXMLNodeOptionsNone                       = 0,
	DDXMLNodeExpandEmptyElement                = 1 << 1,
	DDXMLNodeCompactEmptyElement               = 1 << 2,
	DDXMLNodePrettyPrint                       = 1 << 17,
};

/**
 * DDXMLNode can represent several underlying types, such as xmlNodePtr, xmlDocPtr, xmlAttrPtr, xmlNsPtr, etc.
 * All of these are pointers to structures, and all of those structures start with a pointer, and a type.
 * The xmlKind struct is used as a generic structure, and a stepping stone.
 * We use it to check the type of a structure, and then perform the appropriate cast.
 * 
 * For example:
 * if(genericPtr->type == XML_ATTRIBUTE_NODE)
 * {
 *     xmlAttrPtr attr = (xmlAttrPtr)genericPtr;
 *     // Do something with attr
 * }
**/
struct _xmlKind {
	void * ignore;
	xmlElementType type;
};
typedef struct _xmlKind *xmlKindPtr;

/**
 * Most xml types all start with this standard structure. In fact, all do except the xmlNsPtr.
 * We will occasionally take advantage of this to simplify code when the code wouldn't vary from type to type.
 * Obviously, you cannnot cast a xmlNsPtr to a xmlStdPtr.
**/
struct _xmlStd {
	void * _private;
	xmlElementType type;
	const xmlChar *name;
	struct _xmlNode *children;
	struct _xmlNode *last;
	struct _xmlNode *parent;
	struct _xmlStd *next;
	struct _xmlStd *prev;
	struct _xmlDoc *doc;
};
typedef struct _xmlStd *xmlStdPtr;

@interface DDXMLNode : NSObject <NSCopying>
{
	// Every DDXML object is simply a wrapper around an underlying libxml node
	xmlKindPtr genericPtr;
	
	// The xmlNsPtr type doesn't store a reference to it's parent
	// This is here to fix that problem, and make this class more compatible with the NSXML classes
	xmlNodePtr nsParentPtr;
}

//- (id)initWithKind:(DDXMLNodeKind)kind;

//- (id)initWithKind:(DDXMLNodeKind)kind options:(NSUInteger)options;

//+ (id)document;

//+ (id)documentWithRootElement:(DDXMLElement *)element;

+ (id)elementWithName:(NSString *)name;

+ (id)elementWithName:(NSString *)name URI:(NSString *)URI;

+ (id)elementWithName:(NSString *)name stringValue:(NSString *)string;

+ (id)elementWithName:(NSString *)name children:(NSArray *)children attributes:(NSArray *)attributes;

+ (id)attributeWithName:(NSString *)name stringValue:(NSString *)stringValue;

+ (id)attributeWithName:(NSString *)name URI:(NSString *)URI stringValue:(NSString *)stringValue;

+ (id)namespaceWithName:(NSString *)name stringValue:(NSString *)stringValue;

+ (id)processingInstructionWithName:(NSString *)name stringValue:(NSString *)stringValue;

+ (id)commentWithStringValue:(NSString *)stringValue;

+ (id)textWithStringValue:(NSString *)stringValue;

//+ (id)DTDNodeWithXMLString:(NSString *)string;

#pragma mark --- Properties ---

- (DDXMLNodeKind)kind;

- (void)setName:(NSString *)name;
- (NSString *)name;

//- (void)setObjectValue:(id)value;
//- (id)objectValue;

- (void)setStringValue:(NSString *)string;
//- (void)setStringValue:(NSString *)string resolvingEntities:(BOOL)resolve;
- (NSString *)stringValue;

#pragma mark --- Tree Navigation ---

- (NSUInteger)index;

- (NSUInteger)level;

- (DDXMLDocument *)rootDocument;

- (DDXMLNode *)parent;
- (NSUInteger)childCount;
- (NSArray *)children;
- (DDXMLNode *)childAtIndex:(NSUInteger)index;

- (DDXMLNode *)previousSibling;
- (DDXMLNode *)nextSibling;

- (DDXMLNode *)previousNode;
- (DDXMLNode *)nextNode;

- (void)detach;

- (NSString *)XPath;

#pragma mark --- QNames ---

- (NSString *)localName;
- (NSString *)prefix;

- (void)setURI:(NSString *)URI;
- (NSString *)URI;

+ (NSString *)localNameForName:(NSString *)name;
+ (NSString *)prefixForName:(NSString *)name;
//+ (DDXMLNode *)predefinedNamespaceForPrefix:(NSString *)name;

#pragma mark --- Output ---

- (NSString *)description;
- (NSString *)XMLString;
- (NSString *)XMLStringWithOptions:(NSUInteger)options;
//- (NSString *)canonicalXMLStringPreservingComments:(BOOL)comments;

#pragma mark --- XPath/XQuery ---

- (NSArray *)nodesForXPath:(NSString *)xpath error:(NSError **)error;
//- (NSArray *)objectsForXQuery:(NSString *)xquery constants:(NSDictionary *)constants error:(NSError **)error;
//- (NSArray *)objectsForXQuery:(NSString *)xquery error:(NSError **)error;

@end
