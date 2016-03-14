//
//  PasswordViewController.h
//  Notesy
//
//  Created by Kevin O'Connell on 3/5/16.
//  Copyright (c) 2016 Logan O'Connell. All rights reserved.
//

#import "Header.h"
#import "PAPasscodeViewController.h"

@protocol PasswordViewControllerDelegate <NSObject>
- (void)passwordWasEnteredCorrectly;
- (void)passwordWasSet;
- (void)userWantsToBeAuthenticated;
- (void)dismissPasscodeVC;
@end

@interface PasswordViewController : UINavigationController <PAPasscodeViewControllerDelegate>
@property (nonatomic, strong) PAPasscodeViewController *pvc;

@property (nonatomic, strong) id <PasswordViewControllerDelegate> pvcDelegate;
@end