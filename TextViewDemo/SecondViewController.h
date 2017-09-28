//
//  SecondViewController.h
//  TextViewDemo
//
//  Created by ChiJinLian on 2017/9/21.
//  Copyright © 2017年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CJDisplayTextView.h"

@interface SecondViewController : UIViewController
@property (nonatomic, weak) IBOutlet CJDisplayTextView *textView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textViewHeight;

@property (nonatomic, strong) NSArray <CJTextViewModel *>*textModelArray;

@end
