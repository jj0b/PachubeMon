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

#import "DatastreamViewController.h"


@implementation DatastreamViewController

@synthesize datastreamID;
@synthesize feedID;
@synthesize datastreamName;
@synthesize webView;
@synthesize oneHourButton;
@synthesize oneDayButton;
@synthesize fourDaysButton;
@synthesize threeMonthsButton;
@synthesize backButton;
@synthesize loadingIndicator;
@synthesize dataStreamViewBar;

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.loadingIndicator startAnimating];
	
	dataStreamViewBar.topItem.title = datastreamName;
	
	self.datastreamName = [datastreamName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSString *url = [NSString stringWithFormat:@"http://www.pachube.com/feeds/%@/datastreams/%d/history.png?w=320&h=410&c=000066&b=1&g=1&s=3&r=3",feedID,[datastreamID intValue]];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)backButtonPressed {
	[self dismissModalViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.datastreamID = nil;
	self.feedID = nil;
	self.datastreamName = nil;
	self.webView = nil;
	self.oneHourButton = nil;
	self.oneDayButton = nil;
	self.fourDaysButton = nil;
	self.threeMonthsButton = nil;
	self.backButton = nil;
}


- (IBAction)oneHourButtonPressed {
	[loadingIndicator startAnimating];
	
	NSString *url = [NSString stringWithFormat:@"http://www.pachube.com/feeds/%@/datastreams/%d/history.png?w=320&h=410&c=000066&b=1&g=1&s=3&r=1",feedID,[datastreamID intValue]];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


- (IBAction)oneDayButtonPressed {
	[loadingIndicator startAnimating];
	
	/*
	[oneHourButton setSelected:NO];
	[oneDayButton setSelected:YES];
	[fourDaysButton setSelected:NO];
	[threeMonthsButton setSelected:NO]; */
	
	NSString *url = [NSString stringWithFormat:@"http://www.pachube.com/feeds/%@/datastreams/%d/history.png?w=320&h=410&c=000066&b=1&g=1&s=3&r=2",feedID,[datastreamID intValue]];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


- (IBAction)fourDaysButtonPressed {
	[loadingIndicator startAnimating];
	
	NSString *url = [NSString stringWithFormat:@"http://www.pachube.com/feeds/%@/datastreams/%d/history.png?w=320&h=410&c=000066&b=1&g=1&s=3&r=3",feedID,[datastreamID intValue]];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


- (IBAction)threeMonthsButtonPressed {
	[loadingIndicator startAnimating];
	
	NSString *url = [NSString stringWithFormat:@"http://www.pachube.com/feeds/%@/datastreams/%d/history.png?w=320&h=410&c=000066&b=1&g=1&s=3&r=4",feedID,[datastreamID intValue]];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[loadingIndicator stopAnimating];
}


- (void)dealloc {
    MCRelease(backButton);
    MCRelease(oneHourButton);
    MCRelease(oneDayButton);
    MCRelease(fourDaysButton);
    MCRelease(threeMonthsButton);
    MCRelease(webView);
    MCRelease(datastreamID);
    MCRelease(feedID);
    MCRelease(datastreamName);
    MCRelease(loadingIndicator);
    MCRelease(dataStreamViewBar);
    [super dealloc];
}


@end
