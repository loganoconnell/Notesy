//
//  Header.h
//  Notesy
//
//  Created by Logan O'Connell on 3/12/16.
//  Copyright © 2016 Logan O'Connell. All rights reserved.
//

@import UIKit;
@import LocalAuthentication;
@import MessageUI;
@import QuartzCore;

#define appDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define userDefaults [NSUserDefaults standardUserDefaults]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255 green:((float)((rgbValue & 0xFF00) >> 8))/255 blue:((float)(rgbValue & 0xFF))/255 alpha:1]