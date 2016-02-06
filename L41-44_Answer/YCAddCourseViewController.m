//
//  YCAddCourseViewController.m
//  L41-44_Answer
//
//  Created by Yaroslav on 31/01/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//

#import "YCAddCourseViewController.h"
#import "YCDataManager.h"
#import "YCCourse.h"
#import "YCUser.h"
#import "YCTeacher.h"
#import "YCEditingTableViewCell.h"
#import "YCStaticTableObjects.h"
#import "YCChooseViewController.h"
#import "YCAddUserTableViewController.h"
#import "YCAddTeacherViewController.h"

@interface YCAddCourseViewController () <UITextFieldDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) NSArray *fieldsArray;

@property (strong, nonatomic) YCStaticTableObjects *objects;

@end

@implementation YCAddCourseViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *saveItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(saveAllFields:)];
    
    UIBarButtonItem *fixedSpace =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                  target:self
                                                  action:nil];
    
    
    self.navigationItem.rightBarButtonItems = @[saveItem, fixedSpace, self.editButtonItem];
    
    UIBarButtonItem *cancelItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(actionCancel:)];
    
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    
    if (!self.course) {
        
        self.course = [NSEntityDescription insertNewObjectForEntityForName:@"YCCourse"
                                                    inManagedObjectContext:[[YCDataManager sharedManager] managedObjectContext]];
        
    } else {
        
        [self checkForContaintsNilInProperties];
        
        self.fieldsArray = [NSArray arrayWithObjects:self.course.name, self.course.subject, self.course.branch, nil];
    }
    
    
    self.objects = [[YCStaticTableObjects alloc] init];
    
    self.objects.namesSection = [NSArray arrayWithObjects:@"Settings", @"Teacher", @"Students", nil];
    
    self.objects.staticItemsArray = @[@"Name", @"Subject", @"Branch"];
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [[[YCDataManager sharedManager] managedObjectContext] rollback];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAllFields:(UIBarButtonItem *)sender {
    
    NSManagedObjectContext *context = [[YCDataManager sharedManager] managedObjectContext];
    
    [self checkForContaintsNilInProperties];
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionTextChanged:(UITextField *)sender {
    
    if ([sender.superview.superview isKindOfClass:[UITableViewCell class]]) {
        
        YCEditingTableViewCell *cell = (YCEditingTableViewCell *)sender.superview.superview;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        switch (indexPath.row) {
            case 0:
                self.course.name = sender.text;
                break;
                
            case 1:
                self.course.subject = sender.text;
                break;
                
            case 2:
                self.course.branch = sender.text;
                
                sender.keyboardType = UIKeyboardTypeEmailAddress;
                break;
                
            default:
                break;
        }
    }
}

- (void)checkForContaintsNilInProperties {
    
    if (!self.course.name) {
        
        self.course.name = @"";
    }
    
    if (!self.course.subject) {
        
        self.course.subject = @"";
    }
    
    if (!self.course.branch) {
        
        self.course.branch = @"";
    }
}

- (YCUser *)returnInstanceAtIndexPath:(NSIndexPath *)indexPath fromArray:(NSArray *)array {
    
    YCUser *user = [array objectAtIndex:indexPath.row - 1];
    
    return user;
}

- (void)showViewController:(UIViewController *)vc sender:(id)sender {
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    navController.modalPresentationStyle = UIModalPresentationPopover;
    
    [self presentViewController:navController animated:YES completion:nil];
    
    
    UIPopoverPresentationController *popController = [navController popoverPresentationController];
    
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    popController.delegate = self;
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        
        popController.barButtonItem = sender;
        
    } else {
        
        popController.sourceView = self.view;
        popController.sourceRect = [sender frame];
    }
}

- (void)showTeachersList {
    
    YCChooseViewController* vc =
    [self.storyboard instantiateViewControllerWithIdentifier:@"YCChooseViewController"];
    
    vc.course = self.course;
    vc.entityType = YCChoseViewControllerEntityTypeTeacher;
    
    [self showViewController:vc sender:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.objects.namesSection.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [self.objects.namesSection objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return self.objects.staticItemsArray.count;
        
    } else if (section == 2) {
        
        return self.course.users.count + 1;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        
        NSString *textValue = [self.objects.staticItemsArray objectAtIndex:indexPath.row];
        
        YCEditingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        cell.nameLabel.text = textValue;
        cell.inputDataField.text = [self.fieldsArray objectAtIndex:indexPath.row];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        
        static NSString *identifier = @"addCellTeacher";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        if (self.course.teacher) {
            
            YCTeacher *teacher = self.course.teacher;
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.firstName, teacher.lastName];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        } else {
            
            cell.textLabel.text = @"Choose Teacher for Course";
            cell.textLabel.textColor = [UIColor blueColor];
        }
        
        return cell;
        
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            
            static NSString *addIdentifier = @"addCellStudent";
            
            UITableViewCell *addCell = [tableView dequeueReusableCellWithIdentifier:addIdentifier];
            
            if (!addCell) {
                
                addCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addIdentifier];
            }
            
            addCell.textLabel.text = @"Add Student(s) in Course";
            addCell.textLabel.textColor = [UIColor blueColor];
            
            return addCell;
            
        } else {
            
            YCUser *user = [self returnInstanceAtIndexPath:indexPath fromArray:[self.course.users allObjects]];
            
            static NSString *identifier = @"cellStudents";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (!cell) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return NO;
        
    } else if (indexPath.section == 1 && self.course.teacher) {
        
        return YES;
        
    } else if (indexPath.row == 0) {
        
        return NO;
        
    } else {
        
        return YES;
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        self.course.teacher = nil;
        
        [self showTeachersList];
        
    } else {
        
        YCUser *user = [self returnInstanceAtIndexPath:indexPath fromArray:[self.course.users allObjects]];
        
        [self.course removeUsersObject:user];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        
        if (self.course.teacher) {
            
            YCAddTeacherViewController* vc =
            [self.storyboard instantiateViewControllerWithIdentifier:@"YCAddTeacherViewController"];
            
            vc.teacher = self.course.teacher;
            
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            
            [self showTeachersList];
        }
        
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        
        YCChooseViewController* vc =
        [self.storyboard instantiateViewControllerWithIdentifier:@"YCChooseViewController"];
        
        vc.course = self.course;
        vc.entityType = YCChoseViewControllerEntityTypeUser;
        
        [self showViewController:vc sender:nil];
        
    } else if (indexPath.section == 2) {
        
        YCAddUserTableViewController *addUserController = [self.storyboard instantiateViewControllerWithIdentifier:@"YCAddUserTableViewController"];
        
        YCUser *user = [self returnInstanceAtIndexPath:indexPath fromArray:[self.course.users allObjects]];
        
        addUserController.user = user;
        
        [self.navigationController pushViewController:addUserController animated:YES];
    }
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
