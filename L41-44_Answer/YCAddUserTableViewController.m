//
//  YCDetailTableViewController.m
//  L37-38_Answer
//
//  Created by Yaroslav on 26/01/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//

#import "YCAddUserTableViewController.h"
#import "YCUser.h"
#import "YCCourse.h"
#import "YCDataManager.h"
#import "YCEditingTableViewCell.h"
#import "YCStaticTableObjects.h"
#import "YCAddCourseViewController.h"
#import "YCChooseViewController.h"

@interface YCAddUserTableViewController () <UITextFieldDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) NSArray *fieldsArray;

@property (strong, nonatomic) YCStaticTableObjects *objects;

- (IBAction)actionTextChanged:(UITextField *)sender;

@end

@implementation YCAddUserTableViewController


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
    
    self.navigationItem.rightBarButtonItem = saveItem;
    
    UIBarButtonItem *cancelItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(actionCancel:)];
    
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    if (!self.user) {
      
        self.user = [NSEntityDescription insertNewObjectForEntityForName:@"YCUser"
                                                  inManagedObjectContext:[[YCDataManager sharedManager] managedObjectContext]];
        
    } else {
        
        [self checkForContaintsNilInProperties];
        
        self.fieldsArray = [NSArray arrayWithObjects:self.user.firstName, self.user.lastName, self.user.emailAddress, nil];
    }
    
    self.objects = [[YCStaticTableObjects alloc] init];
    
    self.objects.namesSection = [NSArray arrayWithObjects:@"Settings", @"Courses", nil];
    
    self.objects.staticItemsArray = [NSArray arrayWithObjects:@"First name", @"Last name", @"Email address", nil];
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
   
    [[[YCDataManager sharedManager] managedObjectContext] rollback];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAllFields:(UIBarButtonItem *)sender {
    
    NSManagedObjectContext *context = [[YCDataManager sharedManager] managedObjectContext];
    
    NSError *error = nil;
    
    [self checkForContaintsNilInProperties];
    
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
                self.user.firstName = sender.text;
                break;
                
            case 1:
                self.user.lastName = sender.text;
                break;
                
            case 2:
                self.user.emailAddress = sender.text;
                sender.keyboardType = UIKeyboardTypeEmailAddress;
                break;
                
            default:
                break;
        }
    }
    
}

- (void)checkForContaintsNilInProperties {
    
    if (!self.user.firstName) {
        
        self.user.firstName = @"";
    }
    
    if (!self.user.lastName) {
        
        self.user.lastName = @"";
    }
    
    if (!self.user.emailAddress) {
        
        self.user.emailAddress = @"";
    }
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


- (YCCourse *)returnInstanceAtIndexPath:(NSIndexPath *)indexPath fromArray:(NSArray *)array {
    
    YCCourse *course = [array objectAtIndex:indexPath.row - 1];
    
    return course;
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
        
    } else {
        
        return self.user.courses.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        YCEditingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        cell.nameLabel.text = [self.objects.staticItemsArray objectAtIndex:indexPath.row];
        cell.inputDataField.text = [self.fieldsArray objectAtIndex:indexPath.row];
        
        return cell;
        
    } else if (indexPath.row == 0) {
        
        static NSString *addIdentifier = @"addCellCourse";
        
        UITableViewCell *addCell = [tableView dequeueReusableCellWithIdentifier:addIdentifier];
        
        if (!addCell) {
            
            addCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addIdentifier];
        }
        
        addCell.textLabel.text = @"Add Course(s) for User";
        addCell.textLabel.textColor = [UIColor blueColor];
        
        return addCell;
        
    } else {
        
        YCCourse *course = [self returnInstanceAtIndexPath:indexPath fromArray:[self.user.courses allObjects]];
        
        static NSString *identifier = @"cellCourses";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", course.name, course.branch];
        cell.detailTextLabel.text = course.subject;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return NO;
        
    } else if (indexPath.row == 0) {
        
        return NO;
        
    } else {
        
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YCCourse *course = [self returnInstanceAtIndexPath:indexPath fromArray:[self.user.courses allObjects]];
    
    [self.user removeCoursesObject:course];
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        YCChooseViewController* vc =
        [self.storyboard instantiateViewControllerWithIdentifier:@"YCChooseViewController"];
        
        vc.dataObject = (YCTeacher *)self.user;
        vc.entityType = YCChoseViewControllerEntityTypeCourse;
        
        [self showViewController:vc sender:nil];
        
    } else if (indexPath.section == 1) {
        
        YCAddCourseViewController *addCourseController = [self.storyboard instantiateViewControllerWithIdentifier:@"YCAddCourseViewController"];
        
        YCCourse *course = [self returnInstanceAtIndexPath:indexPath fromArray:[self.user.courses allObjects]];
        
        addCourseController.course = course;
        
        [self.navigationController pushViewController:addCourseController animated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}


@end
