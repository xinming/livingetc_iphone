//
//  URLCenter.m
//  BazaarBeta2
//
//  Created by Ake K. on 15/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import "URLCenter.h"
#import "RequestCenter.h"

#define HOSTNAME @"http://livingetc.mobi"
//#define HOSTNAME @"http://localhost"
#define HOMESCREENPATH @"/mobile/iphone_menu.html"
#define COVERSCREENPATH @"/mobile/iphone_cover.html"
#define CATEGORYJSONPATH @"/mobile/article_categories.json"

#define URLPATH(path) [NSString stringWithFormat:@"%@%@", HOSTNAME, path]

@implementation URLCenter



+ (NSURL *)URLForHomeScreen {
    return [NSURL URLWithString:URLPATH(HOMESCREENPATH)];
}

+ (NSURL *)URLForCoverScreen {
    return [NSURL URLWithString:URLPATH(COVERSCREENPATH)];
}

+ (NSURL *)URLForJSONCategory {
    return [NSURL URLWithString:URLPATH(CATEGORYJSONPATH)];
}

+ (NSURL *)URLForPath:(NSString *)path {
    return [NSURL URLWithString:URLPATH(path)];
}

@end
