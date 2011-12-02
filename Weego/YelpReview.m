//
//  YelpReview.m
//  Weego
//
//  Created by Nicholas Velloff on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "YelpReview.h"

@implementation YelpReview

@interface YelpReview (Private)

- (void)setUpDataFetcherMessageListeners;
- (void)removeDataFetcherMessageListeners;
- (void)showLoading;
- (void)hideLoading;
- (void)showError;
- (void)showAlertWithCode:(int)code;
- (BOOL)isYelpInstalled;

@end

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - DataFetcherMessageHandler
- (void)setUpDataFetcherMessageListeners
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataFetcherSuccessMessage:) name:DATA_FETCHER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataFetcherErrorMessage:) name:DATA_FETCHER_ERROR object:nil];
}

- (void)removeDataFetcherMessageListeners
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_FETCHER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_FETCHER_ERROR object:nil];
}

- (void)handleDataFetcherSuccessMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    NSString *loadedHTML;
    switch (fetchType) {
        case DataFetchTypeReviewHTML:
            loadedHTML = [Model sharedInstance].reviewResults;
            loadedHTML = [loadedHTML stringByReplacingOccurrencesOfString:@"<head>" withString:@"<head><style type=\"text/css\">#search-bar{display:none;}</style>"];
            [wView loadHTMLString:loadedHTML baseURL:[NSURL URLWithString:[Model sharedInstance].currentReviewURL]];
            break;
            
        default:
            break;
    }
}

- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    int errorType = [[dict objectForKey:DataFetcherErrorKey] intValue];
    switch (fetchType) {
        case DataFetchTypeReviewHTML:
            [self showError];
            [self showAlertWithCode:errorType];
            break;
            
        default:
            break;
    }
}


- (void)showLoading
{
    [spinner startAnimating];
}

- (void)hideLoading
{
    [spinner stopAnimating];
}

- (void)showError
{
    [spinner stopAnimating];
    
}

- (void)showAlertWithCode:(int)code
{
    NSString *title = @"Error";
    NSString *message = @"";
    
    switch (code) {
        case NSURLErrorNotConnectedToInternet:
            message = NSLocalizedString(@"Not Connected To Internet.", @"Error Status");
            break;
        case NSURLErrorTimedOut:
            message = NSLocalizedString(@"Request Timed Out.", @"Error Status");
            break;
        default:
            message = NSLocalizedString(@"An Error Occurred.", @"Error Status");
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    [self setUpDataFetcherMessageListeners];
    
    self.view.backgroundColor = HEXCOLOR(0xF3F3F3FF);	
    [[NavigationSetter sharedInstance] setNavState:NavStateReviews withTarget:self];
    
    wView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)] autorelease];
    [wView setDelegate:self];
    [self.view addSubview:wView];
    
    [spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    spinner.frame = CGRectMake(150, 185, 20, 20);
    [self.view addSubview:spinner];
    
    [self showLoading];
    
    [[Controller sharedInstance] getYelpHMTLDataWithURLString:[Model sharedInstance].currentReviewURL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Model sharedInstance].currentViewState = ViewStateReviews;
    [[ViewController sharedInstance] showDropShadow:0];
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self withFeedCount:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [wView setDelegate:nil];
    [self removeDataFetcherMessageListeners];
    [wView stopLoading];
}

#pragma mark - Navigation methods
- (void)handleBackPress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}

- (void)handleMorePress:(id)sender
{
    [[MoreButtonActionSheetController sharedInstance:self] showUserActionSheetForReview];
}

- (void)goToYelpReviewPage
{
    [[UIApplication sharedApplication] 
     openURL:[NSURL URLWithString:[Model sharedInstance].currentReviewURL]];
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
    [self hideLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}
#pragma mark - Etc

- (BOOL)isYelpInstalled 
{ 
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"yelp4:"]]; 
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
