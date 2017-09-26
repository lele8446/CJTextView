//
//  CJUITextView.h
//  TextViewDemo
//
//  Created by C.K.Lian on 16/6/26.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CJUITextView;
@class CJTextViewModel;

@protocol CJUITextViewDelegate <NSObject>

@optional
/**
 *  当textView.returnKeyType = UIReturnKeyDone时，点击done执行该回调
 *
 *  @param textView
 *
 *  @return
 */
- (void)CJUITextViewEnterDone:(CJUITextView *)textView;
/**
 *  CJUITextView自动改变高度
 *
 *  @param textView
 *  @param size     改变高度后的size
 */
- (void)CJUITextView:(CJUITextView *)textView heightChanged:(CGRect)frame;
/**
 *  placeHoldLabel是否显示
 *
 *  @param textView
 *  @param hidden
 */
- (void)CJUITextView:(CJUITextView *)textView placeHoldLabelHidden:(BOOL)hidden;
/**
 *  改变选中文本
 *
 *  @param textView
 *  @param selectedRange
 */
- (void)CJUITextView:(CJUITextView *)textView changeSelectedRange:(NSRange)selectedRange;

- (void)CJUITextView:(CJUITextView *)textView layoutDisplaySize:(CGSize)displaySize;

- (BOOL)CJUITextViewShouldBeginEditing:(CJUITextView *)textView;
- (BOOL)CJUITextViewShouldEndEditing:(CJUITextView *)textView;

- (void)CJUITextViewDidBeginEditing:(CJUITextView *)textView;
- (void)CJUITextViewDidEndEditing:(CJUITextView *)textView;

- (BOOL)CJUITextView:(CJUITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)CJUITextViewDidChange:(CJUITextView *)textView;

- (void)CJUITextViewDidChangeSelection:(CJUITextView *)textView;

- (BOOL)CJUITextView:(CJUITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0);
- (BOOL)CJUITextView:(CJUITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0);

- (BOOL)CJUITextView:(CJUITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange NS_DEPRECATED_IOS(7_0, 10_0, "Use textView:shouldInteractWithURL:inRange:forInteractionType: instead");
- (BOOL)CJUITextView:(CJUITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange NS_DEPRECATED_IOS(7_0, 10_0, "Use textView:shouldInteractWithURL:inRange:forInteractionType: instead");
@end

/**
 记录插入文本的索引
 */
extern NSString * const SPECIAL_TEXT_NUM __attribute__((deprecated("已废弃！！对应2.0.0版本之前的SPECIAL_TEXT_NUM宏，请使用-specialTextModelWithKey:相关方法获取插入文本")));

@interface CJUITextView : UITextView
/**
 注意!!!这里要实现的是myDelegate，而不是delegate代理
 */
@property (nonatomic, weak) id<UITextViewDelegate> delegate __attribute__((unavailable("这里要实现的是myDelegate，而不是delegate代理")));
/**
 代理
 */
@property (nonatomic, weak) id<CJUITextViewDelegate> myDelegate;
/**
 输入提示语
 */
@property (nonatomic, copy, setter=setPlaceHoldString:) NSString *placeHoldString;
/**
 提示语字体大小（默认取self.font）
 */
@property (nonatomic, strong, setter=setPlaceHoldTextFont:) UIFont *placeHoldTextFont;
/**
 提示语字体颜色（默认 [UIColor colorWithRed:0.498 green:0.498 blue:0.498 alpha:1.0]）
 */
@property (nonatomic, strong, setter=setPlaceHoldTextColor:) UIColor *placeHoldTextColor;
/**
 placeHold提示内容Insets值(默认 (4, 4, 4, 4))
 */
@property (nonatomic, assign, setter=setPlaceHoldContainerInset:) UIEdgeInsets placeHoldContainerInset;
/**
 是否根据输入内容自动调整高度(默认 NO)
 */
@property (nonatomic, assign, setter=setAutoLayoutHeight:) BOOL autoLayoutHeight;
/**
 autoLayoutHeight为YES时的最大高度(默认 MAXFLOAT)
 */
@property (nonatomic, assign) CGFloat maxHeight;
/**
 插入文本的颜色(默认取 self.textColor)
 */
@property (nonatomic, strong, getter=getSpecialTextColor) UIColor *specialTextColor;
/**
 插入文本是否可编辑(默认 NO)
 */
@property (nonatomic, assign) BOOL enableEditInsterText;

/**
 *  在指定位置插入字符，并返回插入字符后的SelectedRange值
 *
 *  @param specialText    要插入的字符
 *  @param selectedRange  插入位置
 *  @param attributedText 插入前的文本
 *
 *  @return 插入字符后的光标位置
 */
- (NSRange)insterSpecialTextAndGetSelectedRange:(NSAttributedString *)specialText
                                  selectedRange:(NSRange)selectedRange
                                           text:(NSAttributedString *)attributedText __deprecated_msg("Use -insertSpecialText:atIndex: instead");

/**
 在指定位置插入文本

 @param textModel 插入文本对象
 @param loc       插入位置
 @return          插入文本后的光标位置
 */
- (NSRange)insertSpecialText:(CJTextViewModel *)textModel atIndex:(NSUInteger)loc;

/**
 根据插入文本key获取插入文本数组
 
 @param specialStrKey 插入文本key
 @return              CJTextViewModel数组
 */
- (NSArray <CJTextViewModel *>*)insertTextModelWithKey:(NSString *)specialStrKey;

/**
 获取所有插入数组
 
 @return CJTextViewModel数组
 */
- (NSArray <CJTextViewModel *>*)allInsertTextModel;

/**
 获取所有文本model数组，包括输入的文本内容，顺序排列
 比如：textView.attributedText = @"测试内容1 @人名 #主题# 测试内容2"
 结果为：@[ 测试内容1,
          @人名,
          #主题#,
          测试内容2 ]
 
 @return  CJTextViewModel数组
 */
- (NSArray <CJTextViewModel *>*)allTextModel;

/**
 * dealloc方法时，主动移除CJUITextView内部的相关KVO监测
 * 请在该 CJUITextView 所在的 父view 或者 ViewController 中的 dealloc 方法中调用
 * 注意!!!  iOS9以下系统必须调用，不然会crash !!!
 * 注意!!!  iOS9以下系统必须调用，不然会crash !!!
 * 注意!!!  iOS9以下系统必须调用，不然会crash !!!
 */
- (void)removeObserver;

@end

/**
 编辑的文本对象model
 */
@interface CJTextViewModel : NSObject
/**
 标识插入文本的key
 */
@property (nonatomic, copy) NSString *specialKey;
/**
 文本range
 */
@property (nonatomic, assign) NSRange range;
/**
 编辑文本的NSAttributedString
 */
@property (nonatomic, strong) NSAttributedString *attrString;
/**
 文本自定义参数（针对插入内容，比如插入： @姓名，携带参数userID）
 */
@property (nonatomic, strong) id parameter;

+ (CJTextViewModel *)textViewModelKey:(NSString *)specialKey
                           attrString:(NSAttributedString *)attrString
                            parameter:(id)parameter;
@end;


