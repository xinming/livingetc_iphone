//
//  ContentViewController.h
//  BazaarBeta2
//
//  Created by Ake K. on 17/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MyPhotoSource.h"
#import "TapkuLibrary.h"

@interface ContentViewController : UIViewController <UIWebViewDelegate> {
    NSDictionary *contentInfo;
    UIWebView *contentView;
    BOOL contentDidLoad;
    ASIHTTPRequest *asiRequest;
    NSURL *requestURL;
    NSArray *galleryInfo;
    MyPhotoSource *source;
    EGOPhotoViewController *photoController;
    UIActivityIndicatorView *activityView;
    TKProgressBarView *progressBarView;
}

@property (nonatomic, retain) NSDictionary *contentInfo;
@property (nonatomic, retain) UIWebView *contentView;
@property (nonatomic, assign) BOOL contentDidLoad;
@property (nonatomic, assign) NSURL *requestURL;
@property (nonatomic, retain) ASIHTTPRequest *asiRequest;
@property (nonatomic, retain) NSArray *galleryInfo;
@property (nonatomic, retain) MyPhotoSource *source;
@property (nonatomic, retain) EGOPhotoViewController *photoController;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) TKProgressBarView *progressBarView;

//@property (nonatomic, assign) NSString *customURL;

- (void)loadContent;
- (void)hideWebViewGradientBackground:(UIView *)theView;
- (id)initWithCustomURL: (NSString *)customURL;
- (id)initWithContentInfo:(NSDictionary *)theContentInfo;
- (void)loadContentFail:(ASIHTTPRequest *) request;
@end
