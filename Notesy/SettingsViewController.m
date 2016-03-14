//
//  SettingsViewController.m
//  Notesy
//
//  Created by Kevin O'Connell on 3/5/16.
//  Copyright (c) 2016 Logan O'Connell. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface SettingsViewController ()
@property (nonatomic, strong) NSMutableArray *settingsDataArray;
@end

@implementation SettingsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    
    if (![userDefaults boolForKey:@"wantsPasswordEnabled"]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (IBAction)lock:(id)sender {
    UITabBarController *tabBarController = ((UITabBarController *)appDelegate.window.rootViewController);
    
    [((ViewController *)[((UINavigationController *)[tabBarController.viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0]) lockApp];
    
    [tabBarController performSelector:@selector(setSelectedViewController:) withObject:[tabBarController.viewControllers objectAtIndex:0] afterDelay:0.5];
}

- (UITableViewCell *)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 59, 6.5, 51, 31)];
        switchView.tag = indexPath.row + 1;
        switchView.onTintColor = UIColorFromRGB(0x212121);

        [switchView addTarget:self action:@selector(settingsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        switch (indexPath.row) {
            case 0:
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = @"Authenticate to use app";
                switchView.on = [userDefaults boolForKey:@"wantsPasswordEnabled"];
                
                break;
            case 1:
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = @"Use Touch ID to unlock";
                
                if (![ViewController canAuthenticateUser]) {
                    switchView.on = NO;
                    
                    cell.userInteractionEnabled = NO;
                    cell.textLabel.enabled = NO;
                }
                
                else {
                    switchView.on = [userDefaults boolForKey:@"useTouchID"];
                }
                
                break;
            case 2:
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = @"Lock app on exit";
                switchView.on = [userDefaults boolForKey:@"lockAppOnExit"];
                
                break;
            case 3:
                cell.textLabel.text = @"Change password";
                cell.textLabel.textColor = UIColorFromRGB(0x303F9F);
                
                break;
            default:
                break;
        }
        
        if (indexPath.row != 3) {
            if (![cell.contentView viewWithTag:switchView.tag]) {
                [cell.contentView addSubview:switchView];

            }
        }
    }
    
    else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Email support";
                cell.textLabel.textColor = UIColorFromRGB(0x303F9F);
                
                break;
            case 1:
                cell.textLabel.text = @"Follow @logandev22";
                cell.textLabel.textColor = UIColorFromRGB(0x303F9F);
                
                break;
            case 2:
                cell.textLabel.text = @"View app on Github";
                cell.textLabel.textColor = UIColorFromRGB(0x303F9F);
                
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void)settingsSwitchChanged:(UISwitch *)sender {
    switch (sender.tag) {
        case 1:
            [userDefaults setBool:sender.on forKey:@"wantsPasswordEnabled"];
            
            if (![userDefaults boolForKey:@"hasSetPassword"]) {
                [self showViewControllerPasswordView];
            }
            
            self.navigationItem.rightBarButtonItem.enabled = [userDefaults boolForKey:@"wantsPasswordEnabled"];
            
            break;
            
        case 2:
            [userDefaults setBool:sender.on forKey:@"useTouchID"];
            
            break;
        case 3:
            [userDefaults setBool:sender.on forKey:@"lockAppOnExit"];
            
            break;
        default:
            break;
    }
}

- (void)showViewControllerPasswordView {
    [userDefaults setBool:NO forKey:@"hasSetPassword"];
    
    [((ViewController *)[((UINavigationController *)[((UITabBarController *)appDelegate.window.rootViewController).viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0]) showPasswordView];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            [self showViewControllerPasswordView];
        }
    }
    
    else {
        switch (indexPath.row) {
            case 0:
                if ([MFMailComposeViewController canSendMail] ) {
                    MFMailComposeViewController *composeVC = [[MFMailComposeViewController alloc] init];
                    composeVC.mailComposeDelegate = self;
                    [composeVC setToRecipients:@[@"logan.developeremail@gmail.com"]];
                    [composeVC setSubject:@"\"Notesy\" Support"];
                    
                    [((UITabBarController *)appDelegate.window.rootViewController) presentViewController:composeVC animated:YES completion:nil];
                }
                
                break;
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/logandev22"]];
                
                break;
            case 2:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/loganoconnell/notesy"]];
                
                break;
            default:
                break;
        }
        
        
    }
    
    [self.settingsTableView cellForRowAtIndexPath:indexPath].selected = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    ((UITableViewHeaderFooterView *)view).textLabel.textAlignment = NSTextAlignmentCenter;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    
    else if (section == 1) {
        return 3;
    }
    
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"idSettingsCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"idSettingsCell"];
    }
    
    cell.detailTextLabel.text = @"";
    
    [self configureCell:cell forIndexPath:indexPath];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = UIColorFromRGB(0xF5F5F5);
    
    cell.selectedBackgroundView = bgView;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Password";
    }
    else {
        return @"Information";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return @"© 2016 Logan O'Connell";
    }
    
    return nil;
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [((UITabBarController *)appDelegate.window.rootViewController) dismissViewControllerAnimated:YES completion:nil];
}
@end