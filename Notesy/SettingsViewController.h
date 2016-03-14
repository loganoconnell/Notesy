//
//  SettingsViewController.h
//  Notesy
//
//  Created by Kevin O'Connell on 3/5/16.
//  Copyright (c) 2016 Logan O'Connell. All rights reserved.
//

#import "Header.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>
@property IBOutlet UITableView *settingsTableView;
@end