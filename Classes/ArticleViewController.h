//
//  ArticleViewController.h
//  BazaarBeta2
//
//  Created by Ake K. on 17/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
@class ContentViewController;

//@protocol ContentViewControllerDelegate <NSObject>
//@required
//- (void) contentViewFinishedLoading
//
//@end

@interface ArticleViewController : UITableViewController {
    NSString *jsonString;
    NSArray *articleList;
    int articleCategory;
    UIActivityIndicatorView *activityView;
    HomeViewController *homeViewController;
}

@property (nonatomic, retain) NSString *jsonString;
@property (nonatomic, retain) NSArray *articleList;
@property (nonatomic, assign) int articleCategory;
@property (nonatomic, assign) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) HomeViewController *homeViewController;
@end
