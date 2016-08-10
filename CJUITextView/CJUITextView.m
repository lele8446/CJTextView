//
//  CJUITextView.m
//  TextViewDemo
//
//  Created by YiChe on 16/6/26.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#define SPECIAL_TEXT_NUM   @"specialTextNum"

#import "CJUITextView.h"

@interface CJUITextView()<UITextViewDelegate>
@property (nonatomic, strong) UILabel *placeHoldLabel;
@property (nonatomic, strong) NSMutableDictionary *defaultAttributes;
@property (nonatomic, assign) NSUInteger specialTextNum;//记录特殊文本的索引值
@property (nonatomic, assign) CGRect defaultFrame;//初始frame值

@end

@implementation CJUITextView

- (UILabel *)placeHoldLabel {
    if (!_placeHoldLabel) {
        _placeHoldLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_placeHoldLabel setBackgroundColor:[UIColor clearColor]];
        _placeHoldLabel.numberOfLines = 0;
        _placeHoldLabel.minimumScaleFactor = 0.01;
        _placeHoldLabel.adjustsFontSizeToFitWidth = YES;
        _placeHoldLabel.textAlignment = NSTextAlignmentLeft;
        _placeHoldLabel.font = self.font;
        _placeHoldLabel.textColor = [UIColor colorWithRed:0.498 green:0.498 blue:0.498 alpha:1.0];
        [self addSubview:_placeHoldLabel];
    }
    return _placeHoldLabel;
}

- (NSMutableDictionary *)defaultAttributes {
    if (!_defaultAttributes) {
        _defaultAttributes = [NSMutableDictionary dictionary];
        [_defaultAttributes setObject:self.font forKey:NSFontAttributeName];
        if (!self.textColor || self.textColor == nil) {
            self.textColor = [UIColor blackColor];
        }
        [_defaultAttributes setObject:self.textColor forKey:NSForegroundColorAttributeName];
    }
    return _defaultAttributes;
}

- (void)setPlaceHoldString:(NSString *)placeHoldString {
    _placeHoldString = placeHoldString;
    self.placeHoldLabel.text = placeHoldString;
}

- (void)setPlaceHoldTextFont:(UIFont *)placeHoldTextFont {
    _placeHoldTextFont = placeHoldTextFont;
    self.placeHoldLabel.font = placeHoldTextFont;
}

- (void)setPlaceHoldTextColor:(UIColor *)placeHoldTextColor {
    _placeHoldTextColor = placeHoldTextColor;
    self.placeHoldLabel.textColor = placeHoldTextColor;
}

- (void)setAutoLayoutHeight:(BOOL)autoLayoutHeight {
    _autoLayoutHeight = autoLayoutHeight;
    if (_autoLayoutHeight) {
        //高度自动调整的时候，不自动联想
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        if (self.maxHeight == 0) {
            self.maxHeight = MAXFLOAT;
        } 
    }else{
        self.autocorrectionType = UITextAutocorrectionTypeDefault;
    }
}

- (UIColor *)getSpecialTextColor {
    if (!_specialTextColor || nil == _specialTextColor) {
        _specialTextColor = self.textColor;
    }
    return _specialTextColor;
}

- (void)dealloc {
    self.delegate = nil;
    self.myDelegate = nil;
    [self removeObserver:self forKeyPath:@"selectedTextRange"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInitialize];
}

- (void)commonInitialize {
    self.specialTextNum = 1;
    self.delegate = self;
    self.layoutManager.allowsNonContiguousLayout = NO;
    [self addObserverForTextView];
    [self hiddenPlaceHoldLabel];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.defaultFrame = self.frame;
    [self placeHoldLabelFrame];
}

- (void)hiddenPlaceHoldLabel {
    if (self.text.length > 0 || self.attributedText.length > 0) {
        self.placeHoldLabel.hidden = YES;
    }else{
        self.placeHoldLabel.hidden = NO;
        [self placeHoldLabelFrame];
    }
}

- (void)placeHoldLabelFrame {
    CGFloat height = 24;
    if (height > self.defaultFrame.size.height-10) {
        height = self.defaultFrame.size.height-10;
        //文字内边距为0
//        self.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    self.placeHoldLabel.frame = CGRectMake(8,8, self.defaultFrame.size.width - 10, height);
    [self layoutIfNeeded];
    
    if (self.frame.size.height <= self.defaultFrame.size.height) {
        self.contentSize = CGSizeMake(self.defaultFrame.size.width, self.defaultFrame.size.height);
        [self layoutIfNeeded];
        self.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
        [self layoutIfNeeded];
    }
}

- (void)changeSize {
    CGRect oriFrame = self.frame;
    CGSize sizeToFit = [self sizeThatFits:CGSizeMake(oriFrame.size.width, MAXFLOAT)];
    if (sizeToFit.height < self.defaultFrame.size.height) {
        sizeToFit.height = self.defaultFrame.size.height;
    }
    if (oriFrame.size.height != sizeToFit.height && sizeToFit.height <= self.maxHeight) {
        oriFrame.size.height = sizeToFit.height;
        self.frame = oriFrame;
        
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextView:heightChanged:)]) {
            [self.myDelegate CJUITextView:self heightChanged:oriFrame];
        }
    }
    [self scrollRangeToVisible:NSMakeRange(self.text.length, 0)];
}

/**
 *  截取指定位置的富文本
 *
 *  @param attString 要截取的文本
 *  @param withRange 截取的位置
 *  @param attrs     截取文本的attrs属性
 *
 *  @return
 */
- (NSMutableAttributedString *)interceptString:(NSAttributedString *)attString
                                     withRange:(NSRange)withRange
                                     withAttrs:(NSDictionary *)attrs
{
    NSString *resultString = [attString.string substringWithRange:withRange];
    NSMutableAttributedString *resultAttStr = [[NSMutableAttributedString alloc]initWithString:resultString];
    [attString enumerateAttributesInRange:withRange options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:attrs];
        if (attrs[SPECIAL_TEXT_NUM] && [attrs[SPECIAL_TEXT_NUM] integerValue] != 0) {
            self.specialTextNum = self.specialTextNum > [attrs[SPECIAL_TEXT_NUM] integerValue]?self.specialTextNum:[attrs[SPECIAL_TEXT_NUM] integerValue];
            [dic setObject:self.specialTextColor forKey:NSForegroundColorAttributeName];
        }else{
            if (!self.textColor || self.textColor == nil) {
                self.textColor = [UIColor blackColor];
            }
            [dic setObject:self.textColor forKey:NSForegroundColorAttributeName];
        }
        [resultAttStr addAttributes:dic range:NSMakeRange(range.location-withRange.location, range.length)];
    }];
    return resultAttStr;
}

- (NSRange)insterSpecialTextAndGetSelectedRange:(NSAttributedString *)specialText
                                  selectedRange:(NSRange)selectedRange
                                           text:(NSAttributedString *)attributedText
{
    //针对输入时，文本内容为空，直接插入特殊文本的处理
    if (self.text.length == 0) {
        [self installStatus];
    }
    NSMutableAttributedString *specialTextAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:specialText];
    NSRange specialRange = NSMakeRange(0, specialText.length);
    NSDictionary *dicAtt = [specialText attributesAtIndex:0 effectiveRange:&specialRange];
    //设置默认字体属性
    UIFont *font = dicAtt[NSFontAttributeName];
    UIFont *defaultFont = [UIFont fontWithName:@"HelveticaNeue" size:12.0];//默认字体
    if ([font.fontName isEqualToString:defaultFont.fontName] && font.pointSize == defaultFont.pointSize) {
        font = self.font;
        [specialTextAttStr addAttribute:NSFontAttributeName value:font range:specialRange];
    }
    UIColor *color = dicAtt[NSForegroundColorAttributeName];
    if (!color || nil == color) {
        color = self.specialTextColor;
        [specialTextAttStr addAttribute:NSForegroundColorAttributeName value:color range:specialRange];
    }
    self.specialTextColor = color;
    
    NSMutableAttributedString *headTextAttStr = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *tailTextAttStr = [[NSMutableAttributedString alloc] init];
    //在文本中间
    if (selectedRange.location > 0 && selectedRange.location != attributedText.length) {
        //头部
        [attributedText enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, selectedRange.location) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            [headTextAttStr insertAttributedString:[self interceptString:attributedText withRange:range withAttrs:attrs] atIndex:0];
        }];
        //尾部
        [attributedText enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(selectedRange.location, attributedText.length-selectedRange.location) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            [tailTextAttStr insertAttributedString:[self interceptString:attributedText withRange:range withAttrs:attrs] atIndex:0];
        }];
    }
    //在文本首部
    else if (selectedRange.location == 0) {
        [attributedText enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(selectedRange.location, attributedText.length-selectedRange.location) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            [tailTextAttStr insertAttributedString:[self interceptString:attributedText withRange:range withAttrs:attrs] atIndex:0];
        }];
    }
    //在文本最后
    else if (selectedRange.location == attributedText.length) {
        [attributedText enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, selectedRange.location) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            [headTextAttStr insertAttributedString:[self interceptString:attributedText withRange:range withAttrs:attrs] atIndex:0];
        }];
    }
    
    //为插入文本增加SPECIAL_TEXT_NUM索引
    self.specialTextNum ++;
    [specialTextAttStr addAttribute:SPECIAL_TEXT_NUM value:@(self.specialTextNum) range:specialRange];
    
    NSMutableAttributedString *newTextStr = [[NSMutableAttributedString alloc] init];
    
    if (selectedRange.location > 0 && selectedRange.location != newTextStr.length) {
        [newTextStr appendAttributedString:headTextAttStr];
        [newTextStr appendAttributedString:specialTextAttStr];
        [newTextStr appendAttributedString:tailTextAttStr];
    }
    //在文本首部
    else if (selectedRange.location == 0) {
        [newTextStr appendAttributedString:specialTextAttStr];
        [newTextStr appendAttributedString:tailTextAttStr];
    }
    //在文本最后
    else if (selectedRange.location == newTextStr.length) {
        [newTextStr appendAttributedString:headTextAttStr];
        [newTextStr appendAttributedString:specialTextAttStr];
    }
    self.attributedText = newTextStr;
    NSRange newSelsctRange = NSMakeRange(selectedRange.location+specialTextAttStr.length, 0);
    self.selectedRange = newSelsctRange;
    return newSelsctRange;
}

//CJUITextView直接显示富文本需先设置一下初始值显示效果才有效
- (void)installStatus {
    NSMutableAttributedString *emptyTextStr = [[NSMutableAttributedString alloc] initWithString:@"1"];
    UIFont *font = self.font;
    [emptyTextStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, emptyTextStr.length)];
    if (!self.textColor || self.textColor == nil) {
        self.textColor = [UIColor blackColor];
    }
    [emptyTextStr addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, emptyTextStr.length)];
    self.attributedText = emptyTextStr;
    [emptyTextStr deleteCharactersInRange:NSMakeRange(0, emptyTextStr.length)];
    self.attributedText = emptyTextStr;
}

#pragma mark - Observer
static void *TextViewObserverSelectedTextRange = &TextViewObserverSelectedTextRange;
- (void)addObserverForTextView {
    [self addObserver:self
           forKeyPath:@"selectedTextRange"
              options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
              context:TextViewObserverSelectedTextRange];
}

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    if (context == TextViewObserverSelectedTextRange && [path isEqual:@"selectedTextRange"]){
        
        UITextRange *newContentStr = [change objectForKey:@"new"];
        UITextRange *oldContentStr = [change objectForKey:@"old"];
        NSRange newRange = [self selectedRange:self selectTextRange:newContentStr];
        NSRange oldRange = [self selectedRange:self selectTextRange:oldContentStr];
        if (newRange.location != oldRange.location) {
            //判断光标移动，光标不能处在特殊文本内
            [self.attributedText enumerateAttribute:SPECIAL_TEXT_NUM inRange:NSMakeRange(0, self.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
//                NSLog(@"range = %@",NSStringFromRange(range));
                if (attrs != nil && attrs != 0) {
                    if (newRange.location > range.location && newRange.location < (range.location+range.length)) {
                        //光标距离左边界的值
                        NSUInteger leftValue = newRange.location - range.location;
                        //光标距离右边界的值
                        NSUInteger rightValue = range.location+range.length - newRange.location;
                        if (leftValue >= rightValue) {
                            self.selectedRange = NSMakeRange(self.selectedRange.location-leftValue, 0);
                        }else{
                            self.selectedRange = NSMakeRange(self.selectedRange.location+rightValue, 0);
                        }
                    }
                }
                
            }];
        }
    }
    self.typingAttributes = self.defaultAttributes;
}

/**
 *  UITextRange转换为NSRange
 *
 *  @param textView
 *  @param selectedTextRange
 *
 *  @return
 */
- (NSRange)selectedRange:(UITextView *)textView selectTextRange:(UITextRange *)selectedTextRange {
    UITextPosition* beginning = textView.beginningOfDocument;
    UITextRange* selectedRange = selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    const NSInteger location = [textView offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [textView offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        return [self.myDelegate textViewShouldBeginEditing:self];
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
        return [self.myDelegate textViewShouldEndEditing:self];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        [self.myDelegate textViewDidBeginEditing:self];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
        [self.myDelegate textViewDidEndEditing:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.typingAttributes = self.defaultAttributes;
    if ([text isEqualToString:@""]) {//删除
        __block BOOL deleteSpecial = NO;
        NSRange oldRange = textView.selectedRange;
        
        [textView.attributedText enumerateAttribute:SPECIAL_TEXT_NUM inRange:NSMakeRange(0, textView.selectedRange.location) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            NSRange deleteRange = NSMakeRange(textView.selectedRange.location-1, 0) ;
            if (attrs != nil && attrs != 0) {
                if (deleteRange.location > range.location && deleteRange.location < (range.location+range.length)) {
                    NSMutableAttributedString *textAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
                    [textAttStr deleteCharactersInRange:range];
                    textView.attributedText = textAttStr;
                    deleteSpecial = YES;
                    textView.selectedRange = NSMakeRange(oldRange.location-range.length, 0);
                    *stop = YES;
                }
            }
        }];
        return !deleteSpecial;
    }
    
    //输入了done
    if ([text isEqualToString:@"\n"]) {
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewEnterDone:)]) {
            [self.myDelegate CJUITextViewEnterDone:self];
        }
        if (self.returnKeyType == UIReturnKeyDone) {
            [self resignFirstResponder];
            return NO;
        }
    }
    
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return [self.myDelegate textView:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.myDelegate textViewDidChange:self];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (self.autoLayoutHeight) {
        [self changeSize];
    }else{
        [self scrollRangeToVisible:NSMakeRange(self.text.length, 0)];
    }
    [self hiddenPlaceHoldLabel];
    self.typingAttributes = self.defaultAttributes;
    
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [self.myDelegate textViewDidChangeSelection:self];
    }
}

- (BOOL)textView:(CJUITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)]) {
        return [self.myDelegate textView:self shouldInteractWithURL:URL inRange:characterRange];
    }
    return YES;
}
- (BOOL)textView:(CJUITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)]) {
        return [self.myDelegate textView:self shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    }
    return YES;
}

@end