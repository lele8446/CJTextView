//
//  CJDisplayTextView.m
//  TextViewDemo
//
//  Created by ChiJinLian on 2017/9/22.
//  Copyright © 2017年 YiChe. All rights reserved.
//

#import "CJDisplayTextView.h"

@interface CJDisplayTextView ()

@end

@implementation CJDisplayTextView

@synthesize editable = _editable;

- (void)setEditable:(BOOL)editable {
    [super setEditable:NO];
}

- (BOOL)isEditable {
    return NO;
}
//CGSize textSize = [self caculateTextViewSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
//self.bounds = CGRectMake(0, 0, self.frame.size.width, textSize.height);
//self.textContainer.size = textSize;
//[self scrollRangeToVisible:NSMakeRange(0,0)];
//if([self.myDelegate respondsToSelector:@selector(CJUITextView:layoutDisplaySize:)]) {
//    [self.myDelegate CJUITextView:self layoutDisplaySize:textSize];
//}

@end

@implementation CJTextAttachment

@end

