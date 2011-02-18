    //
//  HomeViewController.m
//  BazaarBeta2
//
//  Created by Ake K. on 13/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import "HomeViewController.h"
#import "ASIHTTPRequest.h"
#import "RequestCenter.h"
#import "Reachability.h"
#import "CJSONDeserializer.h"
#import "URLCenter.h"
#import "ArticleViewController.h"
#import "ContentViewController.h"


@interface HomeViewController () 

//- (void)display:(ASIHTTPRequest *)request;
- (void)loadFail:(ASIHTTPRequest *)request;
//- (void)loadHomeScreen;
//- (void)loadHomeSuccess:(ASIHTTPRequest *)request;
- (void)loadCategorySuccess:(ASIHTTPRequest *)request;
    
@end

@implementation HomeViewController

@synthesize homeScreen;
@synthesize categoryList;
@synthesize articleViewController;
@synthesize homeScreenDidShow;


#pragma mark -
#pragma mark View

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    // Set up view
    CGRect rectFrame = [UIScreen mainScreen].applicationFrame;
    UIWebView *homeSceen = [[UIWebView alloc] initWithFrame:rectFrame];
    self.homeScreen = homeSceen;
    self.view = homeSceen;
    [homeSceen release];
    self.homeScreen.delegate = self;

    self.homeScreenDidShow = NO;
    NSURL *load = [NSURL URLWithString:[[[NSBundle mainBundle] pathForResource:@"menu_screen" ofType:@"html"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self.homeScreen loadRequest:[NSURLRequest requestWithURL:load]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [(UIScrollView *)[[self.homeScreen subviews] objectAtIndex:0] setBounces:NO];
    self.navigationItem.title = @"Home";
    UIImageView * imageTitle = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"title_bar.png"]];
    self.navigationItem.titleView = imageTitle;
    [imageTitle release];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Notification

- (void)networkConnectionChanged:(NSNotification *)notification {
}

#pragma mark -
#pragma mark UIWebView delegate stuff

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = [[request URL] relativeString];
    if([urlString hasPrefix:@"gotoArticleCategory:"]){
        if (!self.articleViewController) {
            self.articleViewController = [[[ArticleViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        }
        else{
            self.articleViewController.jsonString = nil;
            self.articleViewController.articleList = nil;
        }
        NSUInteger categoryIndex = [[urlString substringFromIndex:20] intValue];
        NSDictionary *category = [self.categoryList objectAtIndex:categoryIndex];
        self.articleViewController.navigationItem.title = [category valueForKey:@"name"];
        [[RequestCenter sharedRequest] requestWithURL:[URLCenter URLForPath:[NSString stringWithFormat:@"/mobile/article_category/%d.json", categoryIndex]] 
                                                 type:RequestTypeNormal 
                                             callback:self 
                                      successSelector:@selector(loadCategorySuccess:) 
                                         failSelector:@selector(loadFail:)];
        [self.navigationController pushViewController:self.articleViewController animated:YES];
        [self.articleViewController.activityView startAnimating];
        
        return NO;
    }//else if([urlString hasPrefix:@"http://"]){
//        ContentViewController *contentViewController = [[[ContentViewController alloc] initWithCustomURL:urlString] autorelease];
//        [self.navigationController pushViewController:contentViewController animated:YES];
//        return NO;
//    }

    return YES;
}

#pragma mark -
#pragma mark Callback

//- (void)display:(ASIHTTPRequest *)request {
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    NSURL *url = [NSURL URLWithString:[[request downloadDestinationPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [self.homeScreen loadRequest:[NSURLRequest requestWithURL:url]];
//    [pool drain];
//}

//- (void)loadHomeScreen {
//    [[RequestCenter sharedRequest] requestWithURL:[URLCenter URLForHomeScreen] 
//                                             type:RequestTypeWebPage 
//                                         callback:self 
//                                  successSelector:@selector(loadHomeSuccess:) 
//                                     failSelector:@selector(loadFail:)];
//}

//- (void)loadHomeSuccess:(ASIHTTPRequest *)request {
//    if ([request didUseCachedResponse] || [request responseStatusCode] == 200) {
//        [self display:request];
//        self.homeScreenDidShow = YES;
//    } else {
//        NSLog(@"Internet Connection is required");
//        [self loadFail:request];
//    }
//}
//
//
- (void)loadFail:(ASIHTTPRequest *)request {
    NSLog(@"Loading %@ Failed %d, %@", [request url], [request responseStatusCode], [request error]);
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Internet Connection Required" message:@"Please check your Internet connection." 
                                                    delegate:nil cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}


//- (void)loadCategoryListSuccess:(ASIHTTPRequest *)request {
//    if ([request didUseCachedResponse] || [request responseStatusCode] == 200) {
//        NSString *jsonString = [NSString stringWithContentsOfFile:[request downloadDestinationPath] encoding:[request responseEncoding] error:nil];
//        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
//        self.categoryList = [[CJSONDeserializer deserializer] deserializeAsArray:jsonData error:nil];
//    } else {
//        NSLog(@"Internet Connection is required");
//        [self loadFail:request];
//    }
//}

- (void)loadCategorySuccess:(ASIHTTPRequest *)request {
    if ([request didUseCachedResponse] || [request responseStatusCode] == 200) {
        NSString *jsonString = [NSString stringWithContentsOfFile:[[request downloadCache] pathToCachedResponseDataForURL:[request url]] encoding:[request responseEncoding] error:nil];
        self.articleViewController.jsonString = jsonString;
    } else {
        NSLog(@"Internet Connection is required");
        [self loadFail:request];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    self.homeScreen = nil;
    self.categoryList = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    self.homeScreen = nil; // Syntax sugar for synthesized property
    self.categoryList = nil;
    [super dealloc];
}


@end
