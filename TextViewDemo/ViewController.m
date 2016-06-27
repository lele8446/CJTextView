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
    // Do any additional setup after loading the view, typically from a nib.
    self.textView.placeHoldString = @"请输入...";
    self.textView.placeHoldTextFont = [UIFont systemFontOfSize:16];
    self.textView.myDelegate = self;
    self.textView.textView.textColor = [UIColor blueColor];
    self.textView.textView.font = [UIFont systemFontOfSize:16];
//    self.textView.textView.returnKeyType = UIReturnKeyDone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)handelText {
    
}


- (BOOL)isTheSameColor2:(UIColor*)color1 anotherColor:(UIColor*)color2 {
    if (CGColorEqualToColor(color1.CGColor, color2.CGColor)) {
        return YES;
    }else {
        return NO;
    }
}

- (IBAction)click:(id)sender {
    [self.textView becomeFirstResponder];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"#但双方#"];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.9737 green:0.2412 blue:0.1335 alpha:1.0] range:NSMakeRange(0,str.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, str.length)];
    [str addAttribute:SPECIAL_TEXT value:@"SPECIAL_TEXT" range:NSMakeRange(0, str.length)];
    self.textView.textView.selectedRange = [self.textView insterSpecialTextAndGetSelectedRange:str selectedRange:self.textView.textView.selectedRange text:self.textView.textView.attributedText];
}

#pragma mark - CJUITextViewDelegate
- (void)CJUITextViewEnterDone:(CJUITextView *)textView {
    NSAttributedString *text = textView.textView.attributedText;
    NSLog(@"text = %@",[text string]);
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
