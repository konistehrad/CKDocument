//
//  CKDocument.h
//  CKDocument
//
//  Created by Conrad Kreyling on 1/12/12.
//  Copyright (c) 2012 Conrad Kreyling. All rights reserved.
//

@class CKElement;
@class CKXPathQuery;

@interface CKDocument : NSObject

+ (id)documentWithXmlData:(NSData*)data;
+ (id)documentWithHtmlData:(NSData*)data;

- (CKElement*)elementForQuery:(CKXPathQuery*)xpathQuery;
- (NSArray*)elementsForQuery:(CKXPathQuery*)xpathQuery;

- (CKElement*)elementForQueryString:(NSString*)queryString;
- (NSArray*)elementsForQueryString:(NSString*)queryString;

@end
