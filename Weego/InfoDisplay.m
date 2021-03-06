//
//  InfoDisplay.m
//  BigBaby
//
//  Created by Nicholas Velloff on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoDisplay.h"
#import <QuartzCore/QuartzCore.h>

@interface InfoDisplay (Private)

- (void)setUpDataFetcherMessageListeners;
- (void)removeDataFetcherMessageListeners;
- (void)loadHTMLContentWithURL:(NSString *)url;
- (void)setupViews;
- (void)setupScrollView;
- (void)setupPageControl;
- (void)layoutInitialCard;
- (void)layoutCards;
- (UIView *)getCardWithHTMLContent:(NSString *)html withViewIndex:(int)index;
- (void)showLoading;
- (void)hideLoading;
- (void)showError;
- (void)showAlertWithCode:(int)code;

@end

@implementation InfoDisplay

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpDataFetcherMessageListeners];
        [self setupViews];
    }
    return self;
}

#pragma mark setup methods
- (void)setupViews
{
    numPages = -1;
    pad = 10;
    CGRect base = self.frame;
        
    cardSize = CGSizeMake(base.size.width - (pad * 2), base.size.height - (pad * 2));
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 5;
    self.clipsToBounds = NO;
    [self setupScrollView];
    [self setupPageControl];
    
    CGFloat offset = ([Model sharedInstance].currentViewState == ViewStateInfo) ? 0.0 : 4.0;
    CGRect cardFrame = CGRectMake(pad, pad+offset, cardSize.width, cardSize.height);
    shader = [[[UIView alloc] initWithFrame:cardFrame] autorelease];
    shader.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    shader.layer.cornerRadius = 5;
    shader.clipsToBounds = YES;
    [self addSubview:shader];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(150, 185, 20, 20);
    [self addSubview:spinner];
    
    NSString *htmlContent = [Model sharedInstance].infoResults;
    
    if (htmlContent && ![htmlContent isEqualToString:@""]) {
        shader.alpha = 0;
        shader.hidden = YES;
        [self layoutInitialCard];
        [self webViewDidFinishLoad:webView];
    } else {
        [self showLoading];
        if ([delegate respondsToSelector:@selector(infoDisplayWillBeginLoading)]) [delegate infoDisplayWillBeginLoading];
    }
    
    [[Controller sharedInstance] getInfoHMTLData];

}

- (void)setupScrollView
{
    infoScrollView = [[[UIScrollView alloc] initWithFrame:self.frame] autorelease];
    infoScrollView.delegate = self;
    infoScrollView.pagingEnabled = YES;
    infoScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:infoScrollView];
}

- (void)setupPageControl
{
    CGRect base = self.frame;
    pageControl = [[[PageControl alloc] initWithFrame:CGRectMake(0, base.size.height, base.size.width, 12)] autorelease];
//    pageControl.hidesForSinglePage = YES;
    [self addSubview:pageControl];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger nearestNumber = lround(fractionalPage);
    
    if (pageControl.currentPage != nearestNumber)
    {
        pageControl.currentPage = nearestNumber;
//        [pageControl updateCurrentPageDisplay];
    }
}


#pragma mark UIWebViewDelegate methods
- (void)webViewDidFinishLoad:(UIWebView *)myWebView
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    if (numPages == -1) // first page parsing complete
    {
        [self hideLoading];
        if (!delegate) return;
        if ([delegate respondsToSelector:@selector(infoDisplayDidFinishLoading)]) [delegate infoDisplayDidFinishLoading];
        
        NSString *jsCommand = @"getNumberOfPages();";
        NSString *result = [myWebView stringByEvaluatingJavaScriptFromString:jsCommand];
        numPages = [result intValue];
        [self layoutCards];
    }
}

#pragma mark layout methods

- (void)layoutInitialCard
{
    NSString *htmlContent = [Model sharedInstance].infoResults;
    UIView *card = [self getCardWithHTMLContent:htmlContent withViewIndex:0];
    [infoScrollView insertSubview:card atIndex:0];
}

- (void)layoutCards
{
    CGSize scrollFrame = CGSizeMake((numPages * self.frame.size.width), cardSize.height);
    infoScrollView.contentSize = scrollFrame;
    NSString *htmlContent = [Model sharedInstance].infoResults;
    
    for (int i=1; i<numPages; i++) {
        UIView *card = [self getCardWithHTMLContent:htmlContent withViewIndex:i];
        [infoScrollView insertSubview:card atIndex:0];
    }
    pageControl.numberOfPages = numPages;
}

- (UIView *)getCardWithHTMLContent:(NSString *)html withViewIndex:(int)index
{
    CGRect cardFrame = CGRectMake(index * (cardSize.width + (pad*2)) + pad, pad, cardSize.width, cardSize.height);
    
    UIView *view = [[[UIView alloc] initWithFrame:cardFrame] autorelease];
    view.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    view.layer.cornerRadius = 5;
    view.clipsToBounds = YES;
    
    CGRect webFrame = CGRectMake(0, 0, cardSize.width, cardSize.height);
    webView = [[[UIWebView alloc] initWithFrame:webFrame] autorelease];
    webView.userInteractionEnabled = NO;
    webView.delegate = self;
    webView.tag = index;
    webView.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    NSString *url = [NSString stringWithFormat:@"http://unitedweego.com/?%d", index];
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:url]];
    [view addSubview:webView];
    
    return view;
}





//DataFetchTypeInfo
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
        case DataFetchTypeInfo:
            [self layoutInitialCard];
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
        case DataFetchTypeInfo:
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
    NSString *htmlContent = [Model sharedInstance].infoResults;
    if (htmlContent && ![htmlContent isEqualToString:@""]) {
        UIView *card = [self getCardWithHTMLContent:htmlContent withViewIndex:0];
        [infoScrollView insertSubview:card atIndex:0];
    }
}

- (void)showAlertWithCode:(int)code
{
    NSString *title = @"Error";
    NSString *message = @"";
    
    switch (code) {
        case NSURLErrorNotConnectedToInternet:
            message = NSLocalizedString(@"Not Connected To Internet. Content shown may be out of date.", @"Error Status");
            return; // Breaking out of this because we don't want to show this message here.
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

- (void)showContent
{
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

- (void)dealloc
{
    delegate = nil;
    webView.delegate = nil;
    [webView stopLoading];
    webView = nil;
    
    [self removeDataFetcherMessageListeners];
    infoScrollView.delegate = nil;
    [super dealloc];
}

@end
