//
//  CellPrefsLoginParticipant.m
//  BigBaby
//
//  Created by Dave Prukop on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellPrefsLoginParticipant.h"

@interface CellPrefsLoginParticipant (Private)

- (void)setUpUI;

@end

@implementation CellPrefsLoginParticipant

@synthesize participant;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellPrefsLoginParticipantHeight;
        self.backgroundColor = [UIColor clearColor];
        
        leftMargin = 8;
        [self setUpUI];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.frame = CGRectMake(0, 0, 300, CellPrefsLoginParticipantHeight);
        
    
    }
    return self;
}

- (void)setParticipant:(Participant *)aParticipant
{
    NSURL *url = [NSURL URLWithString:aParticipant.avatarURL];
    [avatarImage asyncLoadWithNSURL:url useCached:YES andBaseImage:BaseImageTypeAvatar useBorder:YES];
    
    labelName.text = aParticipant.fullName;
    labelEmail.text = aParticipant.email;
//    labelPhone.text = @"000-000-0000";
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
    
    float textLeftPos = leftMargin + 60 + 6;
    fieldWidth = 320 - textLeftPos - 45;
    
    if (labelName == nil) labelName = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
                                                                                       nextY + 13, 
                                                                                       fieldWidth, 
                                                                                       16)] autorelease];
	labelName.textColor = titleLabelColor;
	labelName.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
	labelName.backgroundColor = [ UIColor clearColor ]; 
	labelName.lineBreakMode = UILineBreakModeWordWrap;
	labelName.numberOfLines = 0;
	[self addSubview:labelName];
    
	nextY = labelName.frame.origin.y + labelName.frame.size.height;
	
	if (labelEmail == nil) labelEmail = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
                                                                                   nextY, 
                                                                                   fieldWidth, 
                                                                                   14)] autorelease];
	labelEmail.textColor = labelColor;
	labelEmail.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelEmail.shadowColor = shadowColor;
	labelEmail.shadowOffset = CGSizeMake(0.0, 1.0);
	labelEmail.backgroundColor = [ UIColor clearColor ]; 
	labelEmail.lineBreakMode = UILineBreakModeTailTruncation;
	labelEmail.numberOfLines = 0;
	[self addSubview:labelEmail];
    
	nextY = labelEmail.frame.origin.y + labelEmail.frame.size.height;
	
//	if (labelPhone == nil) labelPhone = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
//                                                                                 nextY, 
//                                                                                 fieldWidth, 
//                                                                                 14)] autorelease];
//	labelPhone.textColor = labelColor;
//	labelPhone.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
//	labelPhone.backgroundColor = [ UIColor clearColor ]; 
//	[self addSubview:labelPhone];
//    
//	nextY = labelPhone.frame.origin.y + labelPhone.frame.size.height;
    
	self.frame = CGRectMake(self.frame.origin.x, 
							self.frame.origin.y, 
							self.frame.size.width, 
							nextY);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    [self.participant release];
    [super dealloc];
}

@end
