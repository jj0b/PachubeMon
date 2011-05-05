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

#import "FeedListViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "AddFeedViewController.h"
#import	"ViewFeedViewController.h"
#import "Reachability.h"


@implementation FeedListViewController


@synthesize feedTable;
@synthesize feedTableData;
@synthesize	feedName;
@synthesize feedID;
@synthesize feedListBar;
@synthesize feeds;
@synthesize sortedFeedNames;
@synthesize feedToEdit;

#pragma mark -
#pragma mark View Lifecyle


- (void)viewWillAppear:(BOOL)animated {
	[[Reachability sharedReachability] setHostName:@"www.apple.com"];
	
	NetworkStatus internetStatus = [[Reachability sharedReachability] remoteHostStatus];
	
	if ((internetStatus != ReachableViaWiFiNetwork) && (internetStatus != ReachableViaCarrierDataNetwork))
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"You require an internet connection via WiFi or cellular network to load feeds." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[super viewWillAppear:animated];
	
	deleteMode = NO;
	
	// retreive the list of feeds and display in a table view
	NSString *filePath = [self pathToFile:kFeedList];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
		self.feeds = dictionary;
		[dictionary release];
		
		NSArray *feedNames = [self.feeds allKeys];
		
		self.sortedFeedNames = [feedNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:sortedFeedNames];
		self.feedTableData = mutableArray;

		[mutableArray release];
	}
	
	[self.feedTable reloadData];
	self.feedTable.backgroundColor = [UIColor clearColor];
	[self.feedTable setEditing:NO animated:YES];
}


- (void)viewDidUnload {
	self.feedTable = nil;
	self.feedListBar = nil;
}


#pragma mark -
#pragma mark Button Methods

- (IBAction)addFeedButtonPressed:(id)sender {
	// release FeedListView and load AddFeedView
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.rootViewController.feedListViewController.view removeFromSuperview];
	[delegate.rootViewController.view insertSubview:delegate.rootViewController.addFeedViewController.view atIndex:0];
	[delegate.rootViewController.addFeedViewController viewWillAppear:YES];
}


- (IBAction)removeFeedButtonPressed:(id)sender {
	if (deleteMode == NO) {
		self.feedListBar.topItem.title = @"Delete Feeds";
		[self.feedTable setEditing:YES animated:YES];
		deleteMode = YES;
	} else {
		self.feedListBar.topItem.title = @"PachubeMon";
		[self.feedTable setEditing:NO animated:YES];
		deleteMode = NO;
	}
}


#pragma mark -
#pragma mark Table View Data Source Methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.feedTableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	static NSString *feedTableIdentifier = @"feedTableIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:feedTableIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:feedTableIdentifier] autorelease];
	}
	
	cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
	
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [self.feedTableData objectAtIndex:row];
	return cell;
}


#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	
	self.feedName = [self.feedTableData objectAtIndex:row];
	
	// store feedName to activefeedname.plist
	NSString *filePath = [self pathToFile:kActiveFeedName];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
		[dictionary setValue:self.feedName forKey:@"ActiveFeedName"];
		[dictionary writeToFile:filePath atomically:YES];
		[dictionary release];
	} else {
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
		[dictionary setValue:self.feedName forKey:@"ActiveFeedName"];
		[dictionary writeToFile:filePath atomically:YES];
		[dictionary release];
	}
	
	// get feedID for feedName from feedlist.plist:
	filePath = [self pathToFile:kFeedList];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
		self.feedID = [dictionary valueForKey:self.feedName];
		[dictionary release];
	}
	
	// store feedID to activefeedid.plist:
	filePath = [self pathToFile:kActiveFeedID];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
		[dictionary setValue:self.feedID forKey:@"ActiveFeedID"];
		[dictionary writeToFile:filePath atomically:YES];
		[dictionary release];
	} else {
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
		[dictionary setValue:self.feedID forKey:@"ActiveFeedID"];
		[dictionary writeToFile:filePath atomically:YES];
		[dictionary release];
	}
	
	// release FeedListView and load ViewFeedView:
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.rootViewController.feedListViewController.view removeFromSuperview];
	[delegate.rootViewController.view insertSubview:delegate.rootViewController.viewFeedViewController.view atIndex:0];
	[delegate.rootViewController.viewFeedViewController viewWillAppear:YES];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath {	
	NSUInteger row = [indexPath row];
	
	self.feedToEdit = [self.sortedFeedNames objectAtIndex:row];
	
	for (int i = 0; i < self.feedTableData.count; i++) {
		if ([[self.feedTableData objectAtIndex:i] isEqualToString:self.feedToEdit]) {
			[self.feedTableData removeObjectAtIndex:i];
		}
	}
		
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

	// remove feed from feedlist.plist
	NSString *filePath = [self pathToFile:kFeedList];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
		[dictionary removeObjectForKey:self.feedToEdit];
		[dictionary writeToFile:filePath atomically:YES];
		[dictionary release];
	}
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	MCRelease(feedTable);
    MCRelease(feedTableData);
    MCRelease(feedName);
    MCRelease(feedID);
    MCRelease(feedListBar);
    MCRelease(feeds);
    MCRelease(sortedFeedNames);
    MCRelease(feedToEdit);
    [super dealloc];
}


@end
