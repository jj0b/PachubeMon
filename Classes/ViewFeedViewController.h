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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewFeedViewController : UIViewController <UIWebViewDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource> {
	NSString *feedID;
	NSString *feedName;
	UINavigationBar *feedViewBar;
	UIActivityIndicatorView *loadingIndicator;
	UILabel *loadingLabel;
	MKMapView *mapView;
	NSMutableData *responseData;
	NSDictionary *feedInfoDictionary;
	UITableView *datastreamTable;
	NSMutableArray *datastreamWebViewArray;
	
}

@property (nonatomic, retain) NSMutableArray *datastreamWebViewArray;
@property (nonatomic, retain) IBOutlet UITableView *datastreamTable;
@property (nonatomic, copy) NSDictionary *feedInfoDictionary;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSString *feedID;
@property (nonatomic, retain) NSString *feedName;
@property (nonatomic, retain) IBOutlet UINavigationBar *feedViewBar;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UILabel *loadingLabel;

- (NSString *)pathToFile:(NSString *)fileName;
- (IBAction)backToFeedListButtonPressed:(id)sender;
- (void)viewWillAppear:(Boolean)animated;
- (void)stopLoadingIndicator;
- (int)numberOfDatastreams;

@end
