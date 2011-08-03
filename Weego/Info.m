//
//  Info.m
//  BigBaby
//
//  Created by Nicholas Velloff on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Info.h"

@interface Info (Private)

- (void)addInfoDisplay;
- (void)showLoading;
- (void)hideLoading;

@end

@implementation Info

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
    [[NavigationSetter sharedInstance] setNavState:NavStateInfo withTarget:self];
    [self addInfoDisplay];
    
    UIView *headerViewMask = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320, 60)];
    headerViewMask.clipsToBounds = YES;
    [self.view addSubview:headerViewMask];
    [headerViewMask release];
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -60.0f, 320, 60)];
    _refreshHeaderView.delegate = self;
    [headerViewMask addSubview:_refreshHeaderView];
    [_refreshHeaderView release];
}

#pragma mark - setup view elements
- (void)addInfoDisplay
{
    CGRect base = self.view.frame;
    infoDisplay = [[[InfoDisplay alloc] initWithFrame:CGRectMake(0, 0, base.size.width, base.size.height - 75)] autorelease];
    infoDisplay.delegate = self;
    [self.view addSubview:infoDisplay];
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

#pragma mark - InfoDisplayDelegate

- (void)infoDisplayWillBeginLoading
{
    [self showLoading];
}

- (void)infoDisplayDidFinishLoading
{
    [self hideLoading];
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
                         [infoDisplay showContent];
                     }];
}

#pragma mark - Navigation handlers
- (void)handleBackPress:(id)sender
{
    [[ViewController sharedInstance] goBack];
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

@end
