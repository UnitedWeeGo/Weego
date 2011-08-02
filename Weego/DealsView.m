//
//  DealsView.m
//  Weego
//
//  Created by Dave Prukop on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DealsView.h"

@interface DealsView (Private)

- (void)showLoading;
- (void)hideLoading;
- (void)showContent:(NSString *)html;

@end

@implementation DealsView

@synthesize dealCode;

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
    [[NavigationSetter sharedInstance] setNavState:NavStateDeals withTarget:self];
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self];
    
    UIView *bevelStripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bevelStripe.backgroundColor = HEXCOLOR(0xFFFFFFFF);
    [self.view addSubview:bevelStripe];
    [bevelStripe release];
    
    UIView *headerViewMask = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320, 60)];
    headerViewMask.clipsToBounds = YES;
    [self.view addSubview:headerViewMask];
    [headerViewMask release];
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -60.0f, 320, 60)];
    _refreshHeaderView.delegate = self;
    [headerViewMask addSubview:_refreshHeaderView];
    [_refreshHeaderView release];
    
    shader = [[[UIView alloc] initWithFrame:self.view.frame] autorelease];
    shader.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    [self.view addSubview:shader];
    
    [self setUpDataFetcherMessageListeners];
    [[Controller sharedInstance] getDealsHTMLDataWithCode:self.dealCode];
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
        case DataFetchTypeDeal:
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
    switch (fetchType) {
        case DataFetchTypeDeal:            
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
    [_refreshHeaderView egoRefreshScrollViewOpenAndShowLoading:nil];
    [_refreshHeaderView refreshLastUpdatedDate];
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         //                         contactEntry.frame = CGRectMake(0, 60, 320, contactEntry.frame.size.height);
                         _refreshHeaderView.frame = CGRectMake(0, 0, 320, 60);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [[ViewController sharedInstance] showDropShadow:5];
}

- (void)hideLoading
{
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         //                         contactEntry.frame = CGRectMake(0, 0, 320, contactEntry.frame.size.height);
                         _refreshHeaderView.frame = CGRectMake(0, -60.0f, 320, 60);
                         
                     }
                     completion:^(BOOL finished){
                         [[ViewController sharedInstance] showDropShadow:0];
                         NSString *htmlContent = [Model sharedInstance].dealResults;
                         [self showContent:htmlContent];
                     }];
}

- (void)showContent:(NSString *)html
{
    CGRect webFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:webFrame] autorelease];
    webView.delegate = self;
    webView.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    NSString *url = [NSString stringWithFormat:@"http://beta.weegoapp.com/public/"];
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:url]];
    [self.view addSubview:webView];
    
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         shader.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         shader.hidden = YES;
                     }];
}

#pragma mark - Navigation handlers
- (void)handleHomePress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}

#pragma mark UIWebViewDelegate methods
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}



#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	_saving = YES;
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _saving; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

- (void)egoRefreshTableHeaderClosed
{
    //    _refreshHeaderView.hidden = YES;
}

- (void)dealloc
{
    [self removeDataFetcherMessageListeners];
    [self.dealCode release];
    [super dealloc];
}

@end