//
//  SubViewLabel.m
//  BigBaby
//
//  Created by Dave Prukop on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubViewLabel.h"

const float oXLabel = 19.0;
const float oYLabel = 10.0;
const float oWLabel = 282.0;

@implementation SubViewLabel


- (id)initWithText:(NSString *)text {
	return [self initWithFrame:CGRectMake(0, 0, 320, 44) andText:text];
}

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        UIColor *labelColor = nil;
        UIColor *shadowColor = nil;

        switch ([Model sharedInstance].currentBGState) {
            case BGStateHome :
                labelColor = HEXCOLOR(0xF5F5F5FF);
                shadowColor = HEXCOLOR(0x33333333);
                break;
            case BGStateEvent :
                labelColor = HEXCOLOR(0x787878FF);
                shadowColor = HEXCOLOR(0xFFFFFF33);
                break;
            default:
                break;
        }
        
		self.backgroundColor = [UIColor clearColor];
        label = [[UILabel alloc] initWithFrame:CGRectMake(oXLabel, oYLabel, oWLabel, 44)];
		label.textColor = labelColor;
		label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:17];
		label.shadowColor = shadowColor;
		label.shadowOffset = CGSizeMake(0.0, 1.0);
		label.backgroundColor = [ UIColor clearColor ]; 
		label.text = text;
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 0;
		[label sizeToFit];
		[self addSubview:label];
		[label release];
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, label.frame.origin.y + label.frame.size.height);
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
