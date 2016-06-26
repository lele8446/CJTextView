//
//  CJUITextView.h
//  TextViewDemo
//
//  Created by YiChe on 16/6/26.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SPECIAL_TEXT @"specialText"

@class CJUITextView;

@protocol CJUITextViewDelegate <NSObject>

@optional

- (BOOL)textViewShouldBeginEditing:(CJUITextView *)textView;
- (BOOL)textViewShouldEndEditing:(CJUITextView *)textView;

- (void)textViewDidBeginEditing:(CJUITextView *)textView;
- (void)textViewDidEndEditing:(CJUITextView *)textView;

- (BOOL)textView:(CJUITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(CJUITextView *)textView;

- (void)textViewDidChangeSelection:(CJUITextView *)textView;

- (BOOL)textView:(CJUITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0);
- (BOOL)textView:(CJUITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0);

@end

@interface CJUITextView : UITextView

@property (nonatomic, weak) id<CJUITextViewDelegate> myDelegate;

@property (nonatomic, copy, setter=setPlaceHoldString:)   NSString *placeHoldString;
@property (nonatomic, strong, setter=setPlaceHoldTextFont:) UIFont *placeHoldTextFont;
@property (nonatomic, strong, setter=setPlaceHoldTextColor:) UIColor *placeHoldTextColor;

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
                                           text:(NSAttributedString *)attributedText;

@end
