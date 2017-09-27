//
//  ViewController.h
//  TextViewDemo
//
//  Created by YiChe on 16/6/25.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CJUITextView.h"

@interface FirstViewController : UIViewController<CJUITextViewDelegate>
@property (nonatomic, weak) IBOutlet CJUITextView *textView;
@property (nonatomic, weak) IBOutlet UISwitch *switchButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textViewHeight;


@end

