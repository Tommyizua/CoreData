//
//  YCChoseUsersViewController.h
//  L41-44_Answer
//
//  Created by Yaroslav on 31/01/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//

#import "YCCoreDataViewController.h"

@class YCCourse, YCTeacher;

typedef enum {
    YCChoseViewControllerEntityTypeUser,
    YCChoseViewControllerEntityTypeTeacher,
    YCChoseViewControllerEntityTypeCourse,
} YCChoseViewControllerEntityType;

@interface YCChooseViewController : YCCoreDataViewController

@property (strong, nonatomic) YCCourse *course;
@property (strong, nonatomic) YCTeacher *dataObject;

@property (assign, nonatomic) YCChoseViewControllerEntityType entityType;

@end
