//
//  CellParticipantsSummary.m
//  BigBaby
//
//  Created by Dave Prukop on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellParticipantsSummary.h"
#import "UIImageViewAsyncLoader.h"
#import "Participant.h"

@implementation CellParticipantsSummary

@synthesize numParticipants;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellParticipantsSummaryHeight;
        
        icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_people_dark_01.png"]];
        icon.frame = CGRectMake(10, 15, 21, 14);
        [self.contentView addSubview:icon];
        [icon release];
        
        labelNumParticipants = [[UILabel alloc] initWithFrame:CGRectMake(35, 15, 50, 14)];
        labelNumParticipants.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
        [labelNumParticipants setBackgroundColor:[UIColor clearColor]];
        UIColor *col2 = HEXCOLOR(0x666666FF);
        [labelNumParticipants setTextColor:col2];
//        NSString *countCopy = [NSString stringWithFormat:@"%d", 888];
//        [labelNumParticipants setText:countCopy];
        [self.contentView addSubview:labelNumParticipants];
        [labelNumParticipants release];
        
//        cellView = [[[SubViewParticipant alloc] initWithFrame:CGRectMake(0, 1, 300, 44)] autorelease];
//        [self.contentView addSubview:cellView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setNumParticipants:(NSString *)value
{
//    NSString *countCopy = [NSString stringWithFormat:@"%d", value];
    [labelNumParticipants setText:value];
    [labelNumParticipants sizeToFit];
}

- (void)setParticipants:(NSArray *)participants
{
    [labelNumParticipants setText:[[[NSString alloc] initWithFormat:@"%i", [participants count]] autorelease]];
    [labelNumParticipants sizeToFit];
    CGFloat left = 78;
    int i = 0;
    for (Participant *p in participants) {
        if (p.avatarURL && ![[p.avatarURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
            CGFloat leftPos = left + (i * 37);
            UIImageViewAsyncLoader *avatarImage = [[UIImageViewAsyncLoader alloc] initWithFrame:CGRectMake(leftPos, 7, 32, 32)];
            NSURL *url = [NSURL URLWithString:p.avatarURL];
            [avatarImage asyncLoadWithNSURL:url useCached:YES andBaseImage:BaseImageTypeAvatar useBorder:YES];
            [self addSubview:avatarImage];
            [avatarImage release];
            i++;
            if (i == 5) break;
        }
    }
}

@end
