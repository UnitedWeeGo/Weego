//
//  LocationDetailWidget.m
//  BigBaby
//
//  Created by Nicholas Velloff on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationDetailWidget.h"
#import "Event.h"
#import "Location.h"

@interface LocationDetailWidget ()
- (void)setupInfoView;
- (void)addButtonPressed;
- (void)createAddButton;
- (void)createLikeButton;
- (void)createUnlikeButton;
- (void)createLoadingView;
- (void)createErrorView;
- (void)createDealButton;
- (void)createWinnerButton;
- (void)createEditNameButton;
- (void)createClearTextButton;
- (void)enableActionButton:(UIButton *)button;
- (void)disableAllButtons;
- (NSString *)urldecode:(NSString *)aString;
- (void)showDealButton;
- (void)showEditNameButton;
- (NSString *)friendlyDistanceBetweenPoint:(CLLocationCoordinate2D)pt1 andPoint:(CLLocationCoordinate2D)pt2;
- (void)createUserActionButton;
- (void)createEditInputField;
//- (void)createDeleteLocationButton;

- (void)showLoading;
- (void)showError;

// remove these later
- (void)showDeal;
- (void)hideDeal;
- (void)hideDealImage;
@end

@implementation LocationDetailWidget

@synthesize iAmShowing, delegate, hasDeal, featureId;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        iAmShowing = false;
        actionBtnRect = CGRectMake(5, 3, 52, 52);
        dealBtnRect = CGRectMake(286, 20, 28, 28);
        editNameBtnRect = CGRectMake(286, 7, 28, 28); 
        [self setupInfoView];
        [self createAddButton];
        [self createLikeButton];
        [self createUnlikeButton];
        [self createWinnerButton];
        [self createDealButton];
        [self createEditNameButton];
        [self createUserActionButton];
        [self createLoadingView];
        [self createErrorView];
        [self createEditInputField];
        [self createClearTextButton];
//        [self createDeleteLocationButton];
    }
    return self;
}

- (void)setState:(WidgetState)state withDelay:(float)delay
{
    [self hideDealImage];
    
    float yLoc;
    switch (state) {
        case WidgetStateClosed:
            iAmShowing = false;
            yLoc = -self.bounds.size.height;
            break;
        case WidgetStateOpen:
            iAmShowing = true;
            yLoc = 0;
            break;
        case WidgetStateOpenWithSearch:
            iAmShowing = true;
            yLoc = 41; // to account for search bar
            break;
        default:
            break;
    }
    CGRect infoViewBGRect = CGRectMake(0, yLoc, currentBaseInfoSize.width, currentBaseInfoSize.height);
    CGRect leftButtonRect = CGRectMake(addButton.frame.origin.x, ceilf((infoViewBGRect.size.height - addButton.frame.size.height)/2), addButton.frame.size.width, addButton.frame.size.height);
    CGRect dealRect = CGRectMake(286, ceilf(infoViewBGRect.size.height - 38), 28, 28);
    
    [UIView animateWithDuration:0.30f 
                        delay:delay 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         self.frame = infoViewBGRect;
                         addButton.frame = leftButtonRect;
                         likeButton.frame = leftButtonRect;
                         unlikeButton.frame = leftButtonRect;
                         winnerButton.frame = leftButtonRect;
                         dealButton.frame = dealRect;
                     }
                     completion:NULL];
    currentState = state;
}

- (void)setupInfoView
{        
    labelLeftPos = 65;
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:.7];
    
    UIFont *primaryFont = [UIFont fontWithName:@"MyriadPro-Regular" size:18];
    UIFont *secondaryFont = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
    UIFont *distanceFont = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
    
    // Labels
    CGRect labelStart = CGRectMake(labelLeftPos, 12, 10, 10);
    CGRect distanceLabelStart = CGRectMake(195, 12, 100, 14);
    
    primaryInfoLabel = [[[UILabel alloc] initWithFrame:labelStart] autorelease];
    primaryInfoLabel.backgroundColor = [UIColor clearColor];
    primaryInfoLabel.textColor = [UIColor whiteColor];
    [primaryInfoLabel setFont:primaryFont];
    primaryInfoLabel.lineBreakMode = UILineBreakModeWordWrap; 
    primaryInfoLabel.numberOfLines = 0;
    
    secondaryInfoLabel = [[[UILabel alloc] initWithFrame:labelStart] autorelease];
    secondaryInfoLabel.backgroundColor = [UIColor clearColor];
    secondaryInfoLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
    [secondaryInfoLabel setFont:secondaryFont];
    secondaryInfoLabel.lineBreakMode = UILineBreakModeWordWrap; 
    secondaryInfoLabel.numberOfLines = 0;
    
    distanceLabel = [[[UILabel alloc] initWithFrame:distanceLabelStart] autorelease];
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
    [distanceLabel setFont:distanceFont];
    distanceLabel.textAlignment = UITextAlignmentRight;
    distanceLabel.numberOfLines = 0;
    
    [self addSubview:primaryInfoLabel];
    [self addSubview:secondaryInfoLabel];
    [self addSubview:distanceLabel];
    
    CGRect infoViewBGRect = CGRectMake(0, -50, self.bounds.size.width, 50);
    [self setFrame:infoViewBGRect];
    

    UIColor *labelColor = nil;
    labelColor = HEXCOLOR(0x666666FF);
    
    UIImage *distanceIcon = [UIImage imageNamed:@"icon_locationPOI_activityfeed_01.png"];
    distanceIconView = [[[UIImageView alloc] initWithImage:distanceIcon] autorelease];
    distanceIconView.frame = CGRectMake(300, 11, distanceIcon.size.width, distanceIcon.size.height);
    distanceIconView.hidden = YES;
    [self addSubview:distanceIconView];

}

- (void)createUserActionButton
{
    userActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    userActionButton.backgroundColor = [UIColor clearColor];
    userActionButton.hidden = YES;
    [userActionButton addTarget:self action:@selector(userActionButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:userActionButton];
}

- (void)createAddButton
{
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = actionBtnRect;
    addButton.hidden = YES;
    [addButton setImage:[UIImage imageNamed:@"button_add_annotation_default.png"] forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"button_add_annotation_pressed.png"] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(addButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:addButton];
}

- (void)createLikeButton
{
    likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    likeButton.frame = actionBtnRect;
    likeButton.hidden = YES;
	[likeButton setImage:[UIImage imageNamed:@"button_like_annonation_default.png"] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageNamed:@"button_like_annonation_pressed.png"] forState:UIControlStateHighlighted];
    [likeButton addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:likeButton];
}

- (void)createUnlikeButton
{
    unlikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    unlikeButton.frame = actionBtnRect;
    unlikeButton.hidden = YES;
	[unlikeButton setImage:[UIImage imageNamed:@"button_unlike_annonation_default.png"] forState:UIControlStateNormal];
    [unlikeButton setImage:[UIImage imageNamed:@"button_unlike_annonation_pressed.png"] forState:UIControlStateHighlighted];
    [unlikeButton addTarget:self action:@selector(unlikeButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:unlikeButton];
}

- (void)createLoadingView
{
    loading = [[UIView alloc] initWithFrame:actionBtnRect];
    loading.hidden = YES;
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_like_pressed.png"]];
    [loading addSubview:bg];
    [bg release];
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = actionBtnRect = CGRectMake(12, 12, 25, 25);
    [loading addSubview:activityView];
    [activityView release];
    [self addSubview:loading];
    [loading release];
}

- (void)createErrorView
{
    errorView = [[UIView alloc] initWithFrame:actionBtnRect];
    errorView.hidden = YES;
    //    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_like_pressed.png"]];
    //    [errorView addSubview:bg];
    //    [bg release];
    UIImageView *errorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_error.png"]];
    errorImage.frame = CGRectMake(17, 17, 16, 16);
    [errorView addSubview:errorImage];
    [errorImage release];
    [self addSubview:errorView];
    [errorView release];
}

- (void)createWinnerButton
{
    winnerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    winnerButton.frame = actionBtnRect;
    winnerButton.hidden = YES;
	[winnerButton setImage:[UIImage imageNamed:@"button_decided_annonation.png"] forState:UIControlStateNormal];
    [winnerButton setImage:[UIImage imageNamed:@"button_decided_annonation.png"] forState:UIControlStateHighlighted];
    [winnerButton addTarget:self action:@selector(winnerButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:winnerButton];
}

- (void)createDealButton
{
    dealButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dealButton.hidden = YES;
    dealButton.adjustsImageWhenHighlighted = NO;
    dealButton.frame = dealBtnRect;
    [dealButton setImage:[UIImage imageNamed:@"button_deal_dark_default.png"] forState:UIControlStateNormal];
    [dealButton setImage:[UIImage imageNamed:@"button_deal_dark_pressed.png"] forState:UIControlStateHighlighted];
    [dealButton setImage:[UIImage imageNamed:@"button_deal_dark_pressed.png"] forState:UIControlStateDisabled];
    [dealButton addTarget:self action:@selector(dealButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:dealButton];
}

- (void)enableActionButton:(UIButton *)button
{
    addButton.hidden = likeButton.hidden = unlikeButton.hidden = winnerButton.hidden = YES;
    button.hidden = NO;
    button.enabled = YES;
}

- (void)disableAllButtons
{
    addButton.hidden = likeButton.hidden = unlikeButton.hidden = YES;
    
}

- (void)userActionButtonPressed
{
    [delegate userActionButtonPressedForParticipant:currentReportedLocationAnnotation.participant];
}

- (void)addButtonPressed
{
    [delegate addButtonPressed];
}
- (void)likeButtonPressed
{
    [delegate likeButtonPressed];
}
- (void)unlikeButtonPressed
{
    [delegate unlikeButtonPressed];
}
- (void)winnerButtonPressed
{
    [delegate winnerButtonPressed];
}
- (void)editNameButtonPressed
{
    [delegate editNameButtonPressed];
}
- (void)deleteLocationButtonPressed
{
//    [delegate deleteLocationButtonPressed];
}

- (void)dealButtonPressed
{
    [[ViewController sharedInstance] showDeal:self.featureId];
//    [self showDeal];
}

- (void)showDealButton
{
    //NSLog(@"showDealButton? -- hasDeal:%d", self.hasDeal);
    if (self.hasDeal) dealButton.hidden = NO;
    else dealButton.hidden = YES;
}

- (void)showEditNameButton
{
    BOOL liveEvent = [Model sharedInstance].currentEvent.currentEventState < EventStateDecided;
    if (currentAnnotation.isAddress && currentAnnotation.iAddedLocation && liveEvent) editNameButton.hidden = NO;
    else editNameButton.hidden = YES;
}

- (void)hideDealImage
{
    if (dealImage)  
    {
        [dealImage removeFromSuperview];
        [self showDealButton];
        dealImage = nil;
    }
}

- (void)showDeal
{
    dealButton.hidden = YES;
    CGRect infoViewBGRect = CGRectMake(0, self.frame.origin.y, self.frame.size.width, [UIScreen mainScreen].bounds.size.height);
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         [self setFrame:infoViewBGRect];
                     }
                     completion:NULL];
    dealImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deal_01.png"]] autorelease];
    dealImage.alpha = 0;
    CGRect dealRect = CGRectMake((self.frame.size.width - dealImage.frame.size.width)/2, currentBaseInfoSize.height, dealImage.image.size.width, dealImage.image.size.height);
    dealImage.frame = dealRect;
    
    [self addSubview:dealImage];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(dealImage.frame.size.width - 44,
                                   16, 
                                   32, 
                                   32);
    closeButton.backgroundColor = HEXCOLOR(0x00FF0000);
    [closeButton addTarget:self action:@selector(hideDeal) forControlEvents:UIControlEventTouchUpInside];
    [dealImage addSubview:closeButton];
    [dealImage bringSubviewToFront:closeButton];
    [dealImage setUserInteractionEnabled:YES];
    [UIView animateWithDuration:0.30f 
                          delay:0.30f 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         dealImage.alpha = 1;
                     }
                     completion:NULL];
}

- (void)hideDeal
{
    [self hideDealImage];
    int yLoc = currentState == WidgetStateOpen ? 0 : 41;
    CGRect infoViewBGRect = CGRectMake(0, yLoc, currentBaseInfoSize.width, currentBaseInfoSize.height);
    
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         [self setFrame:infoViewBGRect];
                     }
                     completion:NULL];
}

- (void)updateInfoViewWithCorrectButtonState:(ActionState)actionState
{
    switch (actionState) {
        case ActionStateAdd:
            [self enableActionButton:addButton];
            break;
        case ActionStateSpinning:
            addButton.enabled = NO;
            break;
        case ActionStateLike:
            [self enableActionButton:likeButton];
            break;
        case ActionStateUnlike:
            [self enableActionButton:unlikeButton];
            break;
        default:
            break;
    }
}

- (void)showLoading
{
    likeButton.hidden = YES;
    unlikeButton.hidden = YES;
    loading.hidden = NO;
    [activityView startAnimating];
}

- (void)showError
{
    loading.hidden = YES;
    [activityView stopAnimating];
//    [self showLikeUnlike];
    errorView.hidden = NO;
    [self performSelector:@selector(hideError) withObject:nil afterDelay:5.0];
}

- (void)hideError
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         errorView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         errorView.hidden = YES;
                         errorView.alpha = 1;
                     }];
}

#pragma mark public methods
- (void)updateInfoViewWithReportedLocationAnnotation:(ReportedLocationAnnotation *)annotation
{
    Model *model = [Model sharedInstance];
    UIFont *primaryFont = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
    UIFont *secondaryFont = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
    
    labelLeftPos = 50;
    dealButton.hidden = YES;
    editNameButton.hidden = YES;
    winnerButton.hidden = YES;
    distanceIconView.hidden = NO;
    
    currentReportedLocationAnnotation = nil;
    currentReportedLocationAnnotation = annotation;
    
    CGRect      bounds = [UIScreen mainScreen].bounds;
    CGFloat		width = 210;
    CGSize		textSize = { width, FLT_MAX };
    
    NSString *titleCopy = [self urldecode:annotation.title];
    NSString *subTitleCopy = [self urldecode:annotation.subtitle];
    
    CGSize		primaryCopySize = [titleCopy sizeWithFont:primaryFont constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    CGSize		secondaryCopySize = [subTitleCopy sizeWithFont:secondaryFont constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];

    int targetHeight = 20+primaryCopySize.height+secondaryCopySize.height;
    CGFloat yLoc = (currentState == WidgetStateOpenWithSearch) ? 41 : 0;
    CGRect infoViewBGRect = CGRectMake(0, (iAmShowing)? yLoc : yLoc-targetHeight , bounds.size.width, targetHeight); // 35 is padding
    currentBaseInfoSize = infoViewBGRect.size;
    
    CGRect primaryInfoLabelRect = CGRectMake(labelLeftPos, 12, width, primaryCopySize.height);
    [primaryInfoLabel setText:titleCopy];
    [primaryInfoLabel setFont:primaryFont];
    
    CGRect secondaryInfoLabelRect = CGRectMake(labelLeftPos, primaryInfoLabelRect.size.height+10, width, secondaryCopySize.height);
    [secondaryInfoLabel setText:subTitleCopy];
    [secondaryInfoLabel setFont:secondaryFont];
    
    CLLocationCoordinate2D pt1 = annotation.coordinate;
    Location *winningLoc = [model.currentEvent getLocationByLocationId:model.currentEvent.topLocationId];
    CLLocationCoordinate2D pt2 = winningLoc.coordinate;
    [distanceLabel setText:[self friendlyDistanceBetweenPoint:pt1 andPoint:pt2]];
    distanceLabel.hidden = NO;
    
    [self disableAllButtons];
    
    // user avatar
    if (avatarImage) [avatarImage removeFromSuperview];
    avatarImage = nil;
    avatarImage = [[[UIImageViewAsyncLoader alloc] initWithFrame:CGRectMake(10, 10, 32, 32)] autorelease];
    [avatarImage asyncLoadWithNSURL:[NSURL URLWithString:annotation.participant.avatarURL] useCached:YES andBaseImage:BaseImageTypeAvatar useBorder:YES];
    avatarImage.alpha = 0;
    [self addSubview:avatarImage];
    
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         self.frame = infoViewBGRect;
                         userActionButton.frame = infoViewBGRect;
                         primaryInfoLabel.frame = primaryInfoLabelRect;
                         secondaryInfoLabel.frame = secondaryInfoLabelRect;
                         avatarImage.alpha = 1;
                     }
                     completion:NULL];
    userActionButton.hidden = NO;
}

- (NSString *)friendlyDistanceBetweenPoint:(CLLocationCoordinate2D)pt1 andPoint:(CLLocationCoordinate2D)pt2
{
    CLLocation *loc1 = [[[CLLocation alloc] initWithLatitude:pt1.latitude longitude:pt1.longitude] autorelease];
    CLLocation *loc2 = [[[CLLocation alloc] initWithLatitude:pt2.latitude longitude:pt2.longitude] autorelease];
    CLLocationDistance distance = [loc1 distanceFromLocation:loc2];
    float feet = distance * 3.2808399;
    int miles = floor(feet/5280);
    if (miles > 0) return [NSString stringWithFormat:@"%0.1f miles", feet/5280];
    
    return [NSString stringWithFormat:@"%0.0f feet", floor(feet)];
}

- (void)updateInfoViewWithLocationAnnotation:(LocAnnotation *)annotation
{
    // Use these if we enable delete in the map view
    //Model *model = [Model sharedInstance];
    //EventState cState = model.currentEvent.currentEventState;
    //BOOL locationAdded = [annotation getStateType] == LocAnnoStateTypePlace || [annotation getStateType] == LocAnnoStateTypeLiked;
    //BOOL locationEligibleForDeletion = cState < EventStateDecided && annotation.iAddedLocation && locationAdded;
    
    self.hasDeal = annotation.hasDeal;
    self.featureId = annotation.featureId;
    if (avatarImage) [avatarImage removeFromSuperview];
    avatarImage = nil;
    distanceLabel.hidden = YES;
    distanceIconView.hidden = YES;
    userActionButton.hidden = YES;
    
    UIFont *primaryFont = [UIFont fontWithName:@"MyriadPro-Regular" size:18];
    UIFont *secondaryFont = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
    
    labelLeftPos = 65; // push copy to the right if needed
    
    currentAnnotation = nil;
    currentAnnotation = annotation;
    
    [self hideDealImage];
    
    CGRect      bounds = [UIScreen mainScreen].bounds;
    CGFloat		width = 210; //210 if button showing -- 267 if not
    CGSize		textSize = { width, FLT_MAX };		// width and height of text area
    
    NSString *titleCopy = [self urldecode:annotation.title];
    NSString *formatted_address = [self urldecode:annotation.subtitle];
    NSString *subTitleCopy;
    if ([formatted_address rangeOfString:@","].location == NSNotFound)
    {
        subTitleCopy = [self urldecode:annotation.subtitle];
    }
    else
    {
        int commaLoc = [formatted_address rangeOfString:@","].location;
        NSString *labelSecondaryInfoS = [formatted_address substringWithRange:NSMakeRange(0, commaLoc)];
        NSString *labelTertiaryInfoS = [formatted_address substringWithRange:NSMakeRange(commaLoc+2, [formatted_address length]-commaLoc-2)];
        subTitleCopy = [NSString stringWithFormat:@"%@\n%@", labelSecondaryInfoS, labelTertiaryInfoS];
    }
    
    
    CGSize		primaryCopySize = [titleCopy sizeWithFont:primaryFont constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    CGSize		secondaryCopySize = [subTitleCopy sizeWithFont:secondaryFont constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    
    int targetHeight = MAX(22+primaryCopySize.height+secondaryCopySize.height, 70);
    CGRect infoViewBGRect = CGRectMake(0, (iAmShowing)?(0):( -(targetHeight) ), bounds.size.width, targetHeight); // 35 is padding
    currentBaseInfoSize = infoViewBGRect.size;
    
    CGRect primaryInfoLabelRect = CGRectMake(labelLeftPos, 16, width, primaryCopySize.height);
    [primaryInfoLabel setText:titleCopy];
    [primaryInfoLabel setFont:primaryFont];
    
    CGRect secondaryInfoLabelRect = CGRectMake(labelLeftPos, primaryInfoLabelRect.size.height+14, width, secondaryCopySize.height);
    [secondaryInfoLabel setText:subTitleCopy];
    [secondaryInfoLabel setFont:secondaryFont];
    
    CGRect leftButtonRect = CGRectMake(addButton.frame.origin.x, ceilf((infoViewBGRect.size.height - addButton.frame.size.height)/2), addButton.frame.size.width, addButton.frame.size.height);
    CGRect dealRect = CGRectMake(286, ceilf(infoViewBGRect.size.height - 38), 28, 28);
    CGRect editNameRect = CGRectMake(286, 10, 28, 28);
    
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         self.frame = infoViewBGRect;
                         primaryInfoLabel.frame = primaryInfoLabelRect;
                         secondaryInfoLabel.frame = secondaryInfoLabelRect;
                         addButton.frame = leftButtonRect;
                         likeButton.frame = leftButtonRect;
                         unlikeButton.frame = leftButtonRect;
                         winnerButton.frame = leftButtonRect;
                         dealButton.frame = dealRect;
                         editNameButton.frame = editNameRect;
                     }
                     completion:NULL];
    
    [self disableAllButtons];
    
    BOOL liveEvent = [Model sharedInstance].currentEvent.currentEventState < EventStateDecided;
    
    if ([annotation getStateType] == LocAnnoStateTypeSearch)
    {
        [self enableActionButton:addButton];
    } 
    else if ([annotation getStateType] == LocAnnoStateTypePlace)
    {
        [self enableActionButton:likeButton];
        if (!liveEvent) likeButton.enabled = NO;
    }
    else if ([annotation getStateType] == LocAnnoStateTypeLiked)
    {
        [self enableActionButton:unlikeButton];
        if (!liveEvent) unlikeButton.enabled = NO;
    }
    else if ([annotation getStateType] == LocAnnoStateTypeDecided)
    {
        [self enableActionButton:winnerButton];
    }
    
    [self showDealButton];
    [self showEditNameButton];
}

#pragma mark utils

- (NSString *)urldecode:(NSString *)aString
{
	aString = [aString stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
	return aString;
}


#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{
    if ([string isEqualToString:@"\n"]) {
        [self handleEditingNameSubmit];
        return FALSE;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    clearTextButton.alpha = newLength > 0 ? 1 : 0;
    return (newLength > 50) ? NO : YES;
}

#pragma mark editing name methods
- (void)createEditInputField
{
    editNameInput = [[[UITextField alloc] initWithFrame:CGRectMake(10, 10, 275, 20)] autorelease];
    editNameInput.alpha = 0;
    editNameInput.keyboardType = UIKeyboardTypeDefault;
    editNameInput.delegate = self;
    editNameInput.backgroundColor = [UIColor clearColor];
    editNameInput.textColor = HEXCOLOR(0xFFFFFFFF);
	editNameInput.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18];
    editNameInput.returnKeyType = UIReturnKeyDone;
    
    [self addSubview:editNameInput];
}

- (void)createEditNameButton
{
    editNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editNameButton.frame = editNameBtnRect;
    editNameButton.adjustsImageWhenHighlighted = NO;
    editNameButton.hidden = YES;
    [editNameButton setImage:[UIImage imageNamed:@"button_edit_dark_default.png"] forState:UIControlStateNormal];
    [editNameButton setImage:[UIImage imageNamed:@"button_edit_dark_pressed.png"] forState:UIControlStateHighlighted];
    [editNameButton addTarget:self action:@selector(editNameButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:editNameButton];
}

- (void)createClearTextButton
{
    clearTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearTextButton.frame = editNameBtnRect;
    clearTextButton.adjustsImageWhenHighlighted = NO;
    clearTextButton.alpha = 0;
    [clearTextButton setImage:[UIImage imageNamed:@"icon_clearTextField_02.png"] forState:UIControlStateNormal];
    [clearTextButton addTarget:self action:@selector(clearTextButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:clearTextButton];
}
/*
- (void)createDeleteLocationButton
{
    deleteLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteLocationButton.frame = editNameBtnRect;
    deleteLocationButton.adjustsImageWhenHighlighted = NO;
    deleteLocationButton.alpha = 0;
    [deleteLocationButton setImage:[UIImage imageNamed:@"icon_remove_default.png"] forState:UIControlStateNormal];
    [deleteLocationButton addTarget:self action:@selector(deleteLocationButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [self addSubview:deleteLocationButton];
}
*/

- (void)clearTextButtonPressed
{
    editNameInput.text = @"";
    clearTextButton.alpha = 0;
}

- (void)transitionToEditNameState
{
    // hide any action buttons
    primaryInfoLabel.alpha = secondaryInfoLabel.alpha = editNameButton.alpha = 0;
    addButton.alpha = likeButton.alpha = unlikeButton.alpha = winnerButton.alpha = 0;
    editNameInput.text = currentAnnotation.title;
    [editNameInput becomeFirstResponder];
    CGRect infoViewBGRect = CGRectMake(0, 0, self.bounds.size.width, 40);
    [UIView animateWithDuration:0.30f
                          delay:0
                        options:(UIViewAnimationOptionBeginFromCurrentState)
                     animations:^(void){
                         self.frame = infoViewBGRect;
                         editNameInput.alpha = 1;
                         clearTextButton.alpha = 1;
                     }
                     completion:NULL];
}

- (void)recoverFromEditNameState
{
    [editNameInput resignFirstResponder];
    editNameInput.alpha = 0;
    clearTextButton.alpha = 0;
    // restore any action buttons
    [self updateInfoViewWithLocationAnnotation:currentAnnotation];
    [UIView animateWithDuration:0.30f
                          delay:0.30f
                        options:(UIViewAnimationOptionBeginFromCurrentState)
                     animations:^(void){
                         primaryInfoLabel.alpha = 1;
                         secondaryInfoLabel.alpha = 1;
                         primaryInfoLabel.alpha = secondaryInfoLabel.alpha = editNameButton.alpha = 1;
                         addButton.alpha = likeButton.alpha = unlikeButton.alpha = winnerButton.alpha = 1;
                     }
                     completion:NULL];
}

- (void)handleEditingNameSubmit
{
    if ([editNameInput.text length] == 0) return;
    NSLog(@"handleEditingNameSubmit");
    currentAnnotation.title = editNameInput.text;
    [delegate editNameSubmittedWithNewName:editNameInput.text];
    [self recoverFromEditNameState];
    [self setState:WidgetStateOpenWithSearch withDelay:0];
}

- (void)dealloc
{
    currentAnnotation = nil;
    delegate = nil;
    [self.featureId release];
    [super dealloc];
}

@end
