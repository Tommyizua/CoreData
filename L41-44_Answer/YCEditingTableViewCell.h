//
//  YCEditingTableViewCell.h
//  L41-44_Answer
//
//  Created by Yaroslav on 30/01/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCEditingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UITextField *inputDataField;

@end
