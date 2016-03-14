//
//  ViewController.h
//  Notesy
//
//  Created by Kevin O'Connell on 3/5/16.
//  Copyright (c) 2016 Logan O'Connell. All rights reserved.
//

#import "Header.h"
#import "EditNoteViewController.h"
#import "PasswordViewController.h"

@interface ViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, EditNoteViewControllerDelegate, PasswordViewControllerDelegate>
@property IBOutlet UITableView *tblNotes;

@property IBOutlet NSLayoutConstraint *topAnchor;

@property (nonatomic) NSInteger noteIndexToEdit;

@property (nonatomic) BOOL isSearching;

+ (BOOL)canAuthenticateUser;
- (void)lockApp;
- (void)showPasswordView;
@end