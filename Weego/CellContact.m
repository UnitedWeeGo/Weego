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
@synthesize disabled;
@synthesize checked;
@synthesize editing;

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
    labelName = [[[UILabel alloc] initWithFrame:CGRectMake(8, 8, 276, 16)] autorelease];
	labelName.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
	labelName.shadowOffset = CGSizeMake(0.0, 1.0);
	labelName.backgroundColor = [ UIColor clearColor ]; 
	labelName.lineBreakMode = UILineBreakModeTailTruncation;
	labelName.numberOfLines = 0;
	[self addSubview:labelName];
    
    labelLabel = [[[UILabel alloc] initWithFrame:CGRectMake(8, 25, 276, 14)] autorelease];
	labelLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
	labelLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	labelLabel.backgroundColor = [ UIColor clearColor ]; 
	labelLabel.lineBreakMode = UILineBreakModeTailTruncation;
	labelLabel.numberOfLines = 0;
	[self addSubview:labelLabel];
        
    labelSecondary = [[[UILabel alloc] initWithFrame:CGRectMake(8, 26, 276, 14)] autorelease];
	labelSecondary.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelSecondary.shadowOffset = CGSizeMake(0.0, 1.0);
	labelSecondary.backgroundColor = [ UIColor clearColor ]; 
	labelSecondary.lineBreakMode = UILineBreakModeTailTruncation;
	labelSecondary.numberOfLines = 0;
	[self addSubview:labelSecondary];
    
    labelTertiary = [[[UILabel alloc] initWithFrame:CGRectMake(8, 40, 276, 14)] autorelease];
	labelTertiary.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelTertiary.shadowOffset = CGSizeMake(0.0, 1.0);
	labelTertiary.backgroundColor = [ UIColor clearColor ]; 
	labelTertiary.lineBreakMode = UILineBreakModeTailTruncation;
	labelTertiary.numberOfLines = 0;
	[self addSubview:labelTertiary];

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
    labelName.frame = CGRectMake(8, 8, 276, 16);
    labelName.text = aContact.contactName;
    NSString *label = [aContact.emailLabel stringByReplacingOccurrencesOfString:@"_$!<" withString:@""];
    label = [label stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
    CGSize labelSize = [label sizeWithFont:labelLabel.font];
    labelLabel.frame = CGRectMake(labelLabel.frame.origin.x, labelLabel.frame.origin.y, labelSize.width, labelSize.height);
    labelLabel.text = label;
    float left = labelLabel.frame.origin.x + labelLabel.frame.size.width + 5;
    if ([[label stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) left = labelLabel.frame.origin.x;
    labelSecondary.frame = CGRectMake(left, 26, 284 - left, 14);
    labelSecondary.text = aContact.emailAddress;
    separator.frame = CGRectMake(0, 43, 320, 1);
    if (!aContact.isValid) {
        UIColor *errorLabelColor = HEXCOLOR(0xFF0000FF);
        labelName.textColor = errorLabelColor;
        labelLabel.textColor = errorLabelColor;
        labelSecondary.textColor = errorLabelColor;
    } else {
        UIColor *titleLabelColor = HEXCOLOR(0x333333FF);
        UIColor *emailLabelColor = HEXCOLOR(0x666666FF);
        labelName.textColor = titleLabelColor;
        labelLabel.textColor = emailLabelColor;
        labelSecondary.textColor = emailLabelColor;
    }
    if ([[aContact.contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) { //[aContact.emailAddress isEqualToString:aContact.contactName]
        labelName.frame = CGRectMake(8, 15, 230, 16);
        labelName.text = aContact.emailAddress;
        labelSecondary.text = @"";
        labelLabel.text = @"";
    }
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
    labelSecondary.text = @"";
    labelLabel.text = @"";
    separator.frame = CGRectMake(0, 43, 320, 1);
    UIColor *titleLabelColor = HEXCOLOR(0x333333FF);
    UIColor *emailLabelColor = HEXCOLOR(0x666666FF);
    labelName.textColor = titleLabelColor;
    labelLabel.textColor = emailLabelColor;
    labelSecondary.textColor = emailLabelColor;
}

- (void)setContactForLocations:(Contact *)aContact
{
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    avatarImage.hidden = YES;
    labelName.frame = CGRectMake(8, 8, 230, 16);
    labelName.text = aContact.contactName;
//    NSString *label = [aContact.addressLabel stringByReplacingOccurrencesOfString:@"_$!<" withString:@""];
//    label = [label stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
//    CGSize labelSize = [label sizeWithFont:labelLabel.font];
//    labelLabel.frame = CGRectMake(8, 25, labelSize.width, labelSize.height);
//    labelLabel.text = label;
//    float left = labelLabel.frame.origin.x + labelLabel.frame.size.width + 5;
//    if (!aContact.addressLabel || [[label stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) left = labelLabel.frame.origin.x;
    labelSecondary.frame = CGRectMake(8, 26, 284, 14);
    labelSecondary.text = aContact.addressLine1;
    labelTertiary.frame = CGRectMake(8, 42, 284, 14);
    labelTertiary.text = aContact.addressLine2;
    separator.frame = CGRectMake(0, 59, 320, 1);
    UIColor *titleLabelColor = HEXCOLOR(0x333333FF);
    UIColor *emailLabelColor = HEXCOLOR(0x666666FF);
    labelName.textColor = titleLabelColor;
    labelLabel.textColor = emailLabelColor;
    labelSecondary.textColor = emailLabelColor;
    labelTertiary.textColor = emailLabelColor;
    if (!aContact.contactName) {
//        labelLabel.frame = CGRectMake(labelLabel.frame.origin.x, 15, labelLabel.frame.size.width, labelLabel.frame.size.height);
        labelSecondary.frame = CGRectMake(labelSecondary.frame.origin.x, 16, labelSecondary.frame.size.width, labelSecondary.frame.size.height);
        labelTertiary.frame = CGRectMake(labelTertiary.frame.origin.x, 32, labelTertiary.frame.size.width, labelTertiary.frame.size.height);
    }
}

- (void)showAdded:(BOOL)hasBeenAdded
{
    if (hasBeenAdded) {
        labelName.alpha = 1;
        labelLabel.alpha = 1;
        labelSecondary.alpha = 1;
        avatarImage.alpha = 1;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
    } else {
        labelName.alpha = 1;
        labelLabel.alpha = 1;
        labelSecondary.alpha = 1;
        avatarImage.alpha = 1;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)showDisabled:(BOOL)hasBeenDisabled
{
    self.disabled = hasBeenDisabled;
    if (hasBeenDisabled) {
        labelName.alpha = 0.5;
        labelLabel.alpha = 0.5;
        labelSecondary.alpha = 0.5;
        avatarImage.alpha = 0.5;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        self.accessoryType = UITableViewCellAccessoryNone;
    } else {
        labelName.alpha = 1;
        labelLabel.alpha = 1;
        labelSecondary.alpha = 1;
        avatarImage.alpha = 1;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
//        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)showChecked:(BOOL)hasBeenChecked
{
    self.checked = hasBeenChecked;
    if (self.checked) {
//        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
//        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)toggleChecked
{
    self.checked = !self.checked;
    if (self.checked) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
