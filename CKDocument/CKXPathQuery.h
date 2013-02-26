//
//  CKXPathQuery.h
//  CKDocument
//
//  Created by Conrad Kreyling on 1/12/12.
//  Copyright (c) 2012 Conrad Kreyling. All rights reserved.
//

@interface CKXPathQuery : NSObject

+ (id)queryFromString:(NSString*)queryString;
- (id)initFromString:(NSString*)queryString;

@property (nonatomic, readonly) NSString* queryString;

@end
