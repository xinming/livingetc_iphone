//
//  BazaarBeta2AppDelegate.m
//  BazaarBeta2
//
//  Created by Ake K. on 13/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import "LivingEtcAppDelegate.h"
#import "CoverScreenController.h"
#import "GANTracker.h"

static const NSInteger kGANDispatchPeriodSec = 10;

@implementation LivingEtcAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    // Add the navigation controller's view to the window and display.
    CoverScreenController *coverScreenController = [[[CoverScreenController alloc] initWithNibName:nil bundle:nil] autorelease];
    //homeController.dataSource; // TO DO
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:coverScreenController] autorelease];
    self.navigationController.delegate = self;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-20442203-6"
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark Navigation controller delegate

- (void)navigationController:(UINavigationController *)_navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController.navigationItem.title isEqualToString:@"Cover"]) {
        _navigationController.navigationBarHidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
    } else {
        _navigationController.navigationBarHidden = NO;
    } 
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

