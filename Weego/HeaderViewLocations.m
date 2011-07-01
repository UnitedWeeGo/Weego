//
//  HeaderViewLocations.m
//  BigBaby
//
//  Created by Dave Prukop on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HeaderViewLocations.h"
#import "SubViewLabel.h"

@interface HeaderViewLocations(Private)

- (void)setUpUI;
- (void) locDetail_Clicked:(id)sender;

@end

@implementation HeaderViewLocations

@synthesize delegate;
//seeMap;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI
{
	self.backgroundColor = [UIColor clearColor];
	
	NSString *title = @"Vote or add location";
	SubViewLabel *label = [[SubViewLabel alloc] initWithText:title];
	[self addSubview:label];
	[label release];
	
	seeMap = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[seeMap retain];
	seeMap.frame = CGRectMake(231, 8, 80, 30);
	[seeMap setTitle:@"See Map" forState:UIControlStateNormal];
	seeMap.titleLabel.textColor = [UIColor colorWithRed: 76/255.0 green: 86/255.0 blue: 108/255.0 alpha:1.0];
	[seeMap addTarget:self action:@selector(locDetail_Clicked:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:seeMap];
}

- (void) locDetail_Clicked:(id)sender
{
	NSLog(@"locDetail_Clicked");
	[delegate seeLocationsClicked];	
}

- (void)dealloc {
	self.delegate = nil;
	[seeMap release];
    [super dealloc];
}


@end
