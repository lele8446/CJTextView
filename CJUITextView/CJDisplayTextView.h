//
//  CJDisplayTextView.h
//  TextViewDemo
//
//  Created by C.K.Lian on 16/6/26.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CJTextViewModel.h"

/**
 CJDisplayTextView功能概要：
 1、只支持浏览模式，不允许编辑。
 2、可以根据显示内容动态调整高度，并自动识别网址、日期、地址、电话，点击则触发系统默认行为；
 3、允许插入自定义点击链点，自定义链点请通过类方法`+linkStr:attributes:parameter:`生成，点击自定义链点会触发点击回调block和长按回调（长按只支持iOS10之后的系统）。
 相关链接https://github.com/lele8446/TextViewDemo
 */
@interface CJDisplayTextView : UITextView
@property (nonatomic, getter=isEditable) BOOL editable __attribute__((unavailable("禁止修改，CJDisplayTextView只允许浏览模式")));
@property (nonatomic, weak) id<UITextViewDelegate> delegate __attribute__((unavailable("delegate不允许设置，点击交互可通过clickBlock、pressBlock回调实现")));

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
 点击CJDisplayTextView的回调（点击URL、NSTextAttachment、自定义链点、复制选择等，不会触发该回调）
 */
@property (nonatomic, copy) void(^clickDisplayViewBlock)();


/**
 生成自定义点击链点

 @param attStr               设置为点击链点的源NSAttributedString
 @param attrs                自定义属性
 @param afterClickAttributes 点击后的自定义属性
 @param parameter            自定义参数
 @return                     NSAttributedString
 */
+ (NSAttributedString *)linkAttStr:(NSAttributedString *)attStr
                        attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs
              afterClickAttributes:(NSDictionary<NSAttributedStringKey, id> *)afterClickAttributes
                         parameter:(id)parameter;

/**
 根据文本内容计算CJDisplayTextView的size

 @param textSize 预计size
 @return CGSize
 */
- (CGSize)caculateTextViewSize:(CGSize)textSize;


@end

