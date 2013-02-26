//
//  CKDocument_Private.h
//  CKDocument
//
//  Created by Conrad Kreyling on 1/12/12.
//  Copyright (c) 2012 Conrad Kreyling. All rights reserved.
//

#import "CKDocument.h"
#import <libxml/tree.h>

@class CKElement;

@interface CKDocument (Private)

- (CKElement*)elementForRawNode:(xmlNodePtr)rawNode;

@end

NSMutableArray* CD_CreateNonRetainingArray(NSInteger capacity);