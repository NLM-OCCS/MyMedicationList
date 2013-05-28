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
#import "DDXMLNode.h"
#import "DDXMLElement.h"
#import "DDXMLDocument.h"

// We can't rely solely on NSAssert, because many developers disable them for release builds.
// Our API contract requires us to keep these assertions intact.
#define DDCheck(condition, desc, ...)  { if(!(condition)) { [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd object:self file:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__ description:(desc), ##__VA_ARGS__]; } }

#define DDLastErrorKey @"DDXML:LastError"


@interface DDXMLNode (PrivateAPI)

+ (id)nodeWithPrimitive:(xmlKindPtr)nodePtr;
- (id)initWithCheckedPrimitive:(xmlKindPtr)nodePtr;
- (id)initWithUncheckedPrimitive:(xmlKindPtr)nodePtr;

+ (id)nodeWithPrimitive:(xmlKindPtr)nodePtr nsParent:(xmlNodePtr)parentPtr;
- (id)initWithCheckedPrimitive:(xmlKindPtr)nodePtr nsParent:(xmlNodePtr)parentPtr;
- (id)initWithUncheckedPrimitive:(xmlKindPtr)nodePtr nsParent:(xmlNodePtr)parentPtr;

+ (BOOL)isXmlAttrPtr:(xmlKindPtr)kindPtr;
- (BOOL)isXmlAttrPtr;

+ (BOOL)isXmlNodePtr:(xmlKindPtr)kindPtr;
- (BOOL)isXmlNodePtr;

+ (BOOL)isXmlDocPtr:(xmlKindPtr)kindPtr;
- (BOOL)isXmlDocPtr;

+ (BOOL)isXmlDtdPtr:(xmlKindPtr)kindPtr;
- (BOOL)isXmlDtdPtr;

+ (BOOL)isXmlNsPtr:(xmlKindPtr)kindPtr;
- (BOOL)isXmlNsPtr;

- (BOOL)hasParent;

+ (void)recursiveStripDocPointersFromNode:(xmlNodePtr)node;

+ (void)detachAttribute:(xmlAttrPtr)attr fromNode:(xmlNodePtr)node;
+ (void)removeAttribute:(xmlAttrPtr)attr fromNode:(xmlNodePtr)node;
+ (void)removeAllAttributesFromNode:(xmlNodePtr)node;

+ (void)detachNamespace:(xmlNsPtr)ns fromNode:(xmlNodePtr)node;
+ (void)removeNamespace:(xmlNsPtr)ns fromNode:(xmlNodePtr)node;
+ (void)removeAllNamespacesFromNode:(xmlNodePtr)node;

+ (void)detachChild:(xmlNodePtr)child fromNode:(xmlNodePtr)node;
+ (void)removeChild:(xmlNodePtr)child fromNode:(xmlNodePtr)node;
+ (void)removeAllChildrenFromNode:(xmlNodePtr)node;

+ (void)removeAllChildrenFromDoc:(xmlDocPtr)doc;

- (void)nodeRetain;
- (void)nodeRelease;

+ (NSError *)lastError;

@end

@interface DDXMLElement (PrivateAPI)

+ (id)nodeWithPrimitive:(xmlKindPtr)nodePtr;
- (id)initWithCheckedPrimitive:(xmlKindPtr)nodePtr;
- (id)initWithUncheckedPrimitive:(xmlKindPtr)nodePtr;

- (NSArray *)elementsWithName:(NSString *)name uri:(NSString *)URI;

+ (DDXMLNode *)resolveNamespaceForPrefix:(NSString *)prefix atNode:(xmlNodePtr)nodePtr;
+ (NSString *)resolvePrefixForURI:(NSString *)uri atNode:(xmlNodePtr)nodePtr;

@end

@interface DDXMLDocument (PrivateAPI)

+ (id)nodeWithPrimitive:(xmlKindPtr)nodePtr;
- (id)initWithCheckedPrimitive:(xmlKindPtr)nodePtr;
- (id)initWithUncheckedPrimitive:(xmlKindPtr)nodePtr;

@end