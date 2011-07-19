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
- (void)setupSpinner;
- (void)setupScrollView;
- (void)setupPageControl;
- (void)layoutInitialCard;
- (void)layoutCards;
- (UIView *)getCardWithHTMLContent:(NSString *)html withViewIndex:(int)index;

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
    
    if ([delegate respondsToSelector:@selector(infoDisplayWillBeginLoading)]) [delegate infoDisplayWillBeginLoading];
//    [self setupSpinner];
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

- (void)setupSpinner
{
    _spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    _spinner.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_spinner sizeToFit];
    [_spinner startAnimating];
    _spinner.center = self.center;
    [self addSubview:_spinner];
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
    if (numPages == -1) // first page parsing complete
    {
//        [_spinner stopAnimating];
//        _spinner.hidden = YES;
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
    NSString *url = [NSString stringWithFormat:@"http://beta.weegoapp.com/public/?%d", index];
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
    switch (fetchType) {
        case DataFetchTypeInfo:
            // recover by populating local data
//            [_spinner stopAnimating];
//            _spinner.hidden = YES;
#warning need to add local content
            
            break;
            
        default:
            break;
    }
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
