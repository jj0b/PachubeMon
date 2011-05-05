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

#import "AddFeedViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "FeedListViewController.h"
#import	"AddFeedViewController.h"
#import "JSON.h"


@implementation AddFeedViewController

@synthesize feedIDField;
@synthesize feedID;
@synthesize responseData;
@synthesize loadingIndicator;

#pragma mark -
#pragma mark View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[feedIDField becomeFirstResponder];
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.feedIDField = nil;
	self.loadingIndicator = nil;
}

#pragma mark -
#pragma mark Button Methods


- (IBAction)doneAddingFeedButtonPressed:(id)sender {
	[self.loadingIndicator startAnimating];
	if (![self.feedIDField.text isEqual:@""]) {
		self.feedID = self.feedIDField.text;
		NSString *url = [NSString stringWithFormat:@"http://www.pachube.com/feeds/%@.json",self.feedID];
	
		responseData = [[NSMutableData data] retain];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
		[[NSURLConnection alloc] initWithRequest:request delegate:self];
	} else {
		// release AddFeedView and load FeedListView
		AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate.rootViewController.addFeedViewController.view removeFromSuperview];
		[delegate.rootViewController.view insertSubview:delegate.rootViewController.feedListViewController.view atIndex:0];
		[delegate.rootViewController.feedListViewController viewWillAppear:YES];
	}
}


- (IBAction)cancelButtonPressed:(id)sender {
	// release AddFeedView and load FeedListView
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.rootViewController.addFeedViewController.view removeFromSuperview];
	[delegate.rootViewController.view insertSubview:delegate.rootViewController.feedListViewController.view atIndex:0];
	[delegate.rootViewController.feedListViewController viewWillAppear:YES];
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
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed" message:@"Please check your feedID and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[self.loadingIndicator stopAnimating];
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.rootViewController.addFeedViewController.view removeFromSuperview];
	[delegate.rootViewController.view insertSubview:delegate.rootViewController.feedListViewController.view atIndex:0];
	[delegate.rootViewController.feedListViewController viewWillAppear:YES];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
	
	if ([responseString isEqualToString:@"\"Unable to find specified resource.\""]) {
		NSLog(@"Unable to find specified resource.\n");
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid feedID" message:@"Please check your feedID and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self.loadingIndicator stopAnimating];
		
		AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate.rootViewController.addFeedViewController.view removeFromSuperview];
		[delegate.rootViewController.view insertSubview:delegate.rootViewController.addFeedViewController.view atIndex:0];
		[delegate.rootViewController.addFeedViewController viewWillAppear:YES];
	} else {
	
		NSDictionary *feedInfoDictionary = [responseString JSONValue];
		NSString *feedName = [feedInfoDictionary valueForKey:@"title"];
		
		// store new feedName and feedID in feedlist.plist
		NSString *filePath = [self pathToFile:kFeedList];
	
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
			[dictionary setValue:feedID forKey:feedName];
			[dictionary writeToFile:filePath atomically:YES];
			[dictionary release];
		} else {
			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
			[dictionary setValue:feedID forKey:feedName];
			[dictionary writeToFile:filePath atomically:YES];
			[dictionary release];
		}
		
		NSString *feedLatitude = [feedInfoDictionary valueForKey:@"lat"];
		NSString *feedLongitude = [feedInfoDictionary valueForKey:@"lng"];
		
		// store new feed location in feedlocations.plist
		filePath = [self pathToFile:kFeedLocations];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
			[dictionary setValue:feedLatitude forKey:[NSString stringWithFormat:@"%@_lat",feedID]];
			[dictionary setValue:feedLongitude forKey:[NSString stringWithFormat:@"%@_long",feedID]];
			[dictionary writeToFile:filePath atomically:YES];
			[dictionary release];
		} else {
			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
			[dictionary setValue:feedLatitude forKey:[NSString stringWithFormat:@"%@_lat",feedID]];
			[dictionary setValue:feedLongitude forKey:[NSString stringWithFormat:@"%@_long",feedID]];
			[dictionary writeToFile:filePath atomically:YES];
			[dictionary release];
		}
		
		[self.loadingIndicator stopAnimating];
	
		// release AddFeedView and load FeedListView
		AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate.rootViewController.addFeedViewController.view removeFromSuperview];
		[delegate.rootViewController.view insertSubview:delegate.rootViewController.feedListViewController.view atIndex:0];
		[delegate.rootViewController.feedListViewController viewWillAppear:YES];
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
    MCRelease(feedIDField);
    MCRelease(responseData);
    MCRelease(feedID);
    MCRelease(loadingIndicator);
    [super dealloc];
}


@end
