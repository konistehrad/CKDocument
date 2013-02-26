//
//  CKElement_Private.h
//  CKDocument
//
//  Created by Conrad Kreyling on 1/12/12.
//  Copyright (c) 2012 Conrad Kreyling. All rights reserved.
//

#import "CKElement.h"
#import <libxml/tree.h>

@interface CKElement (Private)

+ (id)elementWithNode:(xmlNodePtr)xmlNode inDocument:(CKDocument*)doc;
- (id)initWithNode:(xmlNodePtr)xmlNode inDocument:(CKDocument*)doc;

@property (nonatomic, readonly) xmlNodePtr rawNode;

@end