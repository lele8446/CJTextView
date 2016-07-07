//
//  ViewController.m
//  TextViewDemo
//
//  Created by YiChe on 16/6/25.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)dealloc {
    self.textView.myDelegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView.maxHeight = 120;
    self.textView.autoLayoutHeight = YES;
    self.textView.placeHoldString = @"请输入...";
    self.textView.placeHoldTextFont = [UIFont systemFontOfSize:14];
    self.textView.myDelegate = self;
    self.textView.textColor = [UIColor blueColor];
    self.textView.returnKeyType = UIReturnKeyDone;
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

- (IBAction)insertTextclick:(id)sender {
    [self.textView becomeFirstResponder];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"#插入文本#"];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, str.length)];
    self.textView.selectedRange = [self.textView insterSpecialTextAndGetSelectedRange:str selectedRange:self.textView.selectedRange text:self.textView.attributedText];
}

- (IBAction)insertTextclick2:(id)sender {
    [self.textView becomeFirstResponder];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"@特殊文本"];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, str.length)];
    self.textView.selectedRange = [self.textView insterSpecialTextAndGetSelectedRange:str selectedRange:self.textView.selectedRange text:self.textView.attributedText];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
    self.label.attributedText = self.textView.attributedText;
    if (self.textView.attributedText.length == 0) {
        self.label.text = @"显示输入内容";
    }
}

#pragma mark - CJUITextViewDelegate
- (void)CJUITextViewEnterDone:(CJUITextView *)textView {
    NSAttributedString *text = textView.attributedText;
    self.label.attributedText = text;
    if (text.length == 0) {
        self.label.text = @"显示输入内容";
    }
}

- (void)CJUITextView:(CJUITextView *)textView heightChanged:(CGRect)frame {
    self.textViewHeight.constant = frame.size.height;
}

- (BOOL)textViewShouldBeginEditing:(CJUITextView *)textView {

    return YES;
}
- (BOOL)textViewShouldEndEditing:(CJUITextView *)textView {
    return YES;
}

- (void)textViewDidBeginEditing:(CJUITextView *)textView {
    
}
- (void)textViewDidEndEditing:(CJUITextView *)textView {
    
}

- (BOOL)textView:(CJUITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}
- (void)textViewDidChange:(CJUITextView *)textView {
    
}

- (void)textViewDidChangeSelection:(CJUITextView *)textView {
    
}
@end
