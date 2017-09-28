//
//  CJUITextView.m
//  TextViewDemo
//
//  Created by C.K.Lian on 16/6/26.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import "CJUITextView.h"

#define CJTextViewIsNull(a) ((a)==nil || (a)==NULL || (NSNull *)(a)==[NSNull null])

NSString * const SPECIAL_TEXT_NUM = @"SPECIAL_TEXT_NUM";

//标记插入文本的索引值
NSString * const kCJInsterSpecialTextKeyAttributeName         = @"kCJInsterSpecialTextKeyAttributeName";
//标记相同的插入文本
NSString * const kCJInsterSpecialTextKeyGroupAttributeName    = @"kCJInsterSpecialTextKeyGroupAttributeName";
//标记插入文本的range
NSString * const kCJInsterSpecialTextRangeAttributeName       = @"kCJInsterSpecialTextRangeAttributeName";
//标记插入文本的自定义参数
NSString * const kCJInsterSpecialTextParameterAttributeName   = @"kCJInsterSpecialTextParameterAttributeName";
//标记正常编辑的文本
NSString * const kCJTextAttributeName                         = @"kCJTextAttributeName";
//标记未设置标志符的插入文本
NSString * const kCJInsterDefaultGroupAttributeName           = @"kCJInsterDefaultGroupAttributeName";

@interface CJUITextView()<UITextViewDelegate>
{
    BOOL _hasRemoveObserver;
    BOOL _shouldChangeText;
    BOOL _enterDone;
    BOOL _afterLayout;
}
@property (nonatomic, strong) UILabel *placeHoldLabel;
@property (nonatomic, assign) BOOL placeHoldLabelHidden;
@property (nonatomic, strong) NSDictionary *defaultAttributes;
@property (nonatomic, assign) NSUInteger specialTextNum;//记录特殊文本的索引值
@property (nonatomic, assign) CGRect defaultFrame;//初始frame值
@property (nonatomic, assign) int addObserverTime;//注册KVO的次数

@end

@implementation CJUITextView
@dynamic delegate;

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

- (void)setPlaceHoldContainerInset:(UIEdgeInsets)placeHoldContainerInset {
    _placeHoldContainerInset = placeHoldContainerInset;
    [self placeHoldLabelFrame];
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
        if (self.maxHeight == 0) {
            self.maxHeight = MAXFLOAT;
        }
        self.layoutManager.allowsNonContiguousLayout = NO;
    }
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setPlaceHoldTextFont:font];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    self.typingAttributes = self.defaultAttributes;
    [super setAttributedText:attributedText];
}

- (UIColor *)getSpecialTextColor {
    if (!_specialTextColor || nil == _specialTextColor) {
        _specialTextColor = self.textColor;
    }
    return _specialTextColor;
}

- (void)dealloc {
    self.myDelegate = nil;
    
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (iOSVersion >= 9.0 && !_hasRemoveObserver) {
        [self removeObserver];
    }
    
    if (!_hasRemoveObserver) {
        [self removeObserver];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.specialTextNum = 1;
    self.placeHoldContainerInset = UIEdgeInsetsMake(4, 4, 4, 4);
    self.font = [UIFont systemFontOfSize:14];
    self.defaultFrame = CGRectNull;
    self.defaultAttributes = self.typingAttributes;
    //由于delegate 被声明为 unavailable，这里只能通过kvc的方式设置了
    [self setValue:self forKey:@"delegate"];
    [self addObserverForTextView];
    [self hiddenPlaceHoldLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_afterLayout) {
        self.defaultFrame = self.frame;
        [self placeHoldLabelFrame];
    }
}

- (void)hiddenPlaceHoldLabel {
    if (self.text.length > 0 || self.attributedText.length > 0) {
        self.placeHoldLabel.hidden = YES;
    }else{
        self.placeHoldLabel.hidden = NO;
    }
    if (self.placeHoldLabelHidden != self.placeHoldLabel.hidden) {
        self.placeHoldLabelHidden = self.placeHoldLabel.hidden;
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextView:placeHoldLabelHidden:)]) {
            [self.myDelegate CJUITextView:self placeHoldLabelHidden:self.placeHoldLabel.hidden];
        }
    }
}

- (void)placeHoldLabelFrame {
    CGFloat height = 24;
    if (height > self.defaultFrame.size.height-self.placeHoldContainerInset.top-self.placeHoldContainerInset.bottom) {
        height = self.defaultFrame.size.height-self.placeHoldContainerInset.top-self.placeHoldContainerInset.bottom;
    }
    self.placeHoldLabel.frame = CGRectMake(self.placeHoldContainerInset.left,self.placeHoldContainerInset.top, self.defaultFrame.size.width - self.placeHoldContainerInset.left-self.placeHoldContainerInset.right, height);
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
        [self layoutIfNeeded];
    }
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
        if (attrs[kCJInsterSpecialTextKeyAttributeName] && ![attrs[kCJInsterSpecialTextKeyAttributeName] isEqualToString:kCJTextAttributeName]) {
            self.specialTextNum = self.specialTextNum > [attrs[kCJInsterSpecialTextKeyAttributeName] hash]?self.specialTextNum:[attrs[kCJInsterSpecialTextKeyAttributeName] hash];
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

- (NSMutableAttributedString *)instertAttributedString:(NSAttributedString *)attStr {
    if (attStr.length == 0) {
        return [[NSMutableAttributedString alloc] init];
    }
    NSMutableAttributedString *specialTextAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
    NSRange specialRange = NSMakeRange(0, attStr.length);
    NSDictionary *dicAtt = [attStr attributesAtIndex:0 effectiveRange:&specialRange];
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
    return specialTextAttStr;
}

- (NSRange)insterSpecialTextAndGetSelectedRange:(NSAttributedString *)specialText
                                  selectedRange:(NSRange)selectedRange
                                           text:(NSAttributedString *)attributedText
{
    //针对输入时，文本内容为空，直接插入特殊文本的处理
    if (self.text.length == 0) {
        [self installStatus];
    }
    NSMutableAttributedString *specialTextAttStr = [self instertAttributedString:specialText];
    
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
    [specialTextAttStr addAttribute:kCJInsterSpecialTextKeyAttributeName value:[NSString stringWithFormat:@"%@",@(self.specialTextNum)] range:NSMakeRange(0, specialTextAttStr.length)];
    
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
    if (self.autoLayoutHeight) {
        [self changeSize];
    }
    [self scrollRangeToVisible:NSMakeRange(self.selectedRange.location+self.selectedRange.length, 0)];
    return newSelsctRange;
}

- (NSRange)insertSpecialText:(CJTextViewModel *)textModel atIndex:(NSUInteger)loc {
    //针对输入时，文本内容为空，直接插入特殊文本的处理
    if (self.text.length == 0) {
        [self installStatus];
    }
    
    if (self.attributedText.length == 0) {
        loc = 0;
    }else{
        if (loc >= self.attributedText.length) {
            loc = self.attributedText.length;
        }
    }

    NSMutableAttributedString *textAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:[self handleEditTextModel]];
    
    NSRange selectedRange = self.selectedRange;
    
    NSMutableAttributedString *insertTextAttStr = [self instertAttributedString:textModel.attrString];
    NSString *insertKeyGroup = (textModel.insertIdentifier && textModel.insertIdentifier.length > 0)?textModel.insertIdentifier:kCJInsterDefaultGroupAttributeName;
    [insertTextAttStr addAttribute:kCJInsterSpecialTextKeyGroupAttributeName value:insertKeyGroup range:NSMakeRange(0, insertTextAttStr.length)];
    //插入key
    NSString *insertKey = [NSUUID UUID].UUIDString;
    [insertTextAttStr addAttribute:kCJInsterSpecialTextKeyAttributeName value:insertKey range:NSMakeRange(0, insertTextAttStr.length)];
    //插入range
    NSRange insertRange = NSMakeRange(loc, insertTextAttStr.length);
    [insertTextAttStr addAttribute:kCJInsterSpecialTextRangeAttributeName value:NSStringFromRange(insertRange) range:NSMakeRange(0, insertTextAttStr.length)];
    //插入参数
    if (textModel.parameter) {
        [insertTextAttStr addAttribute:kCJInsterSpecialTextParameterAttributeName value:textModel.parameter range:NSMakeRange(0, insertTextAttStr.length)];
    }
    
    [textAttStr insertAttributedString:insertTextAttStr atIndex:loc];
    self.attributedText = textAttStr;
    NSRange newSelsctRange = NSMakeRange(selectedRange.location+selectedRange.length+insertTextAttStr.length, 0);
    if (self.autoLayoutHeight) {
        [self changeSize];
    }
    [self scrollRangeToVisible:NSMakeRange(newSelsctRange.location+newSelsctRange.length, 0)];
    self.selectedRange = newSelsctRange;
    return newSelsctRange;
}

- (NSArray <CJTextViewModel *>*)insertTextModelWithIdentifier:(NSString *)identifier {
    __block NSArray *array = @[];
    //遍历相同的KeyGroup
    [self.attributedText enumerateAttribute:kCJInsterSpecialTextKeyGroupAttributeName inRange:NSMakeRange(0, self.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        NSMutableAttributedString *rangeText = [[NSMutableAttributedString alloc]initWithAttributedString:[self.attributedText attributedSubstringFromRange:range]];
        NSRange rangeTextRange = NSMakeRange(0, rangeText.length);
        NSDictionary* dicAtt = @{};
        if (!NSEqualRanges(rangeTextRange,NSMakeRange(0, 0))) {
            dicAtt = [rangeText attributesAtIndex:0 effectiveRange:&rangeTextRange];
        }
        if (dicAtt.count > 0) {
            NSString *keyGroup = dicAtt[kCJInsterSpecialTextKeyGroupAttributeName];
            if (keyGroup.length > 0 && identifier.length > 0) {
                if ([keyGroup isEqualToString:identifier]) {
                    array = [self textModelFromAttributedString:rangeText insert:YES rangeTextRange:rangeTextRange];
                }
            }
        }
    }];
    return array;
}

- (NSArray <CJTextViewModel *>*)allInsertTextModel {
    NSArray *array = [self textModelFromAttributedString:self.attributedText insert:YES rangeTextRange:NSMakeRange(0, self.attributedText.length)];
    return array;
}

- (NSArray <CJTextViewModel *>*)allTextModel {
    NSArray *array = [self textModelFromAttributedString:self.attributedText insert:NO rangeTextRange:NSMakeRange(0, self.attributedText.length)];
    return array;
}

- (NSArray <CJTextViewModel *>*)textModelFromAttributedString:(NSAttributedString *)attributedString
                                                       insert:(BOOL)insert
                                               rangeTextRange:(NSRange)rangeTextRange
{
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    [attributedString enumerateAttribute:kCJInsterSpecialTextKeyAttributeName inRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        NSString *key = (NSString *)attrs;
        BOOL condition = NO;
        if (insert) {
            condition = (key.length > 0 && ![key isEqualToString:kCJTextAttributeName]);
        }else{
            condition = key.length > 0;
        }
        if (condition) {
            
            NSMutableAttributedString *sText = [[NSMutableAttributedString alloc]initWithAttributedString:[attributedString attributedSubstringFromRange:range]];
            
            NSDictionary *modelAttrs = [sText attributesAtIndex:0 effectiveRange:&range];
            NSString *specialStrKey = modelAttrs[kCJInsterSpecialTextKeyGroupAttributeName];
            NSString *rangeStr = modelAttrs[kCJInsterSpecialTextRangeAttributeName];
            id parameter = modelAttrs[kCJInsterSpecialTextParameterAttributeName];
            
            NSRange modelRange = NSMakeRange(rangeTextRange.location+range.location, range.length);
            if (rangeStr.length > 0) {
                modelRange = NSRangeFromString(rangeStr);
            }
            CJTextViewModel *model = [CJTextViewModel modelWithIdentifier:specialStrKey attrString:sText parameter:parameter];
            model.range = modelRange;
            model.isInsertText = ![key isEqualToString:kCJTextAttributeName];
            
            [array insertObject:model atIndex:0];
        }
    }];
    return array;
}

- (NSAttributedString *)handleEditTextModel {
    NSMutableAttributedString *textAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [textAttStr.string enumerateSubstringsInRange:NSMakeRange(0, [textAttStr.string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         NSDictionary *dicAtt = [textAttStr attributesAtIndex:substringRange.location effectiveRange:&substringRange];
         if (CJTextViewIsNull(dicAtt[kCJInsterSpecialTextKeyAttributeName])) {
             [textAttStr addAttribute:kCJInsterSpecialTextKeyAttributeName value:kCJTextAttributeName range:substringRange];
         }
     }];
    self.attributedText = textAttStr;
    return textAttStr;
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

- (void)removeObserver {
    id obser = self.observationInfo;
    if (obser) {
        @try {
            [self removeObserver:self forKeyPath:@"selectedTextRange" context:TextViewObserverSelectedTextRange];
        } @catch (NSException *exception) {
        } @finally {
            
        }
    }
    _hasRemoveObserver = YES;
}

#pragma mark - Observer
static void *TextViewObserverSelectedTextRange = &TextViewObserverSelectedTextRange;
- (void)addObserverForTextView {
    //确保KVO只注册一次
    if (self.addObserverTime >= 1) {
        return;
    }
    [self addObserver:self
           forKeyPath:@"selectedTextRange"
              options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
              context:TextViewObserverSelectedTextRange];
    self.addObserverTime ++;
}

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    if (context == TextViewObserverSelectedTextRange && [path isEqual:@"selectedTextRange"] && !self.enableEditInsterText){
        
        UITextRange *newContentStr = [change objectForKey:@"new"];
        UITextRange *oldContentStr = [change objectForKey:@"old"];
        if (!CJTextViewIsNull(newContentStr) && !CJTextViewIsNull(oldContentStr)) {
            NSRange newRange = [self selectedRange:self selectTextRange:newContentStr];
            NSRange oldRange = [self selectedRange:self selectTextRange:oldContentStr];
            if (newRange.location != oldRange.location) {
                //判断光标移动，光标不能处在特殊文本内
                [self.attributedText enumerateAttribute:kCJInsterSpecialTextKeyAttributeName inRange:NSMakeRange(0, self.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                    NSString *key = (NSString *)attrs;
                    if (key && ![key isEqualToString:kCJTextAttributeName]) {
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
    }else{
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
    self.typingAttributes = self.defaultAttributes;
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextView:changeSelectedRange:)]) {
        [self.myDelegate CJUITextView:self changeSelectedRange:self.selectedRange];
    }
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
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewShouldBeginEditing:)]) {
        return [self.myDelegate CJUITextViewShouldBeginEditing:self];
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewShouldEndEditing:)]) {
        return [self.myDelegate CJUITextViewShouldEndEditing:self];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewDidBeginEditing:)]) {
        [self.myDelegate CJUITextViewDidBeginEditing:self];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [self handleEditTextModel];
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewDidEndEditing:)]) {
        [self.myDelegate CJUITextViewDidEndEditing:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _shouldChangeText = YES;
    self.typingAttributes = self.defaultAttributes;
    if ([text isEqualToString:@""] && !self.enableEditInsterText) {//删除
        __block BOOL deleteSpecial = NO;
        NSRange oldRange = textView.selectedRange;
        
        [textView.attributedText enumerateAttribute:kCJInsterSpecialTextKeyAttributeName inRange:NSMakeRange(0, textView.selectedRange.location) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            NSRange deleteRange = NSMakeRange(textView.selectedRange.location-1, 0) ;
            NSString *key = (NSString *)attrs;
            if (key && ![key isEqualToString:kCJTextAttributeName]) {
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
    
    _enterDone = NO;
    //输入了done
    if ([text isEqualToString:@"\n"]) {
        _enterDone = YES;
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewEnterDone:)]) {
            [self.myDelegate CJUITextViewEnterDone:self];
        }
        if (self.returnKeyType == UIReturnKeyDone) {
            [self resignFirstResponder];
            return NO;
        }
    }
    
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextView:shouldChangeTextInRange:replacementText:)]) {
        return [self.myDelegate CJUITextView:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewDidChange:)]) {
        [self.myDelegate CJUITextViewDidChange:self];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    _afterLayout = YES;
    self.typingAttributes = self.defaultAttributes;
    if (_shouldChangeText) {
        if (self.autoLayoutHeight) {
            [self changeSize];
        }else{
            textView.layoutManager.allowsNonContiguousLayout = YES;
            if ((self.selectedRange.location+self.selectedRange.length) == (self.text.length)) {
                if (_enterDone) {
                    textView.layoutManager.allowsNonContiguousLayout = NO;
                    [self scrollRangeToVisible:NSMakeRange(self.selectedRange.location+self.selectedRange.length, 0)];
                }
            }
        }
        _shouldChangeText = NO;
    }
    [self hiddenPlaceHoldLabel];
    
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewDidChangeSelection:)]) {
        [self.myDelegate CJUITextViewDidChangeSelection:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextView:shouldInteractWithURL:inRange:interaction:)]) {
        return [self.myDelegate CJUITextView:self shouldInteractWithURL:URL inRange:characterRange interaction:interaction];
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextView:shouldInteractWithTextAttachment:inRange:interaction:)]) {
        return [self.myDelegate CJUITextView:self shouldInteractWithTextAttachment:textAttachment inRange:characterRange interaction:interaction];
    }
    return YES;
}
- (BOOL)textView:(CJUITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextView:shouldInteractWithURL:inRange:)]) {
        return [self.myDelegate CJUITextView:self shouldInteractWithURL:URL inRange:characterRange];
    }
    return YES;
}
- (BOOL)textView:(CJUITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextView:shouldInteractWithTextAttachment:inRange:)]) {
        return [self.myDelegate CJUITextView:self shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    }
    return YES;
}
@end

