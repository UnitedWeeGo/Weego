//
//  SubViewFeedMessage.m
//  BigBaby
//
//  Created by Nicholas Velloff on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubViewFeedMessage.h"
#import "Participant.h"
#import "Event.h"

@interface SubViewFeedMessage (Private)

- (void)setUpUI;
- (NSString *)urldecode:(NSString *)aString;

@end

@implementation SubViewFeedMessage

@synthesize feedMessage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setFeedMessage:(FeedMessage *)aFeedMessage
{    
    [feedMessage release];
    feedMessage = aFeedMessage;
    [feedMessage retain];
    
    Participant *participant;
    BOOL decidedFeedMessage = [aFeedMessage.type isEqualToString:@"decided"];
    BOOL inviteFeedMessage = [aFeedMessage.type isEqualToString:@"invite"];
    BOOL locationFeedMessage = [aFeedMessage.type isEqualToString:@"locationadd"];
    BOOL locationCheckinMessage = [aFeedMessage.type isEqualToString:@"checkin"];
    
    if (decidedFeedMessage)
    {
        Model *model = [Model sharedInstance];
        participant = [[[Participant alloc] init] autorelease];
        participant.firstName = @"Weego";
        participant.avatarURL = @"http://www.unitedweego.com/images/POIs_decided_default.png";

        Location *topLocation = [model.currentEvent getLocationByLocationId:model.currentEvent.topLocationId];
        feedMessage.message = [NSString stringWithFormat:@"\"%@\" is where we are going!", topLocation.name];
    }
    else
    {
        participant = [[Model sharedInstance] getParticipantWithEmail:aFeedMessage.senderId fromEventWithId:aFeedMessage.ownerEventId];
    }
    
    labelName.text = participant.fullName;
    labelDetail.text = [self urldecode:aFeedMessage.message];
    labelElapsedTime.text = aFeedMessage.friendlyTimestamp;
    
    float textLeftPos = 42 + 8;
    CGSize		textSize = { 200, FLT_MAX };// width and height of text area
    CGSize		messageCopySize = [aFeedMessage.message sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:12] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    
    labelDetail.frame = CGRectMake(textLeftPos, 
                                   25, 
                                   messageCopySize.width, 
                                   messageCopySize.height);
    // set frame
    //labelElapsedTime = [[[UILabel alloc] initWithFrame:CGRectMake(210, 12, 100, 14)] autorelease];
    
    newIconView.hidden = aFeedMessage.userReadMessage;
    
    int rightOffsetForTime = aFeedMessage.userReadMessage ? 0: 12;
    CGRect timeLabelFrame = CGRectMake(210-rightOffsetForTime, 12, 100, 14);
    labelElapsedTime.frame = timeLabelFrame;
    
    NSURL *url = [NSURL URLWithString:participant.avatarURL];
    
    checkIconView.hidden = !locationCheckinMessage;
    peopleIconView.hidden = !inviteFeedMessage;
    locationIconView.hidden = !locationFeedMessage;
    
    if (avatarImage != nil) [avatarImage removeFromSuperview];
    avatarImage = nil;
        
    avatarImage = [[[UIImageViewAsyncLoader alloc] init] autorelease];
    [self addSubview:avatarImage];
    
    if (decidedFeedMessage)
    {
        avatarImage.frame = CGRectMake(9, 8, 33.25, 37.05);
        [avatarImage asyncLoadWithNSURL:url useCached:YES andBaseImage:BaseImageTypeNone useBorder:NO];
    }
    else
    {
        avatarImage.frame = CGRectMake(10, 10, 32, 32);
        [avatarImage asyncLoadWithNSURL:url useCached:YES andBaseImage:BaseImageTypeAvatar useBorder:YES];
    }
     
}

- (void)setUpUI
{
    self.backgroundColor = [UIColor clearColor];
    
    float textLeftPos = 42 + 8;
    float fieldWidth = 200;
    
    if (labelName == nil) labelName = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
                                                                                 12, 
                                                                                 fieldWidth, 
                                                                                 14)] autorelease];
	labelName.textColor = HEXCOLOR(0x999999FF);
	labelName.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
	labelName.shadowOffset = CGSizeMake(0.0, 1.0);
	labelName.backgroundColor = [ UIColor clearColor ]; 
	labelName.lineBreakMode = UILineBreakModeTailTruncation;
	labelName.numberOfLines = 0;
	[self addSubview:labelName];
    
    if (labelDetail == nil) labelDetail = [[[UILabel alloc] init] autorelease]; // frame to be set later
	labelDetail.textColor = HEXCOLOR(0x333333FF);
	labelDetail.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelDetail.backgroundColor = [ UIColor clearColor ];
    labelDetail.lineBreakMode = UILineBreakModeWordWrap;
    labelDetail.numberOfLines = 0;
	[self addSubview:labelDetail];
    
    if (labelElapsedTime == nil) labelElapsedTime = [[[UILabel alloc] init] autorelease]; // frame to be reset later
	labelElapsedTime.textColor = HEXCOLOR(0x999999FF);
	labelElapsedTime.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelElapsedTime.backgroundColor = [ UIColor clearColor ];
    labelElapsedTime.textAlignment = UITextAlignmentRight;
	[self addSubview:labelElapsedTime];
    
    UIImage *newIcon = [UIImage imageNamed:@"icon_feed_new.png"];
    if (newIconView == nil) newIconView = [[[UIImageView alloc] initWithImage:newIcon] autorelease];
    newIconView.frame = CGRectMake(305, 13, newIcon.size.width, newIcon.size.height);
    [self addSubview:newIconView];
    
    UIImage *checkIcon = [UIImage imageNamed:@"icon_feed_checkin.png"];
    if (checkIconView == nil) checkIconView = [[[UIImageView alloc] initWithImage:checkIcon] autorelease];
    checkIconView.frame = CGRectMake(299, 26, checkIcon.size.width, checkIcon.size.height);
    checkIconView.hidden = YES;
    [self addSubview:checkIconView];
    
    UIImage *locationIcon = [UIImage imageNamed:@"icon_feed_places.png"];
    if (locationIconView == nil) locationIconView = [[[UIImageView alloc] initWithImage:locationIcon] autorelease];
    locationIconView.frame = CGRectMake(303, 26, locationIcon.size.width, locationIcon.size.height);
    locationIconView.hidden = YES;
    [self addSubview:locationIconView];
    
    UIImage *peopleIcon = [UIImage imageNamed:@"icon_feed_people.png"];
    if (peopleIconView == nil) peopleIconView = [[[UIImageView alloc] initWithImage:peopleIcon] autorelease];
    peopleIconView.frame = CGRectMake(296, 26, peopleIcon.size.width, peopleIcon.size.height);
    peopleIconView.hidden = YES;
    [self addSubview:peopleIconView];

}
/*
+ (int)calulateMyHeightWithMessageString:(NSString *)message
{
    int         fieldY = 25;
    int         bottomPadding = 10;
    CGSize		textSize = { 200, FLT_MAX };// width and height of text area
    CGSize		messageCopySize = [message sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:12] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    
    return MAX(fieldY + messageCopySize.height + bottomPadding, 52);
}
*/
+ (int)calulateMyHeightWithFeedMessage:(FeedMessage *)feedMessage
{
    int         fieldY = 25;
    int         bottomPadding = 10;
    CGSize		textSize = { 200, FLT_MAX };// width and height of text area
    BOOL        decidedFeedMessage = [feedMessage.type isEqualToString:@"decided"];
    
    NSString    *message;
    
    if (decidedFeedMessage)
    {
        Model *model = [Model sharedInstance];
        Location *topLocation = [model.currentEvent getLocationByLocationId:model.currentEvent.topLocationId];
        message = [NSString stringWithFormat:@"\"%@\" is where we are going!", topLocation.name];
    }
    else
    {
        message = feedMessage.message;
    }
    
    CGSize		messageCopySize = [message sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:12] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    return MAX(fieldY + messageCopySize.height + bottomPadding, 52);
}

- (void)dealloc
{
    [feedMessage release];
    feedMessage = nil;
    [super dealloc];
}

- (NSString *)urldecode:(NSString *)aString
{
	aString = [aString stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
	return aString;
}

@end
