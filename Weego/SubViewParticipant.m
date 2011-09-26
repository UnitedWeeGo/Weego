//
//  SubViewParticipant.m
//  BigBaby
//
//  Created by Dave Prukop on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubViewParticipant.h"
#import "Event.h"
#import "SuggestedTime.h"
#import "NSDate+Helper.h"

@interface SubViewParticipant (Private)

- (void)setUpUI;

@end

@implementation SubViewParticipant

@synthesize participant;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setParticipant:(Participant *)aParticipant
{
    [participant release];
    participant = aParticipant;
    [participant retain];
    labelName.text = aParticipant.fullName;
    
    // set the status here    
    SuggestedTime *sugTime =  [[Model sharedInstance] getSuggestedTimeWithEmail:participant.email fromEventWithId:participant.ownerEventId];
    BOOL userSuggestedTime = sugTime != nil;
    
    BOOL isDetailsMode = [Model sharedInstance].currentAppState == AppStateEventDetails;
    AcceptanceType acceptanceStatus = [[Model sharedInstance].currentEvent acceptanceStatusForUserWithEmail:participant.email];
    
    labelStatus.text = @"";
    labelSuggestedTime.text = @"";
    
    NSString *formattedDate;
    if (userSuggestedTime)
    {
        NSDate *suggestedDate = [NSDate dateFromString:sugTime.suggestedTime withFormat:@"yyyy-MM-dd HH:mm:ss" timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        formattedDate = [suggestedDate stringWithFormat:@"'Suggests 'MMMM d 'at' h:mm a" timeZone:[NSTimeZone localTimeZone]];
        labelSuggestedTime.text = formattedDate;
    }
    
    if (acceptanceStatus == AcceptanceTypePending && isDetailsMode)
    {
        labelStatus.text = @"Pending";
    }
    else if (acceptanceStatus == AcceptanceTypeCheckedIn && isDetailsMode)
    {
        labelStatus.text = @"Checked in";
    }
    else if (acceptanceStatus == AcceptanceTypeAccepted && isDetailsMode)
    {
        // no messaging in labelStatus
    }
    else if (acceptanceStatus == AcceptanceTypeDeclined && isDetailsMode)
    {
        labelStatus.text = @"Count me out";
    }
    
    int targetYForLabelName = userSuggestedTime ? 10 : 17;
    CGRect newFrameName = labelName.frame;
    newFrameName.origin.y = targetYForLabelName;
    labelName.frame = newFrameName;
    
    CGRect newFrameStatus = labelStatus.frame;
    newFrameStatus.origin.y = targetYForLabelName;
    labelStatus.frame = newFrameStatus;
    
    NSURL *url = [NSURL URLWithString:participant.avatarURL];
    [avatarImage asyncLoadWithNSURL:url useCached:YES andBaseImage:BaseImageTypeAvatar useBorder:YES];
}

- (void)setUpUI
{
    self.backgroundColor = [UIColor clearColor];
    UIColor *labelColor = nil;
    UIColor *titleLabelColor = nil;
    
    labelColor = HEXCOLOR(0x999999FF);
    titleLabelColor = HEXCOLOR(0x333333FF);
    
    float leftMargin = 10;
    float nameLeftPos = leftMargin + 38;
    float nameFieldWidth = 165;
    
    float statusLeftPos = nameLeftPos + nameFieldWidth + 5;
    float statusFieldWidth = self.frame.size.width - statusLeftPos - 8;
    
    if (avatarImage == nil) avatarImage = [[[UIImageViewAsyncLoader alloc] initWithFrame:CGRectMake(leftMargin, 5, 32, 32)] autorelease];
    [self addSubview:avatarImage];

    if (labelName == nil) labelName = [[[UILabel alloc] initWithFrame:CGRectMake(nameLeftPos, 
                                                                                   17, 
                                                                                   nameFieldWidth, 
                                                                                   14)] autorelease];
	labelName.textColor = titleLabelColor;
	labelName.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
	labelName.backgroundColor = [ UIColor clearColor ]; 
	labelName.lineBreakMode = UILineBreakModeTailTruncation;
	labelName.numberOfLines = 0;
	[self addSubview:labelName];
    
    
    
    if (labelSuggestedTime == nil) labelSuggestedTime = [[[UILabel alloc] initWithFrame:CGRectMake(nameLeftPos, 
                                                                                     24, 
                                                                                     nameFieldWidth, 
                                                                                     14)] autorelease];
    labelSuggestedTime.textColor = labelColor;
	labelSuggestedTime.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelSuggestedTime.backgroundColor = [ UIColor clearColor ]; 
	labelSuggestedTime.lineBreakMode = UILineBreakModeTailTruncation;
	labelSuggestedTime.numberOfLines = 0;
	[self addSubview:labelSuggestedTime];
    
    
	if (labelStatus == nil) labelStatus = [[[UILabel alloc] initWithFrame:CGRectMake(statusLeftPos, 
                                                                                 17, 
                                                                                 statusFieldWidth, 
                                                                                 14)] autorelease];
	labelStatus.textColor = labelColor;
	labelStatus.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelStatus.backgroundColor = [ UIColor clearColor ]; 
    labelStatus.textAlignment = UITextAlignmentRight;
	[self addSubview:labelStatus];
    	
	self.frame = CGRectMake(self.frame.origin.x, 
							self.frame.origin.y, 
							self.frame.size.width, 
							45);
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
    [participant release];
    participant = nil;
    [super dealloc];
}

@end
