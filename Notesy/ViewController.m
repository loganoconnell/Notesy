//
//  ViewController.m
//  Notesy
//
//  Created by Kevin O'Connell on 3/5/16.
//  Copyright (c) 2016 Logan O'Connell. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "PAPasscodeViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *searchResults;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Notes";
    
    self.tblNotes.delegate = self;
    self.tblNotes.dataSource = self;
    
    self.noteIndexToEdit = -1;
    
    self.isSearching = NO;
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    if (![userDefaults boolForKey:@"hasSeenPasswordAlert"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Notesy" message:@"Would you like to lock your notes? You will have to create a password if so, but the app can also be unlocked with Touch ID." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [userDefaults setBool:YES forKey:@"hasSeenPasswordAlert"];
            
            [userDefaults setBool:NO forKey:@"wantsPasswordEnabled"];
        }];
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [userDefaults setBool:YES forKey:@"hasSeenPasswordAlert"];
            
            [userDefaults setBool:YES forKey:@"wantsPasswordEnabled"];
            
            [self showPasswordView];
        }];
        
        [alertController addAction:no];
        [alertController addAction:yes];
        
        alertController.view.tintColor = UIColorFromRGB(0x212121);
        
        [self.tabBarController presentViewController:alertController animated:YES completion:nil];
    }
    
    else {
        if ([userDefaults boolForKey:@"wantsPasswordEnabled"]) {
            [self authenticateUser];
        }
        
        else {
            [self loadData];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.tblNotes.isEditing) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

+ (BOOL)canAuthenticateUser {
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error;
    
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}

- (void)authenticateUser {
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error;
    
    NSString *reasonString = @"Authentication is needed to access your notes.";
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error] && [userDefaults boolForKey:@"useTouchID"]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reasonString reply:^(BOOL success, NSError *error) {
            if (success) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self loadData];
                }];
            }
            
            else {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self showPasswordView];
                }];            }
        }];
    }
    
    else {
        [self showPasswordView];
    }
}

- (void)lockApp {
    if ([userDefaults boolForKey:@"wantsPasswordEnabled"] && [userDefaults boolForKey:@"lockAppOnExit"]) {
        if ([ViewController canAuthenticateUser]) {
            [self dismissPasscodeVC];
        }
        
        [self authenticateUser];
    }
}

- (void)showPasswordView {
    if (![NSStringFromClass([[self presentedViewController] class]) isEqualToString:@"PasswordViewController"]) {
        PasswordViewController *pvc = [[PasswordViewController alloc] init];
        pvc.pvcDelegate = self;
        
        [self.tabBarController presentViewController:pvc animated:YES completion:nil];
    }
}

- (void)loadData {
    if ([appDelegate checkIfDataFileExists]) {
        self.dataArray = [[NSMutableArray alloc] initWithContentsOfFile:[appDelegate getPathOfFile]];
        
        [self.tblNotes reloadData];
    }
    
    if (self.dataArray.count == 0) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    
    else {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

- (IBAction)editNotes:(id)sender {
    self.tblNotes.editing = !self.tblNotes.editing;
    
    if (self.tblNotes.isEditing) {
        [self setNavigationButtonAsDone];
    }
    
    else {
        [self setNavigationButtonAsEdit];
    }
}

- (void)setNavigationButtonAsEdit {
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editNotes:)];
    
    self.navigationItem.leftBarButtonItem = editButton;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewNote:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)setNavigationButtonAsDone {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(editNotes:)];
                                   
    self.navigationItem.leftBarButtonItem = doneButton;
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteSelectedNotes:)];
    deleteButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = deleteButton;
}

- (void)addNewNote:(id)sender {
    [self performSegueWithIdentifier:@"idSegueEditNote" sender:self];
}

- (void)deleteSelectedNotes:(id)sender {
    NSSortDescriptor *rowDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:NO];
    NSArray *sortedRows = [self.tblNotes.indexPathsForSelectedRows sortedArrayUsingDescriptors:@[rowDescriptor]];
    
    for (NSIndexPath *indexPath in sortedRows) {
        [self.dataArray removeObjectAtIndex:indexPath.row];
        
        [self.dataArray writeToFile:[appDelegate getPathOfFile] atomically:YES];
        
        [self.tblNotes reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    self.tblNotes.editing = NO;
    
    [self setNavigationButtonAsEdit];
    
    if (self.dataArray.count == 0) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"idSegueEditNote"]) {
        EditNoteViewController *editNoteViewController = (EditNoteViewController *)segue.destinationViewController;
        
        editNoteViewController.delegate = self;

        if (self.noteIndexToEdit != -1) {
            editNoteViewController.shouldEditNote = YES;
            
            editNoteViewController.indexOfEditedNote = self.noteIndexToEdit;
            
            self.noteIndexToEdit = -1;
        }
        
        else {
            editNoteViewController.shouldEditNote = NO;
        }
    }
}

#pragma mark EditNoteViewControllerDelegate

- (void)noteWasSaved {
    [self loadData];
}

#pragma mark PasscodeViewControllerDelegate

- (void)passwordWasEnteredCorrectly {
    [self loadData];
}

- (void)passwordWasSet {
    [self loadData];
}

- (void)userWantsToBeAuthenticated {
    [self authenticateUser];
}


- (void)dismissPasscodeVC {
    if ([NSStringFromClass([[self.tabBarController presentedViewController] class]) isEqualToString:@"PasswordViewController"]) {
        [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.tblNotes.isEditing) {
        if (self.isSearching) {
            NSDictionary *note = [self.searchResults objectAtIndex:indexPath.row];
            
            NSInteger newIndex = (NSInteger)[self.dataArray indexOfObject:note];
            
            self.noteIndexToEdit = newIndex;
        }
        
        else {
            self.noteIndexToEdit = indexPath.row;
        }
        
        [self performSegueWithIdentifier:@"idSegueEditNote" sender:self];
        
        [self.tblNotes cellForRowAtIndexPath:indexPath].selected = NO;
    }
    
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tblNotes.indexPathsForSelectedRows.count == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.searchResults.count;
    }
    
    else {
        if (self.dataArray) {
            return self.dataArray.count;
        }
        
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:@"idCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"idCell"];
    }
    
    NSDictionary *currentNote;
    
    if (self.isSearching) {
        currentNote = [self.searchResults objectAtIndex:indexPath.row];
    }
    
    else {
        currentNote = [self.dataArray objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = currentNote[@"title"];
    cell.detailTextLabel.text = currentNote[@"body"];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = UIColorFromRGB(0xF5F5F5);
    
    cell.selectedBackgroundView = bgView;

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataArray removeObjectAtIndex:indexPath.row];
        
        [self.dataArray writeToFile:[appDelegate getPathOfFile] atomically:YES];
        
        [self.tblNotes reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    if (self.tblNotes.indexPathsForSelectedRows.count == 0) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSDictionary *noteDict = [self.dataArray objectAtIndex:fromIndexPath.row];
    
    [self.dataArray removeObject:noteDict];
    
    [self.dataArray insertObject:noteDict atIndex:toIndexPath.row];
    
    [self.dataArray writeToFile:[appDelegate getPathOfFile] atomically:YES];
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
    
    UITextField *searchBarTextField = (UITextField *)[searchBar valueForKey:@"_searchField"];
    searchBarTextField.textColor = UIColorFromRGB(0x212121);
    
    searchBar.backgroundColor = [UIColor whiteColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    self.topAnchor.constant = -20;
    [self.view layoutIfNeeded];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if ([searchBar.text isEqualToString:@""]) {
        self.isSearching = NO;
        
        searchBar.backgroundColor = UIColorFromRGB(0xF5F5F5);
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
        self.topAnchor.constant = -64;
        [self.view layoutIfNeeded];
    }
}

-  (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isSearching = NO;
    
    searchBar.backgroundColor = UIColorFromRGB(0xF5F5F5);
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.topAnchor.constant = -64;
    [self.view layoutIfNeeded];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchResults = [NSMutableArray array];
    
    for (NSDictionary *note in self.dataArray) {
        if ([[note[@"title"] lowercaseString] containsString:[searchText lowercaseString]]) {
            [self.searchResults addObject:note];
        }
    }
    
    for (NSDictionary *note in self.dataArray) {
        if ([[note[@"body"] lowercaseString] containsString:[searchText lowercaseString]] && ![self.searchResults containsObject:note]) {
            [self.searchResults addObject:note];
        }
    }
}
@end