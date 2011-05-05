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

#import "RootViewController.h"
#import "AppDelegate.h"
#import "FeedListViewController.h"
#import "AddFeedViewController.h"
#import "ViewFeedViewController.h"


@implementation RootViewController

@synthesize feedListViewController;
@synthesize addFeedViewController;
@synthesize viewFeedViewController;


#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
	
	// create feedlist.plist if it doesn't exist:
	NSString *filePath = [self pathToFile:kFeedList];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
		[dictionary setValue:@"504" forKey:@"Pachube Office environment"];
		[dictionary writeToFile:filePath atomically:YES];
		[dictionary release];
	}
	
	// get lat and long from feedlocations.plist
	filePath = [self pathToFile:kFeedLocations];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
		[dictionary setValue:[NSString stringWithFormat:@"51.5235375648154"] forKey:@"504_lat"];
		[dictionary setValue:[NSString stringWithFormat:@"-0.0807666778564453"] forKey:@"504_long"];
		[dictionary writeToFile:filePath atomically:YES];
		[dictionary release];
	}
	
	
	
	FeedListViewController *feedListController = [[FeedListViewController alloc] initWithNibName:@"FeedListView" bundle:nil];
	self.feedListViewController = feedListController;
	[feedListController release];
	
	AddFeedViewController *addFeedController = [[AddFeedViewController alloc] initWithNibName:@"AddFeedView" bundle:nil];
	self.addFeedViewController = addFeedController;
	[addFeedController release];
	
	ViewFeedViewController *viewFeedController = [[ViewFeedViewController alloc] initWithNibName:@"ViewFeedView" bundle:nil];
	self.viewFeedViewController = viewFeedController;
	[viewFeedController release];
	
	[self.view insertSubview:feedListViewController.view atIndex:0];
	[feedListViewController viewWillAppear:YES];
	
    [super viewDidLoad];
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
    [super dealloc];
}


@end
