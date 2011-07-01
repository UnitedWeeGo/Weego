//
//  HeaderViewEventDetail.m
//  BigBaby
//
//  Created by Dave Prukop on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubViewEventInfo.h"
#import "Event.h"
#import <UIKit/UIKit.h>

@interface SubViewEventInfo(Private)

- (void)setUpUI;
- (NSString *)urldecode:(NSString *)aString;

@end


@implementation SubViewEventInfo

@synthesize event;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        leftMargin = frame.origin.x;
        [self setUpUI];
    }
    return self;
}

- (void)setEvent:(Event *)anEvent
{
    [event release];
    event = anEvent;
    [event retain];
    
    NSURL *url = [NSURL URLWithString:[anEvent getCreatorAvatarURL]];
    [avatarImage asyncLoadWithNSURL:url useCached:YES andBaseImage:BaseImageTypeAvatar useBorder:YES];

    labelCreator.text = [self urldecode:[anEvent getCreatorFullName]];
    labelTitle.text = [self urldecode:anEvent.eventTitle];
    labelDate.text = [anEvent getFormattedDateString];
    
    BOOL isDashboardMode = [Model sharedInstance].currentAppState == AppStateDashboard;
    BOOL toShowFeedInfo = [anEvent.unreadMessageCount intValue] > 0 && isDashboardMode;
    BOOL eventHasBeenRead = [anEvent.eventRead isEqualToString:@"true"];
    AcceptanceType acceptanceStatus = anEvent.acceptanceStatus;
    BOOL doPushDownFeedIcon = NO;
    
    labelNewIndicator.text = @"";
    
    if (!eventHasBeenRead && isDashboardMode)
    {
        doPushDownFeedIcon = YES;
        labelNewIndicator.text = @"NEW";
    }
    else if (acceptanceStatus == AcceptanceTypePending && isDashboardMode)
    {
        doPushDownFeedIcon = YES;
        labelNewIndicator.text = @"PENDING";
    }
    else if (acceptanceStatus == AcceptanceTypeAccepted && isDashboardMode)
    {
        // do nothing
    }
    else if (acceptanceStatus == AcceptanceTypeDeclined && isDashboardMode)
    {
        doPushDownFeedIcon = YES;
        labelNewIndicator.text = @"DECLINED";
    }
    
    if (toShowFeedInfo)
    {
        CGRect frame = feedIconView.frame;
        frame.origin.y = doPushDownFeedIcon ? 30 : 12;
        feedIconView.frame = frame;
        
    }
    
    feedIconView.hidden = !toShowFeedInfo;
    [feedCountLabel setText:anEvent.unreadMessageCount];
    
}

- (void)setUpUI
{
	self.backgroundColor = [UIColor clearColor];
    
    UIColor *labelColor = nil;
    UIColor *titleLabelColor = nil;
    UIColor *shadowColor = nil;
    
    labelColor = HEXCOLOR(0x666666FF);
    titleLabelColor = HEXCOLOR(0x333333FF);
    shadowColor = HEXCOLOR(0xFFFFFF33);
    
	nextY = 10.0;
    
    if (avatarImage == nil) avatarImage = [[[UIImageViewAsyncLoader alloc] initWithFrame:CGRectMake(leftMargin + 10, nextY, 50, 50)] autorelease];
    [self addSubview:avatarImage];
    
    float textLeftPos = leftMargin + 60 + 10;
    fieldWidth = 320 - textLeftPos - 45;
    
    if (labelCreator == nil) labelCreator = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
                                                                                       nextY, 
                                                                                       fieldWidth, 
                                                                                       17)] autorelease];
	labelCreator.textColor = labelColor;
	labelCreator.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelCreator.backgroundColor = [ UIColor clearColor ]; 
	labelCreator.lineBreakMode = UILineBreakModeWordWrap;
	labelCreator.numberOfLines = 0;
	[self addSubview:labelCreator];
    
	nextY = labelCreator.frame.origin.y + labelCreator.frame.size.height;
	
	if (labelTitle == nil) labelTitle = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
																	nextY, 
																	fieldWidth, 
																	22)] autorelease];
	labelTitle.textColor = titleLabelColor;
	labelTitle.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:18];
	labelTitle.shadowColor = shadowColor;
	labelTitle.shadowOffset = CGSizeMake(0.0, 1.0);
	labelTitle.backgroundColor = [ UIColor clearColor ]; 
	labelTitle.text = event.eventTitle;
	labelTitle.lineBreakMode = UILineBreakModeTailTruncation;
	labelTitle.numberOfLines = 0;
	[self addSubview:labelTitle];
    
	nextY = labelTitle.frame.origin.y + labelTitle.frame.size.height - 2;
	
	if (labelDate == nil) labelDate = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
																   nextY, 
																   fieldWidth, 
																   17)] autorelease];
	labelDate.textColor = labelColor;
	labelDate.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelDate.backgroundColor = [ UIColor clearColor ]; 
	labelDate.text = [event getFormattedDateString];
	[self addSubview:labelDate];
    
	nextY = labelDate.frame.origin.y + labelDate.frame.size.height;
	    
	self.frame = CGRectMake(self.frame.origin.x, 
							self.frame.origin.y, 
							self.frame.size.width, 
							nextY);
    
    UIImage *feedIcon = [UIImage imageNamed:@"icon_feed_green.png"];
    feedIconView = [[[UIImageView alloc] initWithImage:feedIcon] autorelease];
    feedIconView.frame = CGRectMake(272, 10, feedIcon.size.width, feedIcon.size.height);
    feedIconView.hidden = YES;
    [self addSubview:feedIconView];
    
    feedCountLabel = [[[UILabel alloc] init] autorelease];
    feedCountLabel.textAlignment = UITextAlignmentCenter;
    feedCountLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
    [feedCountLabel setBackgroundColor:[UIColor clearColor]];
    UIColor *col2 = HEXCOLOR(0xFFFFFFFF);
    [feedCountLabel setTextColor:col2];
    NSString *countCopy = [NSString stringWithFormat:@"%d", 99];
    [feedCountLabel setText:countCopy];
    [feedCountLabel sizeToFit];
    
    CGRect frame = feedCountLabel.bounds;
    frame.origin.x = 0;
    frame.origin.y = 2;
    frame.size.width = 20;
    feedCountLabel.frame = frame;
    [feedIconView addSubview:feedCountLabel];
    
    labelNewIndicator = [[[UILabel alloc] initWithFrame:CGRectMake(232, 11, 59, 14)] autorelease];
    labelNewIndicator.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:10];
    labelNewIndicator.textAlignment = UITextAlignmentRight;
    [labelNewIndicator setBackgroundColor:[UIColor clearColor]];
    [labelNewIndicator setTextColor:labelColor];
    [self addSubview:labelNewIndicator];
}

- (NSString *)urldecode:(NSString *)aString
{
	aString = [aString stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
	return aString;
}

- (void)dealloc {
    NSLog(@"SubViewEventInfo dealloc");
    [event release];
    event = nil;
    [super dealloc];
}


@end
