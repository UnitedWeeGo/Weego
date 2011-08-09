//
//  Terms.m
//  Weego
//
//  Created by Dave Prukop on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Terms.h"

@interface Terms (Private)

- (void)showLoading;
- (void)hideLoading;
- (void)showError;
- (void)showContent:(NSString *)html;
- (void)showAlertWithCode:(int)code;

@end

@implementation Terms

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
    self.view.backgroundColor = [UIColor clearColor];
    [[NavigationSetter sharedInstance] setNavState:NavStateTerms withTarget:self];
    
    [[ViewController sharedInstance] showDropShadow:0];
    
    UIView *bevelStripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bevelStripe.backgroundColor = HEXCOLOR(0xFFFFFFFF);
    [self.view addSubview:bevelStripe];
    [bevelStripe release];

    shader = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
    shader.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    [self.view addSubview:shader];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(150, 185, 20, 20);
    [self.view addSubview:spinner];
    
    [self showLoading];
    
    [self setUpDataFetcherMessageListeners];
    [[Controller sharedInstance] getTermsHMTLData];
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
    switch (fetchType) {
        case DataFetchTypeTerms:
            [self hideLoading];
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
        case DataFetchTypeTerms:
            [self showError];
            [self showAlertWithCode:errorType];
            break;
            
        default:
            break;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showLoading
{
    [spinner startAnimating];
}

- (void)hideLoading
{
    [spinner stopAnimating];
    NSString *htmlContent = [Model sharedInstance].termsResults;
    [self showContent:htmlContent];
}

- (void)showError
{
    [spinner stopAnimating];
    NSString *htmlContent = [Model sharedInstance].termsResults;
    if (htmlContent && ![htmlContent isEqualToString:@""]) {
        [self showContent:htmlContent];
    }
}

- (void)showAlertWithCode:(int)code
{
    NSString *title = @"Error";
    NSString *message = @"";
    
    switch (code) {
        case NSURLErrorNotConnectedToInternet:
            message = NSLocalizedString(@"Not Connected To Internet. Content shown may be out of date.", @"Error Status");
            break;
        case NSURLErrorTimedOut:
            message = NSLocalizedString(@"Request Timed Out. Content shown may be out of date.", @"Error Status");
            break;
        default:
            message = NSLocalizedString(@"An Error Occurred. Content shown may be out of date.", @"Error Status");
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (void)showContent:(NSString *)html
{
    CGRect webFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:webFrame] autorelease];
    webView.delegate = self;
    webView.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    NSString *url = [NSString stringWithFormat:@"http://beta.weegoapp.com/public/"];
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:url]];
    [self.view insertSubview:webView atIndex:0];
    
    [UIView animateWithDuration:0.30f 
                          delay:0.30f 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         shader.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         shader.hidden = YES;
                     }];
}

#pragma mark - Navigation handlers
- (void)handleBackPress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}

#pragma mark UIWebViewDelegate methods
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)dealloc
{
    [self removeDataFetcherMessageListeners];
    [super dealloc];
}

@end