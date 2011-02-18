//
//  HomeViewController.m
//  BazaarBeta2
//
//  Created by Ake K. on 13/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import "CoverScreenController.h"
#import "ASIHTTPRequest.h"
#import "RequestCenter.h"
#import "Reachability.h"
#import "CJSONDeserializer.h"
#import "URLCenter.h"
#import "HomeViewController.h"
#import "ContentViewController.h"
#import "GANTracker.h"


@interface CoverScreenController () 

- (void)display:(ASIHTTPRequest *)request;
- (void)loadFail:(ASIHTTPRequest *)request;
- (void)loadCoverScreen;
@end

@implementation CoverScreenController

@synthesize coverScreen;
@synthesize homeViewController;
@synthesize progressBarView;
#pragma mark -
#pragma mark View

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    // Set up view
    CGRect rectFrame = [UIScreen mainScreen].applicationFrame;
    self.coverScreen = [[UIWebView alloc] initWithFrame:rectFrame];
    self.coverScreen = coverScreen;
    self.view = coverScreen;
    [coverScreen release];
    self.navigationItem.title = @"Cover";
    self.coverScreen.delegate = self;
    
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Default.png"]];
    self.coverScreen.opaque = NO;
    self.coverScreen.backgroundColor = background;
    [background release];
    [self.coverScreen setUserInteractionEnabled:NO];
//    
//    
//    NSURL *load = [NSURL URLWithString:[[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [self.coverScreen loadRequest:[NSURLRequest requestWithURL:load]];
    

    
    
    self.homeViewController = [[[HomeViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(networkConnectionChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    [[RequestCenter sharedReachability] startNotifier];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
//    [(UIScrollView *)[[self.coverScreen subviews] objectAtIndex:0] setBounces:NO];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Notification

- (void)networkConnectionChanged:(NSNotification *)notification {
    [self loadCoverScreen];
}

#pragma mark -
#pragma mark UIWebView delegate stuff

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = [[request URL] relativeString];
    if([urlString hasPrefix:@"goToMenu:"]){
        [self.navigationController pushViewController:self.homeViewController animated:YES];
        return NO;
    }else if([urlString hasPrefix:@"http://"]){
        ContentViewController *contentViewController = [[[ContentViewController alloc] initWithCustomURL:urlString] autorelease];
        [self.navigationController pushViewController:contentViewController animated:YES];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark Callback

- (void)display:(ASIHTTPRequest *)request {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSURL *url = [NSURL URLWithString:[[[request downloadCache] pathToCachedResponseDataForURL:[request url]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self.coverScreen loadRequest:[NSURLRequest requestWithURL:url]];
    [pool drain];
}

- (void)loadCoverScreen {
    progressBarView = [[TKProgressBarView alloc] initWithStyle:TKProgressBarViewStyleLong];
    progressBarView.center = CGPointMake(self.view.bounds.size.width/2, 286);
    [self.view addSubview:progressBarView];
    
    [[RequestCenter sharedRequest] requestWithURL:[URLCenter URLForCoverScreen] 
                                             type:RequestTypeWebPage 
                                         callback:self 
                                  successSelector:@selector(loadCoverSuccess:) 
                                     failSelector:@selector(loadFail:)
                                         userInfo:[NSDictionary dictionaryWithObject:progressBarView forKey:@"progressBar"]];
}

- (void)loadCoverSuccess:(ASIHTTPRequest *)request {
    if ([request didUseCachedResponse] || [request responseStatusCode] == 200) {
        [self display:request];
        [progressBarView removeFromSuperview];
        [self.coverScreen setUserInteractionEnabled:YES];
        
        NSError *error;
        NSLog(@"tracking page view at /home");
        if (![[GANTracker sharedTracker] trackPageview:@"/home"
                                             withError:&error]) {
            NSLog(@"error in sending analytics %@", error);
        }
//        self.coverScreenDidShow = YES;
    } else {
        NSLog(@"Internet Connection is required");
        [self loadFail:request];
    }
}


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


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    self.coverScreen = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    self.coverScreen = nil; // Syntax sugar for synthesized property
    [super dealloc];
}


@end
