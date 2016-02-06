//
//  YCChoseUsersViewController.m
//  L41-44_Answer
//
//  Created by Yaroslav on 31/01/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//

#import "YCChooseViewController.h"
#import "YCDataManager.h"
#import "YCUser.h"
#import "YCCourse.h"
#import "YCTeacher.h"

@interface YCChooseViewController ()

@property (assign, nonatomic) NSInteger selectedRow;

@end

@implementation YCChooseViewController

@synthesize fetchedResultsController = _fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationItem.title = @"Chose menu";
    
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
    
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [[[YCDataManager sharedManager] managedObjectContext] rollback];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveAllFields:(UIBarButtonItem *)sender {
    
    NSArray *indexPathArray = [self.tableView indexPathsForSelectedRows];
    
    NSMutableArray *objectsArray = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in indexPathArray) {
        
        [objectsArray addObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
    
    switch (self.entityType) {
        case YCChoseViewControllerEntityTypeUser:
            [self.course setUsers:[NSSet setWithArray:objectsArray]];
            break;
            
        case YCChoseViewControllerEntityTypeTeacher:
            [self.course setTeacher:[objectsArray firstObject]];
            break;
            
        case YCChoseViewControllerEntityTypeCourse:
            [self.dataObject setCourses:[NSSet setWithArray:objectsArray]];
            break;
            
        default:
            break;
    }
    
    NSManagedObjectContext *context = [[YCDataManager sharedManager] managedObjectContext];
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)returnEntityNameForClassType:(YCChoseViewControllerEntityType)entityType {
    
    NSString *entityName = nil;
    
    switch (entityType) {
        case YCChoseViewControllerEntityTypeUser:
            entityName = NSStringFromClass([YCUser class]);
            break;
            
        case YCChoseViewControllerEntityTypeTeacher:
            entityName = NSStringFromClass([YCTeacher class]);
            break;
            
        case YCChoseViewControllerEntityTypeCourse:
            entityName = NSStringFromClass([YCCourse class]);
            break;
            
        default:
            break;
    }
    
    return entityName;
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if (self.entityType == YCChoseViewControllerEntityTypeUser) {
        
        YCUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        cell.detailTextLabel.text = nil;
        
        if ([self.course.users containsObject:user]) {
            
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
        
    } else if (self.entityType == YCChoseViewControllerEntityTypeTeacher) {
        
        YCTeacher *teacher = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.firstName, teacher.lastName];
        cell.detailTextLabel.text = nil;
        
        if ([self.course.teacher isEqual:teacher]) {
            
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
        
    } else if (self.entityType == YCChoseViewControllerEntityTypeCourse) {
        
        YCCourse *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", course.name, course.branch];
        cell.detailTextLabel.text = course.subject;
        
        if ([[self.dataObject courses] containsObject:course]) {
            
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *selectedRowsIndexPath = [self.tableView indexPathsForSelectedRows];
    
    if (self.entityType == YCChoseViewControllerEntityTypeTeacher && selectedRowsIndexPath.count > 1) {
        
        NSIndexPath *chosenTeacher =  [selectedRowsIndexPath firstObject];
        
        [tableView deselectRowAtIndexPath:chosenTeacher animated:YES];
    }
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *entityName = [self returnEntityNameForClassType:self.entityType];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName
                                                   inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:description];
    
    if (self.entityType == YCChoseViewControllerEntityTypeCourse) {
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        
        [fetchRequest setSortDescriptors:@[nameDescriptor]];
        
    } else {
        
        NSSortDescriptor *firstNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        NSSortDescriptor *lastNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
        
        [fetchRequest setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
    }
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    
    if (![self.fetchedResultsController performFetch:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

@end
