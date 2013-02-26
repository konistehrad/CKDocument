//
//  CKDocument.m
//  CKDocument
//
//  Created by Conrad Kreyling on 1/12/12.
//  Copyright (c) 2012 Conrad Kreyling. All rights reserved.
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


#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

#import "CKDocument.h"
#import "CKDocument_Private.h"

#import "CKElement.h"
#import "CKElement_Private.h"

#import "CKXPathQuery.h"
#import "CKXPathQuery_Private.h"

@interface ConXPathQueryResult : NSObject
{
    NSArray* _result;
    xmlXPathObjectPtr _objectPointer;
}

+ (id)resultWithXPathObj:(xmlXPathObjectPtr)objectPointer withResult:(NSArray*)result;
- (id)initWithXPathObj:(xmlXPathObjectPtr)objectPointer withResult:(NSArray*)result;

@property (nonatomic, strong, readwrite) NSArray* result;
@property (nonatomic, assign, readwrite) xmlXPathObjectPtr objectPointer;
@end

@implementation ConXPathQueryResult
@synthesize result = _result;
@synthesize objectPointer = _objectPointer;
+ (id)resultWithXPathObj:(xmlXPathObjectPtr)objectPointer withResult:(NSArray *)result
{
    return [[ConXPathQueryResult alloc] initWithXPathObj:objectPointer withResult:result];
}
- (id)initWithXPathObj:(xmlXPathObjectPtr)objectPointer withResult:(NSArray*)result
{
    if( self = [super init] )
    {
        _objectPointer = objectPointer;
        _result = result;
    }
    return self;
}
- (void)dealloc
{
    if( _objectPointer != NULL )
        xmlXPathFreeObject(_objectPointer);
}
@end

@interface CKDocument ()
{
@private
    NSData* _data;
    BOOL _isXml;
    xmlDocPtr _doc;
    xmlXPathContextPtr _xpathContext;
    NSMutableDictionary* _cache;    
    NSMutableArray* _knownElements;
}

- (id)initWithXmlData:(NSData*)data;
- (id)initWithHtmlData:(NSData*)data;

- (id)initWithData:(NSData*)data isXML:(BOOL)isXml;
@end

@implementation CKDocument

+ (id)documentWithXmlData:(NSData *)data
{
    return [[CKDocument alloc] initWithXmlData:data];
}

+ (id)documentWithHtmlData:(NSData *)data
{
    return [[CKDocument alloc] initWithHtmlData:data];
}

- (id)initWithXmlData:(NSData *)data
{
    return [self initWithData:data isXML:YES];
}

- (id)initWithHtmlData:(NSData *)data
{
    return [self initWithData:data isXML:NO];
}

- (id)initWithData:(NSData*)data isXML:(BOOL)isXml
{
    if( self = [super init] )
    {
        _doc = NULL;
        _xpathContext = NULL;
        _data = data;
        _isXml = isXml;
        
        if( _isXml )
        {
            _doc = xmlReadMemory(data.bytes, data.length, "", NULL, XML_PARSE_RECOVER);
        }
        else
        {
            _doc = htmlReadMemory(data.bytes, data.length, "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
        }
        
        if( _doc != NULL )
        {
            _xpathContext = xmlXPathNewContext(_doc);
            if( _xpathContext != NULL )
            {
                _cache = [NSMutableDictionary dictionary];
                _knownElements = [NSMutableArray array];
            }
            else
            {
                NSLog(@"Error: cannot create XPATH context!");
                xmlFreeDoc(_doc);
                _doc = NULL;
                self = nil; // XXX: HERE WE GO AGAIN
            }
        }
        else
        {
            
            NSLog(@"ERROR: XML Parsing failed or doc failed to instantiate");
            self = nil; // XXX: is this even legal??
        }
    }
    return self;
}

- (void)dealloc
{
    if( _doc != NULL )
        xmlFreeDoc(_doc);
    
    if( _xpathContext != NULL )
        xmlXPathFreeContext(_xpathContext);
}

- (ConXPathQueryResult*)cachedResultForQuery:(NSString*)query
{
    return [_cache objectForKey:query];
}

- (void)cacheResult:(ConXPathQueryResult*)result forQuery:(NSString*)query
{
    [_cache setObject:result forKey:query];
}

- (NSArray*)processObject:(xmlXPathObjectPtr)objectPointer forQueryString:(NSString*)queryString
{
    NSArray* result = nil;
    xmlXPathObjectPtr xpathObj = objectPointer;
    xmlNodeSetPtr nodes = xpathObj->nodesetval;
    if( nodes )
    {
        NSMutableArray* resultElements = [NSMutableArray arrayWithCapacity:objectPointer->nodesetval->nodeNr];
        for (NSInteger i = 0; i < nodes->nodeNr; i++)
        {
            CKElement* element = [self elementForRawNode:nodes->nodeTab[i]];
            if (element != nil)
            {
                [resultElements addObject:element];
            }
        }
        result = resultElements;
    }
    else
    {
        result = [NSArray array];
    }
    [self cacheResult:[ConXPathQueryResult resultWithXPathObj:xpathObj withResult:result] forQuery:queryString];
    return result;
}

- (CKElement*)elementForRawNode:(xmlNodePtr)rawNode
{
    // Don't do anything if we were given a null target node
    if( !rawNode )
    {
        return nil;
    }
    
    for( CKElement* element in _knownElements )
    {
        // XXX: early out if found
        if( element.rawNode == rawNode )
            return element;
    }
    
    CKElement* element = [CKElement elementWithNode:rawNode inDocument:self];
    [_knownElements addObject:element];
    return element;
}

- (CKElement*)elementForQuery:(CKXPathQuery *)xpathQuery
{
    NSArray* result = [self elementsForQuery:xpathQuery];
    return 
        result.count > 0 ? 
            [result objectAtIndex:0] : 
            nil;
}

- (NSArray*)elementsForQuery:(CKXPathQuery *)xpathQuery
{
    NSArray* result = nil;
    ConXPathQueryResult* cache = [self cachedResultForQuery:xpathQuery.queryString];
    if( cache != nil )
    {
        result = cache.result;
    }
    else
    {
        result = 
            [self processObject:xmlXPathCompiledEval(xpathQuery.compiledExpression, _xpathContext) 
                 forQueryString:xpathQuery.queryString];
    }
    
    return result;
}

- (CKElement*)elementForQueryString:(NSString*)queryString
{
    NSArray* result = [self elementsForQueryString:queryString];
    return 
        result.count > 0 ?
            [result objectAtIndex:0] :  
            nil;
}

- (NSArray*)elementsForQueryString:(NSString*)queryString
{
    NSArray* result = nil;
    ConXPathQueryResult* cache = [self cachedResultForQuery:queryString];
    if( cache != nil )
    {
        result = cache.result;
    }
    else
    {
        result = 
            [self processObject:xmlXPathEvalExpression((xmlChar *)[queryString cStringUsingEncoding:NSUTF8StringEncoding], _xpathContext)
                 forQueryString:queryString];
    }
    
    return result;
}

@end


NSMutableArray* CD_CreateNonRetainingArray(NSInteger capacity) {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    return (__bridge_transfer NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}

