//
//  CKElement.m
//  CKDocument
//
//  Created by Conrad Kreyling on 1/12/12.
//  Copyright (c) 2012 Conrad Kreyling. http://conradscloset.com
//
//  MIT LICENSE
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "CKElement.h"
#import "CKElement_Private.h"

#import "CKDocument.h"
#import "CKDocument_Private.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

@interface CKElement ()
{
    __unsafe_unretained CKDocument* _document;
    __unsafe_unretained CKElement* _parent;
    
    NSString* _tagName;
    NSString* _content;
    NSDictionary* _attributes;
    NSMutableArray* _children;
    xmlNodePtr _node;
}

- (void)parseContentNode:(xmlNodePtr)node;

@end

@implementation CKElement

+ (id)elementWithNode:(xmlNodePtr)xmlNode inDocument:(CKDocument*)doc
{
    return [[CKElement alloc] initWithNode:xmlNode inDocument:doc];
}

- (id)initWithNode:(xmlNodePtr)xmlNode inDocument:(CKDocument*)doc
{
    if( self = [super init] )
    {
        if( xmlNode->type == XML_ELEMENT_NODE )
        {
            _document = doc;
            _tagName = nil;
            _attributes = nil;
            _content = nil;
            _children = nil;
            _parent = nil;
            _node = xmlNode;
        }
        else
        {
            self = nil;
        }
    }
    return self;
}

- (void)dealloc
{
    
}

- (NSString*)tagName
{
    if( _tagName == nil )
    {
        if( _node->name )
        {
            _tagName = [NSString stringWithCString:(const char *)_node->name encoding:NSUTF8StringEncoding];
        }
    }
    return _tagName;
}

- (NSString*)content
{
    if( _content == nil )
    {
        xmlNodePtr childNode = _node->children;
        while (childNode)
        {
            xmlElementType nodeType = childNode->type;
            if( nodeType == XML_TEXT_NODE )
            {
                [self parseContentNode:childNode];
                break;
            }
            childNode = childNode->next;
        }
    }
    return _content;
}

- (CKElement*)parent
{
    if( _parent == nil )
    {
        _parent = [_document elementForRawNode:_node->parent];
    }
    return _parent;
}

- (NSArray*)children
{
    if( _children == nil )
    {
        _children = CD_CreateNonRetainingArray(0);
        xmlNodePtr childNode = _node->children;
        while (childNode)
        {
            xmlElementType nodeType = childNode->type;
            if( nodeType == XML_ELEMENT_NODE )
            {
                CKElement* childElement = [_document elementForRawNode:childNode];
                if (childElement != nil)
                {
                    [_children addObject:childElement];
                }
            }
            else if( nodeType == XML_TEXT_NODE )
            {
                if( _content == nil )
                {
                    [self parseContentNode:childNode];
                }
            }
            childNode = childNode->next;
        }    
        
        // Well, by this point we know!
        if( _content == nil )
        {
            _content = @"";
        }
    }
    return _children;
}

- (NSDictionary*)attributes
{
    if( _attributes == nil )
    {
        NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
        xmlAttr* rawAttr = _node->properties;
        while (rawAttr)
        {
            NSString* attrName;
            NSString* attrValue = @"";
            if( rawAttr->name )
            {
                attrName = [NSString stringWithCString:(const char *)rawAttr->name encoding:NSUTF8StringEncoding];
            }
            
            xmlNodePtr childNode = rawAttr->children;
            if( childNode && childNode->content != (xmlChar *)-1 )
            {
                attrValue = [NSString stringWithCString:(const char *)childNode->content encoding:NSUTF8StringEncoding];
            }
            [attributes setObject:attrValue forKey:attrName];
            rawAttr = rawAttr->next;
        }
        _attributes = attributes;
    }
    return _attributes;
}

- (CKDocument*)document
{
    return _document;
}

- (NSString*)valueForAttributeNamed:(NSString *)attributeName
{
    return [self.attributes objectForKey:attributeName];
}

- (xmlNodePtr)rawNode
{
    return _node;
}

- (void)parseContentNode:(xmlNodePtr)node
{
    if( node->content && node->content != (xmlChar *)-1 )
    {
        NSString* rawContent = [NSString stringWithCString:(const char *)node->content encoding:NSUTF8StringEncoding];
        _content = [rawContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else
    {
        _content = @"";
    }
}


@end
