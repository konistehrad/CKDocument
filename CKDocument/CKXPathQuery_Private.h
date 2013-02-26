//
//  CKXPathQuery_Private.h
//  CKDocument
//
//  Created by Conrad Kreyling on 1/12/12.
//  Copyright (c) 2012 Conrad Kreyling. All rights reserved.
//

#import "CKXPathQuery.h"
#import <libxml/xpath.h>

@interface CKXPathQuery (Private)

@property (nonatomic, assign, readonly) xmlXPathCompExprPtr compiledExpression;

@end