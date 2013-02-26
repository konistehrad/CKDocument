//
//  CKXPathQuery.m
//  CKDocument
//
//  Created by Conrad Kreyling on 1/12/12.
//  Copyright (c) 2012 Conrad Kreyling. All rights reserved.
//

#import "CKXPathQuery.h"
#import "CKXPathQuery_Private.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

@interface CKXPathQuery ()
{
    NSString* _queryString;
    xmlXPathCompExprPtr _compiledExpression;
}

@end

@implementation CKXPathQuery


+ (id)queryFromString:(NSString*)queryString
{
    return [[CKXPathQuery alloc] initFromString:queryString];
}

- (id)initFromString:(NSString*)queryString
{
    _compiledExpression = NULL;
    
    if( self = [super init] )
    {
        _compiledExpression = xmlXPathCompile((xmlChar*)[queryString cStringUsingEncoding:NSUTF8StringEncoding]);
        if(_compiledExpression != NULL )
        {
            _queryString = queryString;
        }
        else
        {
            self = nil; // XXX: VALID??
        }
    }
    return self;
}

- (NSString*)queryString
{
    return _queryString;
}

- (xmlXPathCompExprPtr)compiledExpression
{
    return _compiledExpression;
}

- (void)dealloc
{
    if(_compiledExpression != NULL)
        xmlXPathFreeCompExpr(_compiledExpression);
}

@end
