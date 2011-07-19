//
//  CellContact.m
//  BigBaby
//
//  Created by Dave Prukop on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellContact.h"

@interface CellContact (Private)

- (void)setUpUI;

@end


@implementation CellContact

@synthesize contact;
@synthesize participant;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setUpUI
{
    UIColor *titleLabelColor = nil;
    UIColor *emailLabelColor = nil;
    
    titleLabelColor = HEXCOLOR(0x333333FF);
    emailLabelColor = HEXCOLOR(0x666666FF);
    
    labelName = [[[UILabel alloc] initWithFrame:CGRectMake(8, 8, 230, 16)] autorelease];
	labelName.textColor = titleLabelColor;
	labelName.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
	labelName.shadowOffset = CGSizeMake(0.0, 1.0);
	labelName.backgroundColor = [ UIColor clearColor ]; 
	labelName.lineBreakMode = UILineBreakModeTailTruncation;
	labelName.numberOfLines = 0;
	[self addSubview:labelName];
    
    labelLabel = [[[UILabel alloc] initWithFrame:CGRectMake(8, 25, 230, 14)] autorelease];
	labelLabel.textColor = emailLabelColor;
	labelLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
	labelLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	labelLabel.backgroundColor = [ UIColor clearColor ]; 
	labelLabel.lineBreakMode = UILineBreakModeTailTruncation;
	labelLabel.numberOfLines = 0;
	[self addSubview:labelLabel];
        
    labelEmail = [[[UILabel alloc] initWithFrame:CGRectMake(8, 26, 230, 14)] autorelease];
	labelEmail.textColor = emailLabelColor;
	labelEmail.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelEmail.shadowOffset = CGSizeMake(0.0, 1.0);
	labelEmail.backgroundColor = [ UIColor clearColor ]; 
	labelEmail.lineBreakMode = UILineBreakModeTailTruncation;
	labelEmail.numberOfLines = 0;
	[self addSubview:labelEmail];

    separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    separator.backgroundColor = HEXCOLOR(0xCCCCCCFF);
    [self addSubview:separator];
    [separator release];
    
    if (avatarImage == nil) avatarImage = [[[UIImageViewAsyncLoader alloc] initWithFrame:CGRectMake(10, 5, 32, 32)] autorelease];
    [self addSubview:avatarImage];
    avatarImage.hidden = YES;
}

- (void)setContact:(Contact *)aContact
{
    avatarImage.hidden = YES;
    labelName.frame = CGRectMake(8, 8, 230, 16);
    labelName.text = aContact.contactName;
    NSString *label = [aContact.emailLabel stringByReplacingOccurrencesOfString:@"_$!<" withString:@""];
    label = [label stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
    CGSize labelSize = [label sizeWithFont:labelLabel.font];
    labelLabel.frame = CGRectMake(labelLabel.frame.origin.x, labelLabel.frame.origin.y, labelSize.width, labelSize.height);
    labelLabel.text = label;
    float left = labelLabel.frame.origin.x + labelLabel.frame.size.width + 5;
    labelEmail.frame = CGRectMake(left, 26, 320 - left, 14);
    labelEmail.text = aContact.emailAddress;
    separator.frame = CGRectMake(0, 43, 320, 1);
}

- (void)setParticipant:(Participant *)aParticipant
{
    float leftMargin = 10;
    float nameLeftPos = leftMargin + 38;
    float nameFieldWidth = 150;
    NSURL *url = [NSURL URLWithString:aParticipant.avatarURL];
    [avatarImage asyncLoadWithNSURL:url useCached:YES andBaseImage:BaseImageTypeAvatar useBorder:YES];
    avatarImage.hidden = NO;
    labelName.frame = CGRectMake(nameLeftPos, 15, nameFieldWidth, 16);
    labelName.text = aParticipant.fullName;
    labelEmail.text = @"";
    labelLabel.text = @"";
    separator.frame = CGRectMake(0, 43, 320, 1);
}

- (void)showAdded:(BOOL)hasBeenAdded
{
    if (hasBeenAdded) {
        labelName.alpha = 0.5;
        labelLabel.alpha = 0.5;
        labelEmail.alpha = 0.5;
        avatarImage.alpha = 0.5;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        labelName.alpha = 1;
        labelLabel.alpha = 1;
        labelEmail.alpha = 1;
        avatarImage.alpha = 1;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
