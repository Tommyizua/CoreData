//
//  YCCourse+CoreDataProperties.h
//  L41-44_Answer
//
//  Created by Yaroslav on 30/01/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YCCourse.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCCourse (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *branch;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSSet<YCUser *> *users;
@property (nullable, nonatomic, retain) YCTeacher *teacher;

@end

@interface YCCourse (CoreDataGeneratedAccessors)

- (void)addUsersObject:(YCUser *)value;
- (void)removeUsersObject:(YCUser *)value;
- (void)addUsers:(NSSet<YCUser *> *)values;
- (void)removeUsers:(NSSet<YCUser *> *)values;

@end

NS_ASSUME_NONNULL_END
