//
//  HomeViewController.h
//  BazaarBeta2
//
//  Created by Ake K. on 13/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "TKProgressBarView.h"

@class CoverScreenController;

@interface CoverScreenController : UIViewController <UIWebViewDelegate, UINavigationControllerDelegate> {
    UIWebView *coverScreen;
    HomeViewController *homeViewController;
    TKProgressBarView *progressBarView;
}

@property (nonatomic, retain) UIWebView *coverScreen;
@property (nonatomic, retain) HomeViewController * homeViewController;
@property (nonatomic, retain) TKProgressBarView *progressBarView;

@end
