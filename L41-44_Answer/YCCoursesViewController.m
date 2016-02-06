//
//  YCCoursesViewController.m
//  L41-44_Answer
//
//  Created by Yaroslav on 30/01/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//

#import "YCCoursesViewController.h"
#import "YCCourse.h"
#import "YCAddCourseViewController.h"

@interface YCCoursesViewController ()

@end

@implementation YCCoursesViewController

@synthesize fetchedResultsController = _fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationItem.title = @"Courses list";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItems = @[addButton, self.editButtonItem];
}


#pragma mark - Actions

- (void)insertNewObject:(id)sender {
    
    YCAddCourseViewController *addCourseController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"YCAddCourseViewController"];
    
    [self showViewController:addCourseController sender:sender];
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:@"YCCourse"
                                                   inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:description];
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[nameDescriptor]];
    
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
    
    YCCourse *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", course.name, course.branch];
    cell.detailTextLabel.text = course.subject;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YCAddCourseViewController *addCourseController = [self.storyboard instantiateViewControllerWithIdentifier:@"YCAddCourseViewController"];
    
    YCCourse *course = [self.fetchedResultsController objectAtIndexPath:indexPath];

    addCourseController.course = course;
    
    [self showViewController:addCourseController sender:nil];
}


@end
