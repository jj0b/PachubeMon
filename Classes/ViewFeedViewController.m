/*
 Copyright (c) 2009, Jason Job, Bit Catapult
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the Jason Job or Bit Catapult nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL Jason Job or Bit Catapult BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ViewFeedViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import	"FeedListViewController.h"
#import "FeedAnnotation.h"
#import "JSON.h"
#import "DatastreamViewController.h"


@implementation ViewFeedViewController

@synthesize datastreamWebViewArray;
@synthesize datastreamTable;
@synthesize feedInfoDictionary;
@synthesize responseData;
@synthesize mapView;
@synthesize feedID;
@synthesize feedName;
@synthesize feedViewBar;
@synthesize loadingIndicator;
@synthesize loadingLabel;

#pragma mark -
#pragma mark View Lifecycle


- (void)viewWillAppear:(Boolean)animated {		
	[super viewWillAppear:animated];	
	
	[datastreamTable reloadData];
	
	self.datastreamWebViewArray = [NSMutableArray arrayWithCapacity:1];
	
	self.loadingLabel.text = @"Loading Feed...";
	[self.loadingIndicator startAnimating];
	
	// get active feedID from activefeedid.plist
	NSString *filePath = [self pathToFile:kActiveFeedName];
	
	NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
	self.feedName = [dictionary objectForKey:@"ActiveFeedName"];
	[dictionary release];
	
	feedViewBar.topItem.title = self.feedName;
	
	// get active feedID from activefeedid.plist
	filePath = [self pathToFile:kActiveFeedID];
	
	dictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
	self.feedID = [dictionary objectForKey:@"ActiveFeedID"];
	[dictionary release];
	
	// get lat and long from feedlocations.plist
	filePath = [self pathToFile:kFeedLocations];
	
	dictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
	NSNumber *feedLatitude = [dictionary objectForKey:[NSString stringWithFormat:@"%@_lat",feedID]];
	NSNumber *feedLongitude = [dictionary objectForKey:[NSString stringWithFormat:@"%@_long",feedID]];
	
	NSString *url = [NSString stringWithFormat:@"http://www.pachube.com/feeds/%@.json",feedID];
	self.responseData = [[NSMutableData data] retain];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	
	//NSString *url = [NSString stringWithFormat:@"http://apps.pachube.com/i/%@",self.feedID];
	
	CLLocationCoordinate2D center;
	center.latitude = [feedLatitude doubleValue];
	center.longitude = [feedLongitude doubleValue];
	
	[dictionary release];
	
	MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, 1000, 1000);
	MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
	[mapView setRegion:adjustedRegion animated:YES];
	mapView.scrollEnabled = YES;
	mapView.zoomEnabled = YES;
	
	NSMutableArray* annotations = [[NSMutableArray alloc] init];
	
	FeedAnnotation *feedAnnotation = [[FeedAnnotation alloc] init];
	feedAnnotation.text = [NSString stringWithFormat:@"feed #%@",feedID];
	feedAnnotation.coordinate = center;
	[annotations addObject:feedAnnotation];
	[feedAnnotation release];	
	
	[mapView addAnnotations:annotations];
	
	[annotations release];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark -
#pragma mark Connection Methods


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"%@",[NSString stringWithFormat:@"\nConnection failed: %@\n", [error description]]);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[self.loadingIndicator stopAnimating];
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.rootViewController.viewFeedViewController.view removeFromSuperview];
	[delegate.rootViewController.view insertSubview:delegate.rootViewController.feedListViewController.view atIndex:0];
	[delegate.rootViewController.feedListViewController viewWillAppear:YES];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
	
	if ([responseString isEqualToString:@"\"Unable to find specified resource.\""]) {
		NSLog(@"Unable to find specified resource.\n");
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Resource Unavailable" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self.loadingIndicator stopAnimating];
		
		AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate.rootViewController.viewFeedViewController.view removeFromSuperview];
		[delegate.rootViewController.view insertSubview:delegate.rootViewController.feedListViewController.view atIndex:0];
		[delegate.rootViewController.feedListViewController viewWillAppear:YES];
	} else {
		
		self.feedInfoDictionary = [responseString JSONValue];
		
		[self.loadingIndicator stopAnimating];
		
		[self.datastreamTable reloadData];
	}
  
  [responseString release];
}

#pragma mark -
#pragma mark Table View Data Source Methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self numberOfDatastreams];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [[[[feedInfoDictionary objectForKey:@"datastreams"] objectAtIndex:row] objectForKey:@"tags"] objectAtIndex:0];
	return cell;
}


#pragma mark -
#pragma mark Table View Delegate Methods


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	
	NSString *datastreamName = [[[[feedInfoDictionary objectForKey:@"datastreams"] objectAtIndex:row] objectForKey:@"tags"] objectAtIndex:0];
	
	DatastreamViewController *_datastreamViewController = [[DatastreamViewController alloc] init];
	
	[_datastreamViewController setFeedID:feedID];
	[_datastreamViewController setDatastreamID:[NSNumber numberWithInt:row]];
	[_datastreamViewController setDatastreamName:datastreamName];
	[self presentModalViewController:_datastreamViewController animated:NO];
	[_datastreamViewController release];
}


- (int)numberOfDatastreams {
	return [[feedInfoDictionary objectForKey:@"datastreams"] count];
}


- (void)stopLoadingIndicator {
	self.loadingLabel.text = @"";
	[self.loadingIndicator stopAnimating];
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	// turn off loading indicator after one second:
	[self performSelector:@selector(stopLoadingIndicator) withObject:nil afterDelay:1];
}


#pragma mark -
#pragma mark Buttons

- (IBAction)backToFeedListButtonPressed:(id)sender {
	
	// release AddFeedView and load FeedListView
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.rootViewController.viewFeedViewController.view removeFromSuperview];
	[delegate.rootViewController.view insertSubview:delegate.rootViewController.feedListViewController.view atIndex:0];
	[delegate.rootViewController.feedListViewController viewWillAppear:YES];
}


#pragma mark -
#pragma mark Storage Methods


- (NSString *)pathToFile:(NSString *)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}


#pragma mark -
#pragma mark Memory Management
						   
- (void)viewDidUnload {
	self.datastreamWebViewArray = nil;
	self.datastreamTable = nil;
	self.feedInfoDictionary = nil;
	self.responseData = nil;
	self.mapView = nil;
	self.feedViewBar = nil;
	self.loadingIndicator = nil;
	self.loadingLabel = nil;
}						   
							   

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    MCRelease(feedID);
    MCRelease(feedName);
    MCRelease(feedViewBar);
    MCRelease(loadingIndicator);
    MCRelease(loadingLabel);
    MCRelease(mapView);
    MCRelease(responseData);
    MCRelease(feedInfoDictionary);
    MCRelease(datastreamTable);
    MCRelease(datastreamWebViewArray);
    [super dealloc];
}


@end
