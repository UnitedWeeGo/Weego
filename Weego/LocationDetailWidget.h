//
//  LocationDetailWidget.h
//  BigBaby
//
//  Created by Nicholas Velloff on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocAnnotation.h"
#import "ReportedLocationAnnotation.h"
#import "UIImageViewAsyncLoader.h"

typedef enum {
	WidgetStateClosed = 0,
	WidgetStateOpen,
    WidgetStateOpenWithSearch
} WidgetState;
typedef enum {
	ActionStateAdd = 0,
    ActionStateSpinning,
	ActionStateLike,
    ActionStateUnlike
} ActionState;

@protocol LocationDetailWidgetDelegate
- (void)addButtonPressed;
- (void)likeButtonPressed;
- (void)unlikeButtonPressed;
- (void)winnerButtonPressed;
- (void)editNameButtonPressed;
//- (void)deleteLocationButtonPressed;
- (void)editNameSubmittedWithNewName:(NSString *)name;
- (void)userActionButtonPressedForParticipant:(Participant *)part;

@end

@interface LocationDetailWidget : UIView <UITextFieldDelegate> {
    UILabel *primaryInfoLabel;
    UILabel *secondaryInfoLabel;
    UILabel *distanceLabel;
    UITextField *editNameInput;
    UIButton *addButton;
    UIButton *likeButton;
    UIButton *unlikeButton;
    UIView *loading;
    UIActivityIndicatorView *activityView;
    UIView *errorView;
    UIButton *winnerButton;
    UIButton *userActionButton;
    UIButton *dealButton;
    UIButton *editNameButton;
    UIButton *clearTextButton;
    UIButton *getDirectionsButton;
//    UIButton *deleteLocationButton;
    WidgetState currentState;
    Boolean iAmShowing;
    LocAnnotation *currentAnnotation;
    ReportedLocationAnnotation *currentReportedLocationAnnotation;
    CGRect actionBtnRect;
    CGRect dealBtnRect;
    CGRect editNameBtnRect;
    int labelLeftPos;

    CGSize currentBaseInfoSize;
    UIImageView *dealImage;
    UIImageView *ratingImage;
    UILabel *reviewCountLabel;
    
    UIImageViewAsyncLoader *avatarImage;
    UIImageView *distanceIconView;
}

@property (readonly,assign) Boolean iAmShowing;
@property (readwrite,assign) Boolean hasDeal;
@property (nonatomic, copy) NSString *featureId;
@property (nonatomic,assign) id <LocationDetailWidgetDelegate> delegate;

- (void)updateInfoViewWithLocationAnnotation:(LocAnnotation *)annotation;
- (void)setState:(WidgetState)state withDelay:(float)delay;
- (void)updateInfoViewWithCorrectButtonState:(ActionState)actionState;
- (void)updateInfoViewWithReportedLocationAnnotation:(ReportedLocationAnnotation *)annotation;
- (void)transitionToEditNameState;
- (void)recoverFromEditNameState;
- (void)handleEditingNameSubmit;

@end