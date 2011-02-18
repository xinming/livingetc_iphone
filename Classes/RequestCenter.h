//
//  RequestCenter.h
//  BazaarBeta2
//
//  Created by Ake K. on 15/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _RequestType {
    RequestTypeNormal,
    RequestTypeWebPage,
    RequestTypeJSONData,
    RequestTypeCoverPage
} RequestType;

@interface RequestCenter : NSObject {
    
}

+ (id)sharedRequest;
+ (id)sharedReachability;
- (id)requestWithURL:(NSURL *)url type:(RequestType)type callback:(id)callback successSelector:(SEL)success failSelector:(SEL)fail userInfo:(NSDictionary *)info;
- (id)requestWithURL:(NSURL *)url type:(RequestType)type callback:(id)callback successSelector:(SEL)success failSelector:(SEL)fail;
- (void)cancelAllDownload:(NSNotification *)notification;
//+(void) cancelRequest;
@end
