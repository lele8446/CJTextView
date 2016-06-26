//
//  CJUITextView.m
//  TextViewDemo
//
//  Created by YiChe on 16/6/26.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "CJUITextView.h"

@interface CJUITextView()<UITextViewDelegate>
@property (nonatomic, strong) UILabel *placeHoldLabel;


@end

@implementation CJUITextView

- (UILabel *)placeHoldLabel {
    if (!_placeHoldLabel) {
        CGFloat height = 30;
        height = height>self.bounds.size.height?self.bounds.size.height:height;
        _placeHoldLabel = [[UILabel alloc] initWithFrame:CGRectMake(4,0, self.bounds.size.width - 8, height)];
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

- (void)dealloc {
    self.delegate = nil;
    self.myDelegate = nil;
    [self removeObserver:self forKeyPath:@"selectedTextRange"];
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
    self.delegate = self;
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
            [dic setObject:[UIColor colorWithRed:0.1892 green:0.2526 blue:1.0 alpha:1.0] forKey:NSForegroundColorAttributeName];
        }
        [resultAttStr addAttributes:dic range:NSMakeRange(range.location-withRange.location, range.length)];
    }];
    return resultAttStr;
}

- (void)handelTextViewText:(NSAttributedString *)text {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:text];
    [text enumerateAttributesInRange:NSMakeRange(0,text.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:attrs];
        if (attrs[SPECIAL_TEXT]) {
            [dic setObject:[UIColor colorWithRed:0.9737 green:0.2412 blue:0.1335 alpha:1.0] forKey:NSForegroundColorAttributeName];
        }else{
            [dic setObject:[UIColor colorWithRed:0.1892 green:0.2526 blue:1.0 alpha:1.0] forKey:NSForegroundColorAttributeName];
        }
        [str addAttributes:dic range:range];
    }];
    self.attributedText = str;
//    self.selectedRange = NSMakeRange(str.length,0);
}

- (NSRange)insterSpecialTextAndGetSelectedRange:(NSAttributedString *)specialText
                                  selectedRange:(NSRange)selectedRange
                                           text:(NSAttributedString *)attributedText
{
    NSMutableAttributedString *textStr = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    NSRange headRange = selectedRange;
    
    NSMutableAttributedString *headTextAttStr = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *tailTextAttStr = [[NSMutableAttributedString alloc] init];
    //在文本中间
    if (headRange.location > 0 && headRange.location != textStr.length) {
        //头部
        [textStr enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, headRange.location) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            [headTextAttStr insertAttributedString:[self interceptString:textStr withRange:range withAttrs:attrs] atIndex:0];
        }];
        //尾部
        [textStr enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(headRange.location, textStr.length-headRange.location) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            [tailTextAttStr insertAttributedString:[self interceptString:textStr withRange:range withAttrs:attrs] atIndex:0];
        }];
    }
    //在文本首部
    else if (headRange.location == 0) {
        [textStr enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(headRange.location, textStr.length-headRange.location) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            [tailTextAttStr insertAttributedString:[self interceptString:textStr withRange:range withAttrs:attrs] atIndex:0];
        }];
    }
    //在文本最后
    else if (headRange.location == textStr.length) {
        [textStr enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, headRange.location) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            [headTextAttStr insertAttributedString:[self interceptString:textStr withRange:range withAttrs:attrs] atIndex:0];
        }];
    }
    
    NSMutableAttributedString *newTextStr = [[NSMutableAttributedString alloc] init];
    
    if (headRange.location > 0 && headRange.location != newTextStr.length) {
        [newTextStr appendAttributedString:headTextAttStr];
        [newTextStr appendAttributedString:specialText];
        [newTextStr appendAttributedString:tailTextAttStr];
    }
    //在文本首部
    else if (headRange.location == 0) {
        [newTextStr appendAttributedString:specialText];
        [newTextStr appendAttributedString:tailTextAttStr];
    }
    //在文本最后
    else if (headRange.location == newTextStr.length) {
        [newTextStr appendAttributedString:headTextAttStr];
        [newTextStr appendAttributedString:specialText];
    }
    [self handelTextViewText:newTextStr];
    NSRange newSelsctRange = NSMakeRange(selectedRange.location+specialText.length, 0);
    return newSelsctRange;
}

- (void)hiddenPlaceHoldLabel {
    if (self.text.length > 0 || self.attributedText.length > 0) {
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
//    UITextView *textView = notification.object;
    
//    [self handelTextViewText:textView.attributedText];
    [self hiddenPlaceHoldLabel];
}

#pragma mark - ObserverContentOffset
static void *TextViewObservationContext = &TextViewObservationContext;
- (void)addObserverForTextView {
    [self addObserver:self
           forKeyPath:@"selectedTextRange"
              options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
              context:TextViewObservationContext];
}

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    NSString *newContentStr = [change objectForKey:@"new"];
    NSString *oldContentStr = [change objectForKey:@"old"];
    NSLog(@"newContentStr =%@",newContentStr);
    NSLog(@"oldContentStr =%@",oldContentStr);
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
    [self handelTextViewText:textView.attributedText];
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
