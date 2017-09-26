//
//  SecondViewController.m
//  TextViewDemo
//
//  Created by ChiJinLian on 2017/9/21.
//  Copyright © 2017年 YiChe. All rights reserved.
//

#import "SecondViewController.h"
#import "CJUITextView.h"
#import "CJDisplayTextView.h"

@interface SecondViewController ()<CJUITextViewDelegate>
@property (nonatomic, weak) IBOutlet CJDisplayTextView *textView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textViewHeight;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.textView.textViewModel = DisplayModelType;
//    self.textView.text = @"IQKeyboardManager应该www.baidu.com都不陌生，现在要求在点击Done按钮github.com的 北京市海淀区首体南路5号 同时执行自定义事件myAction。分13675547656析源y.com码发现Done按钮对应的方法- (void)doneAction:(IQBarButtonItem*)barButton在IQKeyboardManager.m中，对于这个私有方法貌641003000@qq.com似只能通过修改IQKeyboardManager.m源码来进行扩展了，http://www.jianshu.com/p/cfe338e2e9e5 但奈何项目是用CocoaPods进行管理的，如果直接修改三方库源码也就意味 2017-09-19 11:20:10 着IQKeyboardManager需要从CocoaPods管理中移除，这对于有强迫症的人来说自然是不能忍的😣😣";
//    self.textView.myDelegate = self;
    self.textView.editable = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)CJUITextView:(CJUITextView *)textView layoutDisplaySize:(CGSize)displaySize {
    self.textViewHeight.constant = displaySize.height;
}

@end
