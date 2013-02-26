//
//  CKElement.h
//  CKDocument
//
//  Created by Conrad Kreyling on 1/12/12.
//  Copyright (c) 2012 Conrad Kreyling. All rights reserved.
//

@class CKDocument;

@interface CKElement : NSObject

@property (nonatomic, readonly) CKDocument* document;
@property (nonatomic, readonly) CKElement* parent;
@property (nonatomic, readonly) NSArray* children;

@property (nonatomic, readonly) NSString* tagName;
@property (nonatomic, readonly) NSString* content;

@property (nonatomic, readonly) NSDictionary* attributes;

- (NSString*)valueForAttributeNamed:(NSString *)attributeName;

@end
