//
//  RequestCenter.m
//  BazaarBeta2
//
//  Created by Ake K. on 15/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import "RequestCenter.h"
#import "Reachability.h"
#import "URLCenter.h"
#import "ASIHTTPRequest.h"
#import "ASIWebPageRequest.h"
#import "ASIDownloadCache.h"
#import "ASINetworkQueue.h"
#import "TapkuLibrary.h"

@implementation RequestCenter

static RequestCenter *sharedRequest = nil;
static ASINetworkQueue *queue = nil;
static Reachability *hostReachable = nil;
//static Reachability *networkReachable = nil;

+ (id)sharedRequest {
    if (!sharedRequest) {
        sharedRequest = [[[self class] alloc] init];
        hostReachable = [[self class] sharedReachability];
        [[NSNotificationCenter defaultCenter] addObserver:sharedRequest 
                                                 selector:@selector(cancelAllDownload:) 
                                                     name:@"loadFail" 
                                                   object:nil];
    }
    return sharedRequest;
}

+ (id)sharedReachability {
    if (!hostReachable) {
        // TESTING MODIFICATION
        hostReachable = [[Reachability reachabilityWithHostName:@"wallpaperth.mobi"] retain];
        //        networkReachable = [[Reachability reachabilityForInternetConnection] retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:sharedRequest 
                                                 selector:@selector(checkNetworkStatus:) 
                                                     name:kReachabilityChangedNotification 
                                                   object:nil];
        [hostReachable startNotifier];
    }
    return hostReachable;
}

- (id)requestWithURL:(NSURL *)url type:(RequestType)type callback:(id)callback successSelector:(SEL)success failSelector:(SEL)fail userInfo:(NSDictionary *)info {
    
    
    if (!queue) {
        queue = [[ASINetworkQueue alloc] init];
    }
    if (!hostReachable) {
        hostReachable = [RequestCenter sharedReachability];
    }
    
    ASIHTTPRequest *request = nil;
    
    
    switch (type) {
        case RequestTypeJSONData:
        case RequestTypeNormal:
            [ASIHTTPRequest setShouldThrottleBandwidthForWWAN:YES];
            [ASIHTTPRequest throttleBandwidthForWWANUsingLimit:20000];
            request = [ASIHTTPRequest requestWithURL:url];
            break;
        case RequestTypeCoverPage:
            [ASIHTTPRequest setShouldThrottleBandwidthForWWAN:YES];
            [ASIHTTPRequest throttleBandwidthForWWANUsingLimit:20000];
        case RequestTypeWebPage:
            [ASIHTTPRequest setShouldThrottleBandwidthForWWAN:NO];
            request = [ASIHTTPRequest requestWithURL:url];
            //            UIProgressView *progressBar = [info objectForKey:@"progressBar"];
            TKProgressBarView *progressBar = [info objectForKey:@"progressBar"];
            request.showAccurateProgress = YES;
            [request setDownloadProgressDelegate:progressBar];
            request.showAccurateProgress = YES;
            [request showAccurateProgress];
            
            
            break;
        default:
            request.timeOutSeconds = 120.0;
            return request; // RequestType Error, may result in program crash.
    }
    
    [request setNumberOfTimesToRetryOnTimeout:5];
    [request setDelegate:callback];
    [request setDidFinishSelector:success];
    [request setDidFailSelector:fail];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
//    [request setDownloadDestinationPath:[[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:request]];
    [request setUserInfo:info];
    //    if ([networkReachable currentReachabilityStatus] != kNotReachable) {
    if ([hostReachable currentReachabilityStatus] != kNotReachable) {
        NSLog(@"Host Reachable for %@", [request url]);
        [request setSecondsToCache:60*60*24]; // 1 day
        [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy];
    } else {
        NSLog(@"Host Unreachable for %@", [request url]);
        [request setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy];
    }
    //    } else {
    //        NSLog(@"Host Unreachable");
    //        [request setCachePolicy:ASIDontLoadCachePolicy];
    //    }
    if(type == RequestTypeWebPage){
        [request startAsynchronous];
    }else{
        [queue addOperation:request];
        [queue go];
    }
    
    //    NSLog(@"%@", request);
    return request;
}

- (id)requestWithURL:(NSURL *)url type:(RequestType)type callback:(id)callback successSelector:(SEL)success failSelector:(SEL)fail {
    return [self requestWithURL:url type:type callback:callback successSelector:success failSelector:fail userInfo:nil];
}

- (void)cancelAllDownload:(NSNotification *)notification {
    [queue cancelAllOperations];
}


- (void)checkNetworkStatus:(NSNotification *)notification {
    NSLog(@"please check network status");
}


//+(void) cancelRequest{
//    [sharedRequest cancelRequest];
//}


@end
