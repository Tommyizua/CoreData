//
//  YCUser+CoreDataProperties.h
//  L41-44_Answer
//
//  Created by Yaroslav on 30/01/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YCUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSString *emailAddress;
@property (nullable, nonatomic, retain) NSSet<YCCourse *> *courses;

@end

@interface YCUser (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(YCCourse *)value;
- (void)removeCoursesObject:(YCCourse *)value;
- (void)addCourses:(NSSet<YCCourse *> *)values;
- (void)removeCourses:(NSSet<YCCourse *> *)values;

@end

NS_ASSUME_NONNULL_END
