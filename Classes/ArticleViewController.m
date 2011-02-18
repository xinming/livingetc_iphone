//
//  ArticleViewController.m
//  BazaarBeta2
//
//  Created by Ake K. on 17/01/11.
//  Copyright 2011 SIIT, TU. All rights reserved.
//

#import "ArticleViewController.h"
#import "ASIHTTPRequest.h"
#import "RequestCenter.h"
#import "Reachability.h"
#import "URLCenter.h"
#import "CJSONDeserializer.h"
#import "ContentViewController.h"
#import "HomeViewController.h"
#import "ASIDownloadCache.h"

@implementation ArticleViewController

@synthesize jsonString;
@synthesize articleList;
@synthesize articleCategory;
@synthesize activityView;
@synthesize homeViewController;


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"jsonString"]) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
        self.articleList = [[CJSONDeserializer deserializer] deserializeAsArray:jsonData error:nil];
        [self.tableView reloadData];
        [self.activityView stopAnimating];
    }
}

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self addObserver:self forKeyPath:@"jsonString" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityView.center = CGPointMake(160, 176);
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.navigationItem.rightBarButtonItem = barButton;
    UIImageView * imageTitle = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"title_bar.png"]];
    self.navigationItem.titleView = imageTitle;
    [imageTitle release];
    self.homeViewController = [self.navigationController.viewControllers objectAtIndex:0];
    [barButton release];
}



- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(networkConnectionChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    //[self.tableView reloadData];
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];

}


- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"%@", self.homeViewController);
//    [self.homeViewController.homeScreen stringByEvaluatingJavaScriptFromString: @"document.getElementsByClassName('hover')[0].setAttribute('class', '');"];
    NSLog(@"remove highlighted ones");
    
    [super viewDidDisappear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (void)networkConnectionChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.articleList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    NSDictionary *article = [self.articleList objectAtIndex:indexPath.row];    
    NSString *path = [[ASIDownloadCache sharedCache] pathToCachedResponseDataForURL:[URLCenter URLForPath:[article valueForKey:@"thumbnail_src"]]];
    if(path != nil){
        [cell.imageView setImage:[UIImage imageWithContentsOfFile:path]];
    }
    else {
        NSDictionary *info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:cell,nil]
                                                         forKeys:[NSArray arrayWithObjects:@"cell",nil]];
        if([[article valueForKey:@"type"] isEqualToString:@"advertisement"]){
            cell.imageView.image = [UIImage imageNamed:@"dummy_banner.png"];
        }else {
            [cell.imageView setImage:[UIImage imageNamed:@"dummy_icon.png"]];
        }
        [[RequestCenter sharedRequest] requestWithURL:[URLCenter URLForPath:[article valueForKey:@"thumbnail_src"]] 
                                                 type:RequestTypeNormal 
                                             callback:self 
                                      successSelector:@selector(loadThumbSuccess:) 
                                         failSelector:nil 
                                             userInfo:info];
    }

    
    // left over configs for article
    if([[article valueForKey:@"type"] isEqualToString:@"article"]){
        cell.textLabel.text = [article valueForKey:@"title"];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.detailTextLabel.text = [article valueForKey:@"subtitle"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }else{
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *contentInfo = [self.articleList objectAtIndex:indexPath.row];
    ContentViewController *contentViewController;
    
    if([[contentInfo valueForKey:@"type"] isEqualToString:@"advertisement"]){
        contentViewController = [[[ContentViewController alloc] initWithCustomURL:[contentInfo valueForKey:@"html_src"]] autorelease];
    }else {
        contentViewController = [[[ContentViewController alloc] initWithContentInfo:contentInfo] autorelease];
    }
    [self.navigationController pushViewController:contentViewController animated:YES];

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.0;
}

- (void)loadThumbSuccess:(ASIHTTPRequest *)request {
    NSDictionary *info = [request userInfo];
    [[[info valueForKey:@"cell"] imageView] setImage:[UIImage imageWithContentsOfFile:[[request downloadCache] pathToCachedResponseDataForURL:[request url]]]]; 
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    self.jsonString = nil;
    self.articleList = nil;
    self.activityView = nil;
    self.homeViewController = nil;
    [super viewDidUnload];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    self.jsonString = nil;
    self.articleList = nil;
    self.homeViewController = nil;
    [super dealloc];
}


@end

