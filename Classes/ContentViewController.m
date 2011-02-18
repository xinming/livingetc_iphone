//
//  ContentViewController.m
//  BazaarBeta2
//
//  Created by Ake K. on 17/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import "ContentViewController.h"
#import "Reachability.h"
#import "RequestCenter.h"
#import "URLCenter.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

#import "EGOPhotoGlobal.h"
#import "MyPhoto.h"
#import "MyPhotoSource.h"
#import "GANTracker.h"

@implementation ContentViewController

@synthesize contentInfo;
@synthesize contentView;
@synthesize contentDidLoad;
@synthesize asiRequest;
@synthesize requestURL;
@synthesize galleryInfo;
@synthesize source;
@synthesize photoController;
@synthesize activityView;
@synthesize progressBarView;

#pragma mark -
#pragma mark View

- (id)initWithCustomURL:(NSString *)customURL{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self=[super init]) {
        self.hidesBottomBarWhenPushed = YES;
        UIImageView * imageTitle = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"title_bar.png"]];
        self.navigationItem.titleView = imageTitle;
        [imageTitle release];
        self.requestURL = [NSURL URLWithString:customURL];
    }
    return self;
}

- (id)initWithContentInfo:(NSDictionary *)theContentInfo {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
        UIImageView * imageTitle = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"title_bar.png"]];
        self.navigationItem.titleView = imageTitle;
        [imageTitle release];
        self.contentInfo = theContentInfo;
        self.galleryInfo = [self.contentInfo valueForKey:@"gallery"];
        self.requestURL = [URLCenter URLForPath:[self.contentInfo valueForKey:@"html_src"]];
    }
    return self;
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    CGRect rectFrame = [UIScreen mainScreen].applicationFrame;
    UIWebView *content = [[UIWebView alloc] initWithFrame:rectFrame];
    
    self.contentView = content;
    self.view = content;
    self.contentView.delegate = self;
    self.contentView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.contentView.multipleTouchEnabled = NO;
    self.contentView.backgroundColor = [UIColor whiteColor];
    NSURL *load = [NSURL URLWithString:[[[NSBundle mainBundle] pathForResource:@"dummy_page" ofType:@"png"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self.contentView loadRequest:[NSURLRequest requestWithURL:load]];
    [self.contentView setUserInteractionEnabled:NO];
    progressBarView = [[TKProgressBarView alloc] initWithStyle:TKProgressBarViewStyleLong];
    progressBarView.center = CGPointMake(self.view.bounds.size.width/2, 222);
    [self.view addSubview:progressBarView];
    [content release];
}

- (void) hideWebViewGradientBackground:(UIView *)theView {
	for (UIView * subview in theView.subviews)
	{
		if ([subview isKindOfClass:[UIImageView class]])
			subview.hidden = YES;
		
		[self hideWebViewGradientBackground:subview];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [self loadContent];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(networkConnectionChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    self.title = @"Back";
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)loadContent{
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityView.center = CGPointMake(160, 176);
    [self.activityView startAnimating];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.navigationItem.rightBarButtonItem = barButton;
    [barButton release];
    [self.activityView startAnimating];
    NSDictionary * info = [NSDictionary dictionaryWithObject:progressBarView forKey:@"progressBar"];
    
    self.asiRequest = [[RequestCenter sharedRequest] requestWithURL:self.requestURL
                                                               type:RequestTypeWebPage 
                                                           callback:self 
                                                    successSelector:@selector(loadContentSuccess:)
                                                       failSelector:@selector(loadContentFail:)
                                                           userInfo:info];
    
    if ([self.contentInfo objectForKey:@"gallery"] != [NSNull null]) {
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:[self.galleryInfo count]];
        for (NSDictionary *gallery in self.galleryInfo) {
            NSString *caption = [gallery valueForKey:@"caption"];
            NSString *url = [gallery valueForKey:@"gallery_src"];
            MyPhoto *photo = [[MyPhoto alloc] initWithImageURL:[URLCenter URLForPath:url]
                                                          name:caption];
            [photos addObject:photo];
            [photo release];
        }
        
        self.source = [[MyPhotoSource alloc] initWithPhotos:photos];
        self.photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:self.source];
        NSLog(@"photo gallery ready");
    }
    
    
    
    
}

#pragma mark -
#pragma mark Notification

- (void)networkConnectionChanged:(NSNotification *)notification {
    if (!self.contentDidLoad) {
        [self loadContent];
    }
}

#pragma mark -
#pragma mark Callback

- (void)loadContentSuccess:(ASIHTTPRequest *)request{
    if ([request didUseCachedResponse] || [request responseStatusCode] == 200) {
        NSURL *url = [NSURL URLWithString:[[[request downloadCache] pathToCachedResponseDataForURL:[request url]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self.contentView loadRequest:[NSURLRequest requestWithURL:url]];
        [self.contentView setUserInteractionEnabled:YES];
        self.contentDidLoad = YES;
        [self.activityView stopAnimating];
        [self.progressBarView removeFromSuperview];
        
        NSError *error;
        NSLog(@"track pageview %@", [[[request url] relativeString] stringByReplacingOccurrencesOfString:@"http://" withString:@"/"]);
        if (![[GANTracker sharedTracker] trackPageview:[[[request url] relativeString] stringByReplacingOccurrencesOfString:@"http://" withString:@"/"]
                                             withError:&error]) {
            NSLog(@"error in sending analytics %@", error);
        }
        
        
        
    } else {
        [self loadContentFail:request];
        NSLog(@"Internet Connection is required");
    }
}

- (void)loadContentFail:(ASIHTTPRequest *)request{
    [self.activityView stopAnimating];
    [self.progressBarView removeFromSuperview];
    NSLog(@"Loading %@ Failed %d, %@", [request url], [request responseStatusCode], [request error]);
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Internet Connection Required" message:@"Please check your Internet connection." 
                                                    delegate:nil cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}



#pragma mark -
#pragma mark UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] scheme] isEqualToString:@"goToGalleryItem"]) {
        NSUInteger index = [[[[[request URL] description] componentsSeparatedByString:@"goToGalleryItem:"] objectAtIndex:1] intValue];
		[self.navigationController pushViewController:self.photoController animated:YES];
        [self.photoController moveToPhotoAtIndex:index animated:YES];
        return NO; 
    }
    else if([[[request URL] scheme] isEqualToString:@"http"]){
        NSLog(@"Going to URL %@", [request URL]);
        return YES;
    }
    return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    self.contentInfo = nil;
    self.contentView.delegate = nil;
    self.contentView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    if(self.asiRequest != nil || self.asiRequest.delegate != nil){
        self.asiRequest.delegate = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.contentInfo = nil;
    self.photoController = nil;
    self.source = nil;
    self.contentView.delegate = nil;
    self.contentView = nil;
    self.activityView = nil;
    //    self.progressBarView = nil;
    [super dealloc];
}


@end
