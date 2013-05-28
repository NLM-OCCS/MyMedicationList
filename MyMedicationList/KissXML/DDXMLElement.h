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
#import "DDXMLNode.h"


@interface DDXMLElement : DDXMLNode
{
}

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name URI:(NSString *)URI;
- (id)initWithName:(NSString *)name stringValue:(NSString *)string;
- (id)initWithXMLString:(NSString *)string error:(NSError **)error;

#pragma mark --- Elements by name ---

- (NSArray *)elementsForName:(NSString *)name;
- (NSArray *)elementsForLocalName:(NSString *)localName URI:(NSString *)URI;

#pragma mark --- Attributes ---

- (void)addAttribute:(DDXMLNode *)attribute;
- (void)removeAttributeForName:(NSString *)name;
- (void)setAttributes:(NSArray *)attributes;
//- (void)setAttributesAsDictionary:(NSDictionary *)attributes;
- (NSArray *)attributes;
- (DDXMLNode *)attributeForName:(NSString *)name;
//- (DDXMLNode *)attributeForLocalName:(NSString *)localName URI:(NSString *)URI;

#pragma mark --- Namespaces ---

- (void)addNamespace:(DDXMLNode *)aNamespace;
- (void)removeNamespaceForPrefix:(NSString *)name;
- (void)setNamespaces:(NSArray *)namespaces;
- (NSArray *)namespaces;
- (DDXMLNode *)namespaceForPrefix:(NSString *)prefix;
- (DDXMLNode *)resolveNamespaceForName:(NSString *)name;
- (NSString *)resolvePrefixForNamespaceURI:(NSString *)namespaceURI;

#pragma mark --- Children ---

- (void)insertChild:(DDXMLNode *)child atIndex:(NSUInteger)index;
//- (void)insertChildren:(NSArray *)children atIndex:(NSUInteger)index;
- (void)removeChildAtIndex:(NSUInteger)index;
- (void)setChildren:(NSArray *)children;
- (void)addChild:(DDXMLNode *)child;
//- (void)replaceChildAtIndex:(NSUInteger)index withNode:(DDXMLNode *)node;
//- (void)normalizeAdjacentTextNodesPreservingCDATA:(BOOL)preserve;

@end
