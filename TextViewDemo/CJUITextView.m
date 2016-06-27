//
//  CJUITextView.m
//  TextViewDemo
//
//  Created by YiChe on 16/6/26.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "CJUITextView.h"
#define SPECIAL_TEXT_NUM @"specialTextNum"

@interface CJUITextView()<UITextViewDelegate>
@property (nonatomic, strong) UILabel *placeHoldLabel;
@property (nonatomic, strong) NSMutableDictionary *defaultAttributes;
@property (nonatomic, assign) NSUInteger specialTextNum;//记录特殊文本的索引值

@end

@implementation CJUITextView

- (BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc]initWithFrame:self.bounds];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        _textView.autocorrectionType = UITextAutocorrectionTypeNo;
        [self addSubview:_textView];
    }
    return _textView;
}

- (UILabel *)placeHoldLabel {
    if (!_placeHoldLabel) {
        CGFloat height = 30;
        height = height>self.bounds.size.height?self.bounds.size.height:height;
        _placeHoldLabel = [[UILabel alloc] initWithFrame:CGRectMake(4,1, self.bounds.size.width - 8, height)];
        [_placeHoldLabel setBackgroundColor:[UIColor clearColor]];
        _placeHoldLabel.numberOfLines = 0;
        _placeHoldLabel.minimumScaleFactor = 0.5;
        _placeHoldLabel.adjustsFontSizeToFitWidth = YES;
        _placeHoldLabel.textAlignment = NSTextAlignmentLeft;
        _placeHoldLabel.font = [UIFont systemFontOfSize:15];
        _placeHoldLabel.textColor = [UIColor colorWithRed:0.498 green:0.498 blue:0.498 alpha:1.0];
        _placeHoldLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_placeHoldLabel];
    }
    return _placeHoldLabel;
}

- (NSMutableDictionary *)defaultAttributes {
    if (!_defaultAttributes) {
        _defaultAttributes = [NSMutableDictionary dictionary];
        [_defaultAttributes setObject:self.textView.font forKey:NSFontAttributeName];
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

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.textView.textColor = textColor;
}

- (void)dealloc {
    self.textView.delegate = nil;
    self.myDelegate = nil;
    [self.textView removeObserver:self forKeyPath:@"selectedTextRange"];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
    self.textView.delegate = self;
    [self addObserverForTextView];
    [self addTextDidChangeNotification];
    [self hiddenPlaceHoldLabel];
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
        if (attrs[SPECIAL_TEXT]) {
            [dic setObject:[UIColor colorWithRed:0.9737 green:0.2412 blue:0.1335 alpha:1.0] forKey:NSForegroundColorAttributeName];
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
    //针对输入时直接插入特殊文本的处理
    if (self.textView.text.length == 0) {
        [self.textView becomeFirstResponder];
        NSMutableAttributedString *emptyTextStr = [[NSMutableAttributedString alloc] initWithString:@"1"];
        UIFont *font = self.textView.font;
        [emptyTextStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, emptyTextStr.length)];
        if (!self.textColor || self.textColor == nil) {
            self.textColor = [UIColor blackColor];
        }
        [emptyTextStr addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, emptyTextStr.length)];
        self.textView.attributedText = emptyTextStr;
        [emptyTextStr deleteCharactersInRange:NSMakeRange(0, emptyTextStr.length)];
        self.textView.attributedText = emptyTextStr;
    }

    NSMutableAttributedString *specialTextAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:specialText];
    NSRange specialRange = NSMakeRange(0, specialText.length);
    NSDictionary *dicAtt = [specialText attributesAtIndex:0 effectiveRange:&specialRange];
    //设置默认字体属性
    UIFont *font = dicAtt[NSFontAttributeName];
    if (!font || nil == font) {
        font = self.textView.font;
        [specialTextAttStr addAttribute:NSFontAttributeName value:font range:specialRange];
    }
    [specialTextAttStr addAttribute:SPECIAL_TEXT_NUM value:@(self.specialTextNum) range:specialRange];
    self.specialTextNum ++;
    
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
    self.textView.attributedText = newTextStr;
    self.textView.typingAttributes = self.defaultAttributes;
    NSRange newSelsctRange = NSMakeRange(selectedRange.location+specialTextAttStr.length, 0);
    return newSelsctRange;
}

- (void)hiddenPlaceHoldLabel {
    if (self.textView.text.length > 0 || self.textView.attributedText.length > 0) {
        self.placeHoldLabel.hidden = YES;
    }else{
        self.placeHoldLabel.hidden = NO;
    }
}

#pragma mark - NSNotificationCenter
- (void)addTextDidChangeNotification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
}

- (void)textChanged:(NSNotification *)notification {
    self.textView.typingAttributes = self.defaultAttributes;
    [self hiddenPlaceHoldLabel];
}

#pragma mark - ObserverContentOffset
static void *TextViewObservationContext = &TextViewObservationContext;
- (void)addObserverForTextView {
    [self.textView addObserver:self
                    forKeyPath:@"selectedTextRange"
                       options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                       context:TextViewObservationContext];
}

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    UITextRange *newContentStr = [change objectForKey:@"new"];
    UITextRange *oldContentStr = [change objectForKey:@"old"];
    NSRange newRange = [self selectedRange:self.textView selectTextRange:newContentStr];
    NSRange oldRange = [self selectedRange:self.textView selectTextRange:oldContentStr];

    self.textView.typingAttributes = self.defaultAttributes;
    
    if (context == TextViewObservationContext && [path isEqual:@"selectedTextRange"] && (newRange.location != oldRange.location)){
        //判断光标移动，光标不能处在特殊文本内
        [self.textView.attributedText enumerateAttribute:SPECIAL_TEXT_NUM inRange:NSMakeRange(0, self.textView.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
//            NSLog(@"range = %@",NSStringFromRange(range));
            if (attrs != nil && attrs != 0) {
                if (newRange.location > range.location && newRange.location < (range.location+range.length)) {
                    //光标距离左边界的值
                    NSUInteger leftValue = newRange.location - range.location;
                    //光标距离右边界的值
                    NSUInteger rightValue = range.location+range.length - newRange.location;
                    if (leftValue >= rightValue) {
                        self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location-leftValue, 0);
                    }else{
                        self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location+rightValue, 0);
                    }
                }
            }

        }];
    }
}

- (BOOL)isTheSameColor2:(UIColor*)color1 anotherColor:(UIColor*)color2 {
    if (CGColorEqualToColor(color1.CGColor, color2.CGColor)) {
        return YES;
    }
    else {
        return NO;
    }
}

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
    if ([text isEqualToString:@""]) {
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
        if (self.textView.returnKeyType == UIReturnKeyDone) {
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
    [self hiddenPlaceHoldLabel];
    self.textView.typingAttributes = self.defaultAttributes;
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
