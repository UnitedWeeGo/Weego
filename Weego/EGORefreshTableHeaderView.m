//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"
#import "Model.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f
#define WAIT_FOR_CLOSE_INTERVAL 5.0f


@interface EGORefreshTableHeaderView (Private)
- (void)setStatusLabelForError:(int)code;
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
        UIColor *labelColor = nil;
        UIColor *shadowColor = nil;
        NSString *arrowImage = @"";
        int activityIndicatorStyle = -1;
        
        BGState bgState = [Model sharedInstance].currentBGState;
        
        switch (bgState) {
            case BGStateHome :
                labelColor = HEXCOLOR(0xF5F5F5FF);
                shadowColor = HEXCOLOR(0x33333333);
                arrowImage = @"icon_pullArrow_light_01.png";
                activityIndicatorStyle = UIActivityIndicatorViewStyleWhite;
                break;
            case BGStateEvent :
                labelColor = HEXCOLOR(0x787878FF);
                shadowColor = HEXCOLOR(0xFFFFFF33);
                arrowImage = @"icon_pullArrow_dark_01.png";
                activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
                break;
            case BGStateFeed:
                labelColor = HEXCOLOR(0x787878FF);
                shadowColor = HEXCOLOR(0xFFFFFF33);
                arrowImage = @"icon_pullArrow_dark_01.png";
                activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
                break;
            default:
                break;
        }
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = HEXCOLOR(0x00000026);

        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = labelColor;
		label.shadowColor = shadowColor;
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		[label release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = labelColor;
		label.shadowColor = shadowColor;
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(12.0f, frame.size.height - 42.0f, 17.0f, 26.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrowImage].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
        
        CALayer *errorlayer = [CALayer layer];
		errorlayer.frame = CGRectMake(14.0f, frame.size.height - 36.0f, 16.0f, 16.0f);
		errorlayer.contentsGravity = kCAGravityResizeAspect;
		errorlayer.contents = (id)[UIImage imageNamed:@"icon_error.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			errorlayer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		[[self layer] addSublayer:errorlayer];
		_errorImage=errorlayer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityIndicatorStyle];
		view.frame = CGRectMake(12.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		[view release];
		
		[self setState:EGOOPullRefreshNormal];
		
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	if (_delegate == nil) return;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"AM"];
		[formatter setPMSymbol:@"PM"];
		[formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [date getWeegoFormattedDateString]]; // [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[formatter release];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}

}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
            _errorImage.hidden = YES;
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
            _errorImage.hidden = YES;
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
            _errorImage.hidden = YES;
			
			break;
        case EGOOPullRefreshShowError:
//            _statusLabel.text = NSLocalizedString(@"An Error Occurred, Try Again...", @"Error Status");
            [_activityView stopAnimating];
            [CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
            _errorImage.hidden = NO;
		default:
			break;
	}
	
	_state = aState;
}

- (void)setStatusLabelForError:(int)code
{
    switch (code) {
        case NSURLErrorNotConnectedToInternet:
            _statusLabel.text = NSLocalizedString(@"Not Connected To Internet", @"Error Status");
            break;
        case NSURLErrorTimedOut:
            _statusLabel.text = NSLocalizedString(@"Request Timed Out, Try Again...", @"Error Status");
            break;
        default:
            _statusLabel.text = NSLocalizedString(@"An Error Occurred, Try Again...", @"Error Status");
            break;
    }
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
	
	if (_state == EGOOPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} 
    else if (_state == EGOOPullRefreshShowError) {
        CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    } 
    else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
//        else if (_state == EGOOPullRefreshShowError && 
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		
	}
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
                     }
                     completion:^(BOOL finished){
                         if (!_cancelAnimations) {
                             [self setState:EGOOPullRefreshNormal];
                             if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderClosed)]) {
                                 [_delegate egoRefreshTableHeaderClosed];
                             }
                         }
                     }];
    
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationDuration:.3];
//	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
//	[UIView commitAnimations];
//	
//	[self setState:EGOOPullRefreshNormal];

}

- (void)egoRefreshScrollViewOpenAndShowLoading:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setState:EGOOPullRefreshLoading];
    if (scrollView) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
        [self performSelector:@selector(egoRefreshScrollViewDataSourceDidFinishedLoading:) withObject:scrollView afterDelay:DATA_FETCH_TIMEOUT_SECONDS_INTERVAL + 0.1f];
    }
}

- (void)egoRefreshScrollViewOpenAndShowSaving:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setState:EGOOPullRefreshLoading];
    if (scrollView) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
    }
    _statusLabel.text = NSLocalizedString(@"Saving...", @"Saving Status");
}

- (void)egoRefreshScrollViewShowError:(UIScrollView *)scrollView withCode:(int)code
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    BOOL _loading = NO;
    if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
        _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
    }
    if (_loading) {
        [self setStatusLabelForError:code];
        [self setState:EGOOPullRefreshShowError];
        if (scrollView) [self performSelector:@selector(egoRefreshScrollViewDataSourceDidFinishedLoading:) withObject:scrollView afterDelay:WAIT_FOR_CLOSE_INTERVAL];
    }
}

- (void)egoRefreshScrollViewOpenAndShowError:(UIScrollView *)scrollView withCode:(int)code
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setStatusLabelForError:code];
    [self setState:EGOOPullRefreshShowError];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
    [UIView commitAnimations];
    [self performSelector:@selector(egoRefreshScrollViewDataSourceDidFinishedLoading:) withObject:scrollView afterDelay:WAIT_FOR_CLOSE_INTERVAL];
}

- (void)cancelAnimations
{
    _cancelAnimations = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)reset:(UIScrollView *)scrollView
{
    _cancelAnimations = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [UIView animateWithDuration:0 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         if (scrollView) [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
                     } completion:^(BOOL finished){
                         [self setState:EGOOPullRefreshNormal];
                         if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderClosed)]) {
                             [_delegate egoRefreshTableHeaderClosed];
                         }
                     }];
    _cancelAnimations = NO;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [super dealloc];
}


@end
