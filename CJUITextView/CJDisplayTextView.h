//
//  CJDisplayTextView.h
//  TextViewDemo
//
//  Created by C.K.Lian on 16/6/26.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CJTextViewModel.h"

@interface CJDisplayTextView : UITextView
@property (nonatomic, getter=isEditable) BOOL editable __attribute__((unavailable("禁止修改，CJDisplayTextView只允许浏览模式")));
@property (nonatomic, weak) id<UITextViewDelegate> delegate __attribute__((unavailable("delegate不允许设置，点击交互可通过clickBlock、pressBlock回调实现")));

/**
 CJDisplayTextView的frame.size改变后的回调
 */
@property (nonatomic, copy) void(^displayViewLayoutBlock)(CGSize size);
/**
 自定义链点点击回调block
 */
@property (nonatomic, copy) void(^clickBlock)(CJTextViewModel *textModel);
/**
 自定义链点长按回调block
 */
@property (nonatomic, copy) void(^pressBlock)(CJTextViewModel *textModel);
/**
 NSURL交互回调block
 */
@property (nonatomic, copy) BOOL(^shouldInteractUrlBlock)(NSURL *url, NSRange range, UITextItemInteraction interaction);
/**
 NSTextAttachment交互回调block
 */
@property (nonatomic, copy) BOOL(^shouldInteractAttachmentBlock)(NSTextAttachment *textAttachment, NSRange range, UITextItemInteraction interaction);


/**
 生成自定义点击链点

 @param attStr    设置为点击链点的源NSAttributedString
 @param attrs     自定义属性
 @param parameter 自定义参数
 @return          NSAttributedString
 */
+ (NSAttributedString *)linkAttStr:(NSAttributedString *)attStr attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs parameter:(id)parameter;

/**
 根据文本内容计算CJDisplayTextView的size

 @param textSize 预计size
 @return CGSize
 */
- (CGSize)caculateTextViewSize:(CGSize)textSize;


@end
