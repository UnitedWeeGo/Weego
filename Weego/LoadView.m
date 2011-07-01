//
//  LoadView.m
//  BigBaby
//
//  Created by Nicholas Velloff on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadView.h"


@implementation LoadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *exitImage = [UIImage imageNamed:@"load_screen.png"];
        UIImageView  *exitView = [[[UIImageView alloc] initWithImage:exitImage] autorelease];
        [self addSubview:exitView];
                
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(frame.size.width/2 - 9.5, 150, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		[view release];
        
        [_activityView startAnimating];
    }
    return self;
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
    _activityView = nil;
    [super dealloc];
}

@end
