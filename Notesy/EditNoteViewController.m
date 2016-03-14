//
//  EditNoteViewController.m
//  Notesy
//
//  Created by Kevin O'Connell on 3/5/16.
//  Copyright (c) 2016 Logan O'Connell. All rights reserved.
//

#import "EditNoteViewController.h"
#import "AppDelegate.h"

@interface EditNoteViewController ()
@end

@implementation EditNoteViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.txtNoteTitle.delegate = self;
    
    if (!self.shouldEditNote) {
        self.title = @"New Note";
        
        [self.txtNoteTitle becomeFirstResponder];
    }
    
    else {
        self.title = @"Edit Note";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.shouldEditNote) {
        [self editNote];
    }
}

- (IBAction)saveNote:(id)sender {
    if ([self.txtNoteTitle.text isEqualToString:@""]) {
        return;
    }
    
    NSDictionary *noteDict = @{
                               @"title": self.txtNoteTitle.text,
                               @"body": self.tvNoteBody.text
                               };
    
    NSMutableArray *dataArray;
    
    if ([appDelegate checkIfDataFileExists]) {
        dataArray = [[NSMutableArray alloc] initWithContentsOfFile:[appDelegate getPathOfFile]];
        
        if (!self.shouldEditNote) {
            [dataArray insertObject:noteDict atIndex:0];
        }
        
        else {
            [dataArray replaceObjectAtIndex:self.indexOfEditedNote withObject:noteDict];
        }
    }
    
    else {
        dataArray = [[NSMutableArray alloc] initWithObjects:noteDict, nil];
    }
    
    [dataArray writeToFile:[appDelegate getPathOfFile] atomically:YES];
    
    [self.delegate noteWasSaved];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)editNote {
    NSArray *notesArray = [[NSArray alloc] initWithContentsOfFile:[appDelegate getPathOfFile]];
    
    NSDictionary *noteDict = [notesArray objectAtIndex:self.indexOfEditedNote];
    
    self.txtNoteTitle.text = noteDict[@"title"];
    
    self.tvNoteBody.text = noteDict[@"body"];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.txtNoteTitle resignFirstResponder];
    
    [self.tvNoteBody performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
    
    return YES;
}
@end