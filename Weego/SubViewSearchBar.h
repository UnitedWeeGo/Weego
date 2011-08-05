//
//  SubViewContactsSearchBar.h
//  Weego
//
//  Created by Dave Prukop on 7/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SubViewSearchBarDelegate <NSObject>

- (void)searchBar:(id)searchBar textDidChange:(NSString *)searchText;
- (void)searchBarBookmarkButtonClicked:(id)searchBar;
- (void)searchBarClearButtonClicked:(id)searchBar;
- (void)searchBarCancelButtonClicked:(id)searchBar;
- (void)searchBarReturnButtonClicked:(id)searchBar;

@optional
- (void)searchBarTextDidBeginEditing:(id)searchBar;
- (void)searchBarTextDidEndEditing:(id)searchBar;
- (BOOL)searchBarShouldBeginEditing:(id)searchBar;
- (BOOL)searchBarShouldEndEditing:(id)searchBar;


@end

@interface SubViewSearchBar : UIView <UITextFieldDelegate> {
    CGPoint nonEditingFieldOrigin;
    CGPoint isEditingFieldOrigin;
    CGSize nonEditingFieldSize;
    CGSize isEditingFieldSize;
    CGRect nonEditingBgFrame;
    CGRect isEditingBgFrame;
    CGRect nonEditingCancelFrame;
    CGRect isEditingCancelFrame;
    CGRect nonEditingBgButtonFrame;
    CGRect isEditingBgButtonFrame;
    
    UITextField *searchField;
    UIImageView *fieldBgImageView;
    UIButton *fieldButton;
    UIButton *buttonAddressBook;
    UIButton *buttonClear;
    UIButton *buttonCancel;
    UIActivityIndicatorView *spinner;
    NSString *localText;
    
    BOOL canShowActivity;
    BOOL shouldShowActivity;
}

@property (nonatomic, assign) id <SubViewSearchBarDelegate> delegate;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) NSString *placeholderText;
//@property (nonatomic, assign) BOOL clearOnReset;

- (void)resetField;
- (void)showError:(BOOL)shouldShowError;
- (void)showNetworkActivity:(BOOL)value;

@end