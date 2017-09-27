//
//  CJDisplayTextView.h
//  TextViewDemo
//
//  Created by ChiJinLian on 2017/9/22.
//  Copyright © 2017年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CJDisplayTextView : UITextView
@property(nonatomic, getter=isEditable) BOOL editable __attribute__((unavailable("禁止修改，CJDisplayTextView只允许浏览模式")));
@property (nonatomic, copy) void(^displayViewLayoutBlock)(CGSize size);
@property (nonatomic, copy) void(^clickBlock)(NSAttributedString *linkAttstr, id parameter);
@property (nonatomic, copy) void(^pressBlock)(NSAttributedString *linkAttstr, id parameter);

+ (NSAttributedString *)linkStr:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs parameter:(id)parameter;
- (CGSize)caculateTextViewSize:(CGSize)textSize;


@end
