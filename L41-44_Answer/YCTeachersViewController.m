//
//  YCTeachersViewController.m
//  L41-44_Answer
//
//  Created by Yaroslav on 31/01/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//

#import "YCTeachersViewController.h"
#import "YCTeacher.h"
#import "YCAddTeacherViewController.h"

@interface YCTeachersViewController ()

@end

@implementation YCTeachersViewController

@synthesize fetchedResultsController = _fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Teachers list";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItems = @[addButton, self.editButtonItem];
}

#pragma mark - Actions

- (void)insertNewObject:(id)sender {
    
    YCAddTeacherViewController *addTeacherController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"YCAddTeacherViewController"];
    
    [self showViewController:addTeacherController sender:sender];
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:@"YCTeacher"
                                                   inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:description];
    
    NSSortDescriptor *firstNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *lastNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
    
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

#pragma mark - UITableViewDataSource

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    YCTeacher *teacher = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.firstName, teacher.lastName];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)teacher.courses.count];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YCAddTeacherViewController *addTeacherController = [self.storyboard instantiateViewControllerWithIdentifier:@"YCAddTeacherViewController"];
    
    YCTeacher *teacher = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    addTeacherController.teacher = teacher;
    
    [self.navigationController pushViewController:addTeacherController animated:YES];
}

@end
