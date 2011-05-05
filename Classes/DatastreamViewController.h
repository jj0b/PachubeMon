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


@interface DatastreamViewController : UIViewController <UIWebViewDelegate> {
	
	UIWebView *webView;
	UIButton *backButton;
	UIButton *oneHourButton;
	UIButton *oneDayButton;
	UIButton *fourDaysButton;
	UIButton *threeMonthsButton;
	NSNumber *datastreamID;
	NSString *feedID;
	NSString *datastreamName;
	UIActivityIndicatorView *loadingIndicator;
	UINavigationBar *dataStreamViewBar;
	
}

@property (nonatomic, retain) NSNumber *datastreamID;
@property (nonatomic, copy) NSString *feedID;
@property (nonatomic, copy) NSString *datastreamName;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIButton *oneHourButton;
@property (nonatomic, retain) IBOutlet UIButton *oneDayButton;
@property (nonatomic, retain) IBOutlet UIButton *fourDaysButton;
@property (nonatomic, retain) IBOutlet UIButton *threeMonthsButton;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UINavigationBar *dataStreamViewBar;

- (IBAction)backButtonPressed;
- (IBAction)oneHourButtonPressed;
- (IBAction)oneDayButtonPressed;
- (IBAction)fourDaysButtonPressed;
- (IBAction)threeMonthsButtonPressed;

@end
