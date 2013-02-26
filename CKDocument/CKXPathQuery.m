//
//  CKXPathQuery.m
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
