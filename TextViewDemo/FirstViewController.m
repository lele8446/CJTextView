//
//  ViewController.m
//  TextViewDemo
//
//  Created by YiChe on 16/6/25.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"

@interface FirstViewController ()
@end

@implementation FirstViewController

- (void)dealloc {
    [self.textView removeObserver];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView.maxHeight = 120;
    self.textView.autoLayoutHeight = YES;
//    self.textView.enableEditInsterText = YES;
    self.textView.placeHoldString = @"请输入...";
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.myDelegate = self;
    self.textView.textColor = [UIColor blueColor];
//    self.textView.returnKeyType = UIReturnKeyDone;
    //插入文本的颜色
    self.textView.specialTextColor = [UIColor redColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)clickSwitch:(id)sender {
    self.textView.autoLayoutHeight = self.switchButton.on;
    if (!self.switchButton.on) {
        self.textViewHeight.constant = 60;
    }else{
        CGFloat height = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, MAXFLOAT)].height;
        height = MIN(height, 120);
        self.textViewHeight.constant = height;
    }
}

- (IBAction)finish:(id)sender {
    [self.view endEditing:YES];
    
    NSArray *allModel = [self.textView allTextModel];
    for (CJTextViewModel *model in allModel) {
        if (model.isInsertText) {
            model.isLink = YES;
        }
    }
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //由storyboard根据myView的storyBoardID来获取我们要切换的视图
    SecondViewController *aViewCtr = [story instantiateViewControllerWithIdentifier:@"SecondViewController"];
    aViewCtr.textModelArray = allModel;
    [self.navigationController pushViewController:aViewCtr animated:YES];
}

- (IBAction)insertTextclick:(id)sender {
    [self.textView becomeFirstResponder];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"#主题#"];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, str.length)];
    CJTextViewModel *model = [CJTextViewModel modelWithIdentifier:@"主题" attrString:str parameter:@{@"key":@"插入主题"}];
    [self.textView insertSpecialText:model atIndex:self.textView.selectedRange.location];
}

- (IBAction)insertTextclick2:(id)sender {
    [self.textView becomeFirstResponder];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"@人名"];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, str.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, str.length)];
    CJTextViewModel *model = [CJTextViewModel modelWithIdentifier:@"人名" attrString:str parameter:@"参数"];
    [self.textView insertSpecialText:model atIndex:self.textView.selectedRange.location];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
    NSArray *userModel = [self.textView insertTextModelWithIdentifier:@"人名"];
    NSArray *allInsertModel = [self.textView allInsertTextModel];
    NSArray *allModel = [self.textView allTextModel];
    NSLog(@"@人名 = %@",userModel);
    NSLog(@"所有插入字符 = %@",allInsertModel);
    NSLog(@"所有model = %@",allModel);
}

#pragma mark - CJUITextViewDelegate
- (void)CJUITextViewEnterDone:(CJUITextView *)textView {
    
}

- (void)CJUITextView:(CJUITextView *)textView heightChanged:(CGRect)frame {
    self.textViewHeight.constant = frame.size.height;
}

- (BOOL)CJUITextViewShouldBeginEditing:(CJUITextView *)textView {
    NSLog(@"CJUITextViewShouldBeginEditing");
    return YES;
}
- (BOOL)CJUITextViewShouldEndEditing:(CJUITextView *)textView {
    return YES;
}

- (void)CJUITextViewDidBeginEditing:(CJUITextView *)textView {
    
}
- (void)CJUITextViewDidEndEditing:(CJUITextView *)textView {

}

- (BOOL)CJUITextView:(CJUITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}
- (void)CJUITextViewDidChange:(CJUITextView *)textView {
    
}

- (void)CJUITextViewDidChangeSelection:(CJUITextView *)textView {
    
}

- (void)CJUITextView:(CJUITextView *)textView placeHoldLabelHidden:(BOOL)hidden {
    
}
- (void)CJUITextView:(CJUITextView *)textView changeSelectedRange:(NSRange)selectedRange {
    NSLog(@"改变选中文本 selectedRange = %@",NSStringFromRange(selectedRange));
    
}
@end
