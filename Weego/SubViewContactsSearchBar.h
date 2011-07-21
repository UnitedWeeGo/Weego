//
//  SubViewContactsSearchBar.h
//  Weego
//
//  Created by Dave Prukop on 7/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SubViewContactsSearchBarDelegate <NSObject>

- (void)searchBar:(id)searchBar textDidChange:(NSString *)searchText;
- (void)searchBarBookmarkButtonClicked:(id)searchBar;
- (void)searchBarCancelButtonClicked:(id)searchBar;
- (void)searchBarReturnButtonClicked:(id)searchBar;

@optional
- (void)searchBarTextDidBeginEditing:(id)searchBar;
- (void)searchBarTextDidEndEditing:(id)searchBar;
- (BOOL)searchBarShouldBeginEditing:(id)searchBar;
- (BOOL)searchBarShouldEndEditing:(id)searchBar;


@end

@interface SubViewContactsSearchBar : UIView <UITextFieldDelegate> {
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
    
    NSString *placeholderText;
    NSString *localText;
}

@property (nonatomic, assign) id <SubViewContactsSearchBarDelegate> delegate;
@property (nonatomic, readonly) NSString *text;

- (void)resetField;
- (void)showError:(BOOL)shouldShowError;

@end