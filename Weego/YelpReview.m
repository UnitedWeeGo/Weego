//
//  YelpReview.m
//  Weego
//
//  Created by Nicholas Velloff on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "YelpReview.h"

@implementation YelpReview

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = HEXCOLOR(0xF3F3F3FF);	
    [[NavigationSetter sharedInstance] setNavState:NavStateReviews withTarget:self];
    
    wView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    [self.view addSubview:wView];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[Model sharedInstance].currentReviewURL]];
    [wView loadRequest:req];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Model sharedInstance].currentViewState = ViewStateReviews;
    [[ViewController sharedInstance] showDropShadow:0];
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self withFeedCount:0];
}

#pragma mark - Navigation methods
- (void)handleBackPress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}

#pragma mark - UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

#pragma mark - Etc
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
