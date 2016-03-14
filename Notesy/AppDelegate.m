//
//  AppDelegate.m
//  Notesy
//
//  Created by Kevin O'Connell on 3/5/16.
//  Copyright (c) 2016 Logan O'Connell. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              @"wantsPasswordEnabled": @YES,
                                                              @"useTouchID": @YES,
                                                              @"lockAppOnExit": @YES
                                                              }];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [((ViewController *)[((UINavigationController *)[((UITabBarController *)self.window.rootViewController).viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0]) lockApp];
}

- (NSString *)getPathOfFile {
    NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = pathsArray[0];
    NSString *dataFilePath = [documentsPath stringByAppendingString:@"/notesData"];
    
    return dataFilePath;
}

- (BOOL)checkIfDataFileExists {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getPathOfFile]]) {
        return YES;
    }
    
    return NO;
}
@end