//
//  PasswordViewController.m
//  Notesy
//
//  Created by Kevin O'Connell on 3/5/16.
//  Copyright (c) 2016 Logan O'Connell. All rights reserved.
//

#import "PasswordViewController.h"

@interface PasswordViewController ()
@end

@implementation PasswordViewController
- (id)init {
    if (self = [super init]) {
        PasscodeAction action;
        
        if ([userDefaults boolForKey:@"hasSetPassword"]) {
            action = PasscodeActionEnter;
        }
        
        else {
            action = PasscodeActionSet;
        }
        
        PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:action];
        passcodeViewController.delegate = self;
        
        self.pvc = passcodeViewController;
        
        if (passcodeViewController.action == PasscodeActionEnter) {
            passcodeViewController.passcode = [userDefaults stringForKey:@"password"];
        }
        
        else {
            self.pvc.navigationItem.rightBarButtonItem.enabled = NO;
        }
        
        [self setViewControllers:@[passcodeViewController] animated:NO];
        
        self.navigationBar.translucent = NO;
        self.navigationBar.barTintColor = UIColorFromRGB(0x303F9F);
        self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark PAPasscodeViewControllerDelegate

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller {
    [self.pvcDelegate dismissPasscodeVC];
    
    [self.pvcDelegate passwordWasEnteredCorrectly];
}
- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller {
    [userDefaults setBool:YES forKey:@"hasSetPassword"];
    
    [userDefaults setObject:controller.passcode forKey:@"password"];
    
    [self.pvcDelegate dismissPasscodeVC];
    
    [self.pvcDelegate passwordWasSet];
}

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller {
    [self.pvcDelegate dismissPasscodeVC];
    
    [self.pvcDelegate userWantsToBeAuthenticated];
}
@end