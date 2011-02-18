//
//  HomeViewController.h
//  BazaarBeta2
//
//  Created by Ake K. on 13/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ArticleViewController;

@interface HomeViewController : UIViewController <UIWebViewDelegate, UINavigationControllerDelegate> {
    UIWebView *homeScreen;
    NSArray *categoryList;
    ArticleViewController *articleViewController;
    BOOL homeScreenDidShow;
//    NSArray *jsonStringsArray;
}

@property (nonatomic, retain) UIWebView *homeScreen;
@property (nonatomic, retain) NSArray *categoryList;
@property (nonatomic, retain) ArticleViewController *articleViewController;
@property (nonatomic, assign) BOOL homeScreenDidShow;
//@property (nonatomic, assign) NSArray *jsonStringsArray;

//- (void)loadHomeScreen;

@end
