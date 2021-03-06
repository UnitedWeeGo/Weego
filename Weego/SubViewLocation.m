//
//  SubViewLocation.m
//  BigBaby
//
//  Created by Dave Prukop on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubViewLocation.h"
#import "Event.h"
#import "Model.h"

@interface SubViewLocation (Private)

- (void)setUpUI;
- (void)createMapButton;
- (void)createSeeLocationButton;
- (void)createLikeButton;
- (void)createUnlikeButton;
- (void)createErrorView;
- (void)createDealButton;
- (void)createLocationPOIIcon;

// these are state related methods
- (void)setUIState;
- (void)resetUIState;
- (void)addMap;
- (void)showLoading;
- (void)showLikeUnlike;
- (void)showPOIIcon;
- (void)showSeeLocButton;
- (void)showDealButton;

- (NSString *)urldecode:(NSString *)aString;

- (void)setFormattedAddress;

@end

@implementation SubViewLocation

@synthesize delegate;
@synthesize location;
@synthesize index;
@synthesize eventState;
@synthesize editing;
@synthesize doShowReportingLocationIcon;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        actionBtnRect = CGRectMake(10, 10, 50, 50);
        dealBtnRect = CGRectMake(265, 34, 28, 28);
        [self setUpUI];
    }
    return self;
}

- (void)setLocation:(Location *)aLocation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [location release];
    location = aLocation;
    [location retain];
    labelTitle.text = [self urldecode:aLocation.name];
    imageOwnerIndicator.hidden = !aLocation.addedByMe;
    
    [self setFormattedAddress];
    [self resetUIState];
    [self setUIState];
}

- (void)setFormattedAddress
{
    NSString *formatted_address = [self urldecode:location.formatted_address];
    
    if ([formatted_address rangeOfString:@","].length == 0)
    {
        labelSecondaryInfo.text = formatted_address;
    }
    else
    {
        int commaLoc = [formatted_address rangeOfString:@","].location;
        
        NSString *labelSecondaryInfoS = [formatted_address substringWithRange:NSMakeRange(0, commaLoc)];
        NSString *labelTertiaryInfoS = [formatted_address substringWithRange:NSMakeRange(commaLoc+2, [formatted_address length]-commaLoc-2)];
        
        labelSecondaryInfo.text = labelSecondaryInfoS;
        labelTertiaryInfo.text = labelTertiaryInfoS;
    }
}

- (void)setUIState
{
    isDashboardMode = [Model sharedInstance].currentAppState == AppStateDashboard;

    if (location.hasPendingVoteRequest) {
        [self showLoading];
    } else {
        
        if ( doShowReportingLocationIcon && !isDashboardMode)
        {
            [self showPOIIcon];
        } 
        else if (eventState < EventStateDecided)
        {
            [self showLikeUnlike];
        }
        else if (eventState >= EventStateDecided)
        {
            if (index==0)  [self addMap];
            else [self showLikeUnlike];
        }
    }
    if (!isDashboardMode)
    {
        [self showSeeLocButton];
        [self showDealButton];
    }
    if ([location.location_type isEqualToString:@"yelp"])
    {
        NSString *reviewImg = [NSString stringWithFormat:@"stars_%@.png", location.rating];
        UIImage *rImage = [UIImage imageNamed:reviewImg];
        [ratingImage setImage:rImage];
        [reviewCountLabel setText:[NSString stringWithFormat:@"%@ reviews", location.reviewCount]];
        [reviewCountLabel sizeToFit];
    }
}

- (void)resetUIState
{
    likeButton.hidden = YES;
    unlikeButton.hidden = YES;
    locationImage.hidden = YES;
    annotationImage.hidden = YES;
    mapBtn.hidden = YES;
    locationPOIIcon.hidden = YES;
    seeLocButton.hidden = YES;
    dealButton.hidden = YES;
    loading.hidden = YES;
    [activityView stopAnimating];
    errorView.hidden = YES;
    
    BOOL isYelp = [location.location_type isEqualToString:@"yelp"];
    BOOL isPast = NO;
    Event *cEv = [Model sharedInstance].currentEvent;
    
    if (cEv != nil)
    {
        isPast = cEv.currentEventState >= EventStateEnded;
    }
    
    ratingImage.hidden = !isYelp || isPast;
    reviewCountLabel.hidden = !isYelp || isPast;
    labelTertiaryInfo.hidden = isYelp && !isPast;
}

- (void)addMap
{
    NSString *urlString = [[[NSString alloc] initWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%@,%@&zoom=15&size=50x50&sensor=true", location.latitude, location.longitude] autorelease];
    NSURL *url = [NSURL URLWithString:urlString];
    [locationImage asyncLoadWithNSURL:url useCached:YES andBaseImage:BaseImageTypeMap useBorder:YES];
    
    locationImage.hidden = NO;
    annotationImage.hidden = NO;
    mapBtn.hidden = isDashboardMode;
}

- (void)showLoading
{
    likeButton.hidden = YES;
    unlikeButton.hidden = YES;
    loading.hidden = NO;
    [activityView startAnimating];
}

- (void)showError
{
    loading.hidden = YES;
    [activityView stopAnimating];
    [self showLikeUnlike];
    errorView.hidden = NO;
    [self performSelector:@selector(hideError) withObject:nil afterDelay:5.0];
}

- (void)hideError
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         errorView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         errorView.hidden = YES;
                         errorView.alpha = 1;
                     }];
}

- (void)showLikeUnlike
{
    Boolean iLikedLocation = [[Model sharedInstance] loginUserDidVoteForLocationWithId:location.locationId inEventWithId:location.ownerEventId];
    UIButton *buttonToShow = iLikedLocation ? unlikeButton : likeButton;
    buttonToShow.hidden = NO;
    buttonToShow.enabled = !isDashboardMode && (eventState < EventStateDecided);
}

- (void)showPOIIcon
{
    locationPOIIcon.hidden = NO;
}

- (void)showSeeLocButton
{
    seeLocButton.hidden = NO;
}

- (void)showDealButton
{
    dealButton.hidden = !location.hasDeal;
}

- (void)setUpUI
{
	self.backgroundColor = [UIColor clearColor];
    
    UIColor *labelColor = nil;
    UIColor *titleLabelColor = nil;
    UIColor *shadowColor = nil;
    UIColor *mineLabelColor = nil;
    
    labelColor = HEXCOLOR(0x666666FF);
    titleLabelColor = HEXCOLOR(0x333333FF);
    shadowColor = HEXCOLOR(0xFFFFFF33);
    mineLabelColor = HEXCOLOR(0x999999FF);
    
	nextY = 10.0;
    
    if (locationImage == nil) locationImage = [[[UIImageViewAsyncLoader alloc] initWithFrame:CGRectMake(leftMargin + 10, nextY, 50, 50)] autorelease];
    locationImage.frame = CGRectMake(leftMargin + 10, nextY, 50, 50);    
    [self addSubview:locationImage];
    
    if (annotationImage == nil) annotationImage = [[[UIImageView alloc] init] autorelease];
    UIImage *anno = [UIImage imageNamed:@"POIs_decided_default_sm.png"];
    annotationImage.frame = CGRectMake(21, 15, anno.size.width, anno.size.height);
    annotationImage.image = anno;
    [self addSubview:annotationImage];
    
    float textLeftPos = leftMargin + 60 + 8;
    fieldWidth = 320 - textLeftPos - 50;
    fieldEditingWidth = 320 - textLeftPos - 90;
    
    nextY = 12;
    
    if (labelTitle == nil) labelTitle = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
                                                                                   nextY, 
                                                                                   fieldWidth, 
                                                                                   22)] autorelease];
	labelTitle.textColor = titleLabelColor;
	labelTitle.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:18];
	labelTitle.shadowColor = shadowColor;
	labelTitle.shadowOffset = CGSizeMake(0.0, 1.0);
	labelTitle.backgroundColor = [ UIColor clearColor ]; 
	labelTitle.lineBreakMode = UILineBreakModeTailTruncation;
	labelTitle.numberOfLines = 0;
	[self addSubview:labelTitle];
    
	nextY = labelTitle.frame.origin.y + labelTitle.frame.size.height - 3;
	
	if (labelSecondaryInfo == nil) labelSecondaryInfo = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
                                                                                                   nextY, 
                                                                                                   fieldWidth, 
                                                                                                   15)] autorelease];
	labelSecondaryInfo.textColor = labelColor;
	labelSecondaryInfo.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelSecondaryInfo.backgroundColor = [ UIColor clearColor ];
	[self addSubview:labelSecondaryInfo];
    
	nextY = labelSecondaryInfo.frame.origin.y + labelSecondaryInfo.frame.size.height - 3;
    
    if (labelTertiaryInfo == nil) labelTertiaryInfo = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
                                                                                       nextY, 
                                                                                       fieldWidth, 
                                                                                       16)] autorelease];
	labelTertiaryInfo.textColor = labelColor;
	labelTertiaryInfo.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelTertiaryInfo.backgroundColor = [ UIColor clearColor ]; 
	labelTertiaryInfo.lineBreakMode = UILineBreakModeWordWrap;
	labelTertiaryInfo.numberOfLines = 0;
	[self addSubview:labelTertiaryInfo];
    
    
    
    ratingImage = [[[UIImageView alloc] initWithFrame:CGRectMake(textLeftPos, 
                                                                 nextY+3, 
                                                                 66, 
                                                                 12)] autorelease];
    ratingImage.hidden = YES;
    [self addSubview:ratingImage];
    
    
    UIFont *tertiaryFont = [UIFont fontWithName:@"MyriadPro-Regular" size:10];
    reviewCountLabel = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos+69, 
                                                                  nextY+5, 
                                                                  250, 
                                                                  12)] autorelease];
    reviewCountLabel.backgroundColor = [UIColor clearColor];
    reviewCountLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1];
    [reviewCountLabel setFont:tertiaryFont];
    reviewCountLabel.lineBreakMode = UILineBreakModeWordWrap;
    reviewCountLabel.numberOfLines = 1;
    [self addSubview:reviewCountLabel];
    
	nextY = labelTertiaryInfo.frame.origin.y + labelTertiaryInfo.frame.size.height;
    
    UIImage *iconImage = [UIImage imageNamed:@"icon_MyLocation_01.png"];
    imageOwnerIndicator = [[UIImageView alloc] initWithImage:iconImage];
    imageOwnerIndicator.frame = CGRectMake(277, 11, iconImage.size.width, iconImage.size.height);
    imageOwnerIndicator.hidden = YES;
    [self addSubview:imageOwnerIndicator];
    [imageOwnerIndicator release];
    
    [self createMapButton];
    [self createLikeButton];
    [self createUnlikeButton];
    [self createSeeLocationButton];
    [self createDealButton];
    //[self createLoadingView];
    [self createErrorView];
    [self createLocationPOIIcon];
    
    [self resetUIState]; // hides everything (button related)
	
	self.frame = CGRectMake(self.frame.origin.x, 
							self.frame.origin.y, 
							self.frame.size.width, 
							nextY);
}

- (void)setEditing:(BOOL)isEditing
{
    imageOwnerIndicator.hidden = isEditing;
    int newWidth = isEditing ? fieldEditingWidth : fieldWidth;
    CGRect titleFrame = CGRectMake(labelTitle.frame.origin.x, labelTitle.frame.origin.y, newWidth, labelTitle.frame.size.height);
    CGRect secFrame = CGRectMake(labelSecondaryInfo.frame.origin.x, labelSecondaryInfo.frame.origin.y, newWidth, labelSecondaryInfo.frame.size.height);
    CGRect terFrame = CGRectMake(labelTertiaryInfo.frame.origin.x, labelTertiaryInfo.frame.origin.y, newWidth, labelTertiaryInfo.frame.size.height);
    labelTitle.frame = titleFrame;
    labelSecondaryInfo.frame = secFrame;
    labelTertiaryInfo.frame = terFrame;
    if (isEditing) {
        dealButton.hidden = YES;
    } else {
        [self showDealButton];
    }
}

- (void)createMapButton
{
    mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mapBtn.frame = locationImage.frame;
    [mapBtn addTarget:self action:@selector(mapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mapBtn];
}

- (void)createSeeLocationButton // this covers the button to the right of the like/unlike to go to the map
{
    seeLocButton = [UIButton buttonWithType:UIButtonTypeCustom];
    seeLocButton.alpha = .6;
    seeLocButton.frame = CGRectMake(64, 0, self.frame.size.width - 64, nextY+5);
    [seeLocButton addTarget:self action:@selector(mapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:seeLocButton];
}

- (void)createLikeButton
{
    likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    likeButton.hidden = YES;
    likeButton.adjustsImageWhenHighlighted = NO;
    likeButton.frame = actionBtnRect;
	[likeButton setImage:[UIImage imageNamed:@"button_like_default.png"] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageNamed:@"button_like_pressed.png"] forState:UIControlStateHighlighted];
    [likeButton setImage:[UIImage imageNamed:@"button_like_default.png"] forState:UIControlStateDisabled];
    [likeButton addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:likeButton];
}

- (void)createUnlikeButton
{
    unlikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    unlikeButton.hidden = YES;
    unlikeButton.adjustsImageWhenHighlighted = NO;
    unlikeButton.frame = actionBtnRect;
	[unlikeButton setImage:[UIImage imageNamed:@"button_unlike_default.png"] forState:UIControlStateNormal];
    [unlikeButton setImage:[UIImage imageNamed:@"button_unlike_pressed.png"] forState:UIControlStateHighlighted];
    [unlikeButton setImage:[UIImage imageNamed:@"button_unlike_default.png"] forState:UIControlStateDisabled];
    [unlikeButton addTarget:self action:@selector(unlikeButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:unlikeButton];
}

- (void)createLocationPOIIcon
{
    locationPOIIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    locationPOIIcon.hidden = YES;
    locationPOIIcon.adjustsImageWhenHighlighted = NO;
    [locationPOIIcon setImage:[UIImage imageNamed:@"button_decided_default.png"] forState:UIControlStateNormal];
    locationPOIIcon.frame = actionBtnRect;
    [locationPOIIcon addTarget:self action:@selector(mapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:locationPOIIcon];
}

- (void)createErrorView
{
    errorView = [[UIView alloc] initWithFrame:actionBtnRect];
    errorView.hidden = YES;
    UIImageView *errorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_error.png"]];
    errorImage.frame = CGRectMake(17, 17, 16, 16);
    [errorView addSubview:errorImage];
    [errorImage release];
    [self addSubview:errorView];
    [errorView release];
}

- (void)createDealButton
{
    dealButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dealButton.hidden = YES;
    dealButton.adjustsImageWhenHighlighted = NO;
    dealButton.frame = dealBtnRect;
    [dealButton setImage:[UIImage imageNamed:@"button_deal_light_default.png"] forState:UIControlStateNormal];
    [dealButton setImage:[UIImage imageNamed:@"button_deal_light_pressed.png"] forState:UIControlStateHighlighted];
    [dealButton setImage:[UIImage imageNamed:@"button_deal_light_default.png"] forState:UIControlStateDisabled];
    [dealButton addTarget:self action:@selector(dealButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:dealButton];
}

- (void)mapButtonPressed
{
//    NSLog(@"mapButtonPressed");
    [delegate mapButtonPressed:self];
}

- (void)likeButtonPressed
{
    [delegate likeButtonPressed:self];
}
- (void)unlikeButtonPressed
{
    [delegate unlikeButtonPressed:self];
}

- (void)dealButtonPressed
{
    NSLog(@"dealButtonPressed");
    [[ViewController sharedInstance] showDeal:location.g_id];
}

- (NSString *)urldecode:(NSString *)aString
{
	aString = [aString stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
	return aString;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    delegate = nil;
    [location release];
    location = nil;
    [super dealloc];
}

@end
