//
//  URLCenter.h
//  BazaarBeta2
//
//  Created by Ake K. on 15/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLCenter : NSObject {

}

+ (NSURL *)URLForHomeScreen;
+ (NSURL *)URLForCoverScreen;
+ (NSURL *)URLForJSONCategory;
+ (NSURL *)URLForPath:(NSString *)path;


@end
