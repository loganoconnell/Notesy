//
//  EditNoteViewController.h
//  Notesy
//
//  Created by Kevin O'Connell on 3/5/16.
//  Copyright (c) 2016 Logan O'Connell. All rights reserved.
//

#import "Header.h"

@protocol EditNoteViewControllerDelegate <NSObject>
- (void)noteWasSaved;
@end

@interface EditNoteViewController : UIViewController <UITextFieldDelegate>
@property IBOutlet UITextField *txtNoteTitle;
@property IBOutlet UITextView *tvNoteBody;

@property (nonatomic, strong) id <EditNoteViewControllerDelegate> delegate;

@property (nonatomic) NSInteger indexOfEditedNote;

@property (nonatomic) BOOL shouldEditNote;

- (void)editNote;
@end