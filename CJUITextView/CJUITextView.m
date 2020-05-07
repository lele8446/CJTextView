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
NSString * const kCJLinkAttributeName                         = @"kCJLinkAttributeName";

typedef void(^ObserverResultBlock)(id oldValue, id newValue);
typedef BOOL(^ObserverJudgeBlock)(NSString *path, void *context);
@interface CJTextViewObserver : NSObject
@property (nonatomic, copy) ObserverResultBlock resultBlock;
@property (nonatomic, copy) ObserverJudgeBlock judgeBlock;
- (void)observerForTarget:(NSObject *)target forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context resultBlock:(ObserverResultBlock)resultBlock judgeBlock:(ObserverJudgeBlock)judgeBlock;
@end

@interface CJUITextView()<UITextViewDelegate>
{
    BOOL _shouldChangeText;
    BOOL _enterDone;
    BOOL _afterLayout;
}
@property (nonatomic, assign) BOOL placeHoldLabelHidden;
@property (nonatomic, strong) NSDictionary *defaultAttributes;
@property (nonatomic, assign) NSUInteger specialTextNum;//记录特殊文本的索引值
@property (nonatomic, assign) CGFloat oneLineHeight;//单行输入文字时的高度
@property (nonatomic, assign) int addObserverTime;//注册KVO的次数

@property (nonatomic, strong) CJTextViewObserver *textViewObserver;//注册KVO观察者
@property (nonatomic, strong) NSMutableArray *insterSpecialTextIndexArray;
@property (nonatomic, assign) NSUInteger currentTextLength;

+ (NSRange)selectedRange:(UITextView *)textView selectTextRange:(UITextRange *)selectedTextRange;
@end

@implementation CJUITextView
@dynamic delegate;

- (UILabel *)placeHoldLabel {
    if (!_placeHoldLabel) {
        _placeHoldLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_placeHoldLabel setBackgroundColor:[UIColor clearColor]];
        _placeHoldLabel.numberOfLines = 1;
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
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
    [dic addEntriesFromDictionary:self.defaultAttributes];
    [dic setValue:font forKey:NSFontAttributeName];
    self.defaultAttributes = dic;
    [self setPlaceHoldTextFont:font];
    [self calculationOneLineHeight];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
    [dic addEntriesFromDictionary:self.defaultAttributes];
    [dic setValue:textColor forKey:NSForegroundColorAttributeName];
    self.defaultAttributes = dic;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    self.typingAttributes = self.defaultAttributes;
    
    if (attributedText.length > 0) {
        NSRange specialRange = NSMakeRange(0, attributedText.length);
        NSDictionary *dicAtt = [attributedText attributesAtIndex:0 effectiveRange:&specialRange];
        NSMutableParagraphStyle *style = dicAtt[NSParagraphStyleAttributeName];
        if (style) {
            NSTextAlignment alignment = style.alignment;
            self.placeHoldLabel.textAlignment = alignment;
        }
        UIFont *font = self.defaultAttributes[NSFontAttributeName];
        if (font) {
            [self calculationOneLineHeight];
        }
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    self.placeHoldLabel.textAlignment = textAlignment;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.defaultAttributes];
    NSMutableParagraphStyle *style = self.defaultAttributes[NSParagraphStyleAttributeName];
    if (!style) {
        style = [[NSMutableParagraphStyle alloc]init];
    }
    style.alignment = textAlignment;
    [dic setObject:style forKey:NSParagraphStyleAttributeName];
    self.defaultAttributes = dic;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    self.placeHoldContainerInset = UIEdgeInsetsMake(textContainerInset.top,
                                                    textContainerInset.left==0?4:textContainerInset.left,
                                                    textContainerInset.bottom,
                                                    textContainerInset.right==0?4:textContainerInset.right);
    [self calculationOneLineHeight];
}

- (UIColor *)getSpecialTextColor {
    if (!_specialTextColor || nil == _specialTextColor) {
        if (!self.textColor || self.textColor == nil) {
            self.textColor = [UIColor blackColor];
        }
        _specialTextColor = self.textColor;
    }
    return _specialTextColor;
}

- (NSString *)text {
    NSString *text = [super text];
    text = [text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "];
    return text;
}

- (NSAttributedString *)attributedText {
    NSAttributedString *attributedText = [super attributedText];
    NSRange range = NSMakeRange(0, attributedText.length);
    [attributedText.string stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" " options:NSRegularExpressionSearch range:range];
    return attributedText;
}

- (CGFloat)oneLineHeight {
    if (_oneLineHeight == 0) {
        _oneLineHeight = [self calculationOneLineHeight];
    }
    return _oneLineHeight;
}

- (CGFloat)calculationOneLineHeight {
    UIFont *font = self.defaultAttributes[NSFontAttributeName];
    if (!font) {
        font = self.font;
    }
    if (!font) {
        font = [UIFont systemFontOfSize:14];
    }
    NSDictionary *attr = @{NSFontAttributeName:font};
    CGSize stringSize = [@"输入文本" boundingRectWithSize:CGSizeMake(375, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
    _oneLineHeight = stringSize.height + self.textContainerInset.top + self.textContainerInset.bottom;
    return _oneLineHeight;
}

- (void)dealloc {
    _myDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidShowMenuNotification object:nil];
    [self removeObserver:_textViewObserver forKeyPath:@"selectedTextRange" context:TextViewObserverSelectedTextRange];
//    id obser = self.observationInfo;
//    if (obser) {
//        @try {
//            [self removeObserver:_textViewObserver forKeyPath:@"selectedTextRange" context:TextViewObserverSelectedTextRange];
//        } @catch (NSException *exception) {
//            NSLog(@"ZWTTextView 多次删除了 selectedTextRange KVO");
//        } @finally {
//        }
//    }
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
    //确保KVO只注册一次
    if (self.addObserverTime >= 1) {
        return;
    }
    self.insterSpecialTextIndexArray = [NSMutableArray array];
    self.specialTextNum = 1;
    self.placeHoldContainerInset = UIEdgeInsetsMake(8, 4, 8, 4);
    self.font = [UIFont systemFontOfSize:14];
    self.defaultAttributes = self.typingAttributes;
    [self addMenuControllerDidShowNotic];
    //由于delegate 被声明为 unavailable，这里只能通过kvc的方式设置了
    [self setValue:self forKey:@"delegate"];
    self.textViewObserver = [[CJTextViewObserver alloc]init];
    [self addObserverForTextView];
    [self hiddenPlaceHoldLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_afterLayout || ((self.placeHoldLabel.frame.size.width == 0) || (self.placeHoldLabel.frame.size.height == 0))) {
        [self placeHoldLabelFrame];
    }
}

- (void)adjustPlaceHoldLabelFrame:(CGRect)frame {
    if (CGRectIsNull(frame)) {
        [self placeHoldLabelFrame];
    }else{
        self.placeHoldLabel.frame = frame;
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
    CGFloat width = self.bounds.size.width - self.placeHoldContainerInset.left-self.placeHoldContainerInset.right;
    CGSize sizeToFit = [self.placeHoldLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    CGFloat height = sizeToFit.height;
    
    if (self.oneLineHeight > self.bounds.size.height) {
        if (height > (self.bounds.size.height - (self.placeHoldContainerInset.top + self.placeHoldContainerInset.bottom))) {
            height = self.bounds.size.height - (self.placeHoldContainerInset.top + self.placeHoldContainerInset.bottom);
        }
    }
    else{
        if (height > (self.oneLineHeight - (self.placeHoldContainerInset.top + self.placeHoldContainerInset.bottom))) {
            height = self.oneLineHeight - (self.placeHoldContainerInset.top + self.placeHoldContainerInset.bottom);
        }
    }
    
    self.placeHoldLabel.frame = CGRectMake(self.placeHoldContainerInset.left,self.placeHoldContainerInset.top, self.bounds.size.width - self.placeHoldContainerInset.left-self.placeHoldContainerInset.right, height);
}

- (void)changeSize {
    CGRect oriFrame = self.frame;
    CGSize sizeToFit = [self sizeThatFits:CGSizeMake(oriFrame.size.width, MAXFLOAT)];
    if (sizeToFit.height < self.oneLineHeight) {
        sizeToFit.height = self.oneLineHeight;
    }
    if (fabs((sizeToFit.height-oriFrame.size.height)) > 0.1 && sizeToFit.height <= self.maxHeight) {
        oriFrame.size.height = ceilf(sizeToFit.height);
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
 *  @return NSMutableAttributedString
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

    NSMutableAttributedString *textAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:[CJUITextView handleEditTextModel:self.attributedText]];
    
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
    [self handleEditAttributedTextToCJTextModel];
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
    [self handleEditAttributedTextToCJTextModel];
    NSArray *array = [self textModelFromAttributedString:self.attributedText insert:YES rangeTextRange:NSMakeRange(0, self.attributedText.length)];
    return array;
}

- (NSArray <CJTextViewModel *>*)allTextModel {
    [self handleEditAttributedTextToCJTextModel];
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
            if ([modelAttrs[kCJLinkAttributeName] boolValue]) {
                model.isLink = YES;
            }else{
                model.isLink = NO;
            }
            
            [array insertObject:model atIndex:0];
        }
    }];
    return array;
}

- (void)handleEditAttributedTextToCJTextModel {
    self.attributedText = [CJUITextView handleEditTextModel:self.attributedText];
}

+ (NSMutableAttributedString *)handleEditTextModel:(NSAttributedString *)attributedText {
    NSMutableAttributedString *textAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    [textAttStr.string enumerateSubstringsInRange:NSMakeRange(0, [textAttStr.string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         NSDictionary *dicAtt = [textAttStr attributesAtIndex:substringRange.location effectiveRange:&substringRange];
         if (CJTextViewIsNull(dicAtt[kCJInsterSpecialTextKeyAttributeName])) {
             [textAttStr addAttribute:kCJInsterSpecialTextKeyAttributeName value:kCJTextAttributeName range:substringRange];
         }
     }];
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
    NSLog(@"CJUITextView: - removeObserver， V2.0.2版本后该方法已经废弃，使用者无需再主动移除KVO监听");
}

+ (NSMutableAttributedString *)setRangeStrAsSpecialText:(NSRange)range
                                             attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs
                                         attributedText:(NSMutableAttributedString *)attributedText
{
    if (range.location == NSNotFound) {
        return attributedText;
    }
    if (range.location >= attributedText.length) {
        return attributedText;
    }
    if (range.location + range.length > attributedText.length) {
        range = NSMakeRange(range.location, attributedText.length-range.location);
    }
    
    attributedText = [CJUITextView handleEditTextModel:attributedText];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    NSString *insertKeyGroup = kCJInsterDefaultGroupAttributeName;
    [attStr addAttribute:kCJInsterSpecialTextKeyGroupAttributeName value:insertKeyGroup range:range];
    //插入key
    NSString *insertKey = [NSUUID UUID].UUIDString;
    [attStr addAttribute:kCJInsterSpecialTextKeyAttributeName value:insertKey range:range];
    [attStr addAttribute:kCJInsterSpecialTextRangeAttributeName value:NSStringFromRange(range) range:range];
    [attStr addAttributes:attrs range:range];
    return attStr;
}

#pragma mark - NSNotificationCenter
- (void)addMenuControllerDidShowNotic {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerDidShow:) name:UIMenuControllerDidShowMenuNotification object:nil];
}

- (void)menuControllerDidShow:(NSNotification *)notification {
    NSRange selectedRange = self.selectedRange;
    [self getSelextIndex:selectedRange.location isLeft:YES completion:^(NSUInteger index) {
        self.selectedRange = NSMakeRange(index, (selectedRange.location+selectedRange.length) - index);
    }];
    NSRange newRange = self.selectedRange;
    NSUInteger rightIndex = newRange.location + newRange.length;
    [self getSelextIndex:rightIndex isLeft:NO completion:^(NSUInteger index) {
        self.selectedRange = NSMakeRange(newRange.location, index-newRange.location);
    }];
}

#pragma mark - Observer
static void *TextViewObserverSelectedTextRange = &TextViewObserverSelectedTextRange;
- (void)addObserverForTextView {
    //确保KVO只注册一次
    if (self.addObserverTime >= 1) {
        return;
    }
    __weak typeof(self) wSelf = self;
    [self.textViewObserver observerForTarget:self forKeyPath:@"selectedTextRange" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:TextViewObserverSelectedTextRange resultBlock:^(id oldValue, id newValue) {
        UITextRange *newContentStr = newValue;
        UITextRange *oldContentStr = oldValue;
        if (!CJTextViewIsNull(newContentStr) && !CJTextViewIsNull(oldContentStr)) {
            NSRange newRange = [CJUITextView selectedRange:wSelf selectTextRange:newContentStr];
            NSRange oldRange = [CJUITextView selectedRange:wSelf selectTextRange:oldContentStr];
            
            //长按弹出放大镜时，移动光标
            if (newRange.length == 0) {
                if (newRange.location != oldRange.location) {
                    //判断光标移动，光标不能处在特殊文本内
                    [wSelf.attributedText enumerateAttribute:kCJInsterSpecialTextKeyAttributeName inRange:NSMakeRange(0, wSelf.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                        NSString *key = (NSString *)attrs;
                        if (key && ![key isEqualToString:kCJTextAttributeName]) {
                            if (newRange.location > range.location && newRange.location < (range.location+range.length)) {
                                //光标距离左边界的值
                                NSUInteger leftValue = newRange.location - range.location;
                                //光标距离右边界的值
                                NSUInteger rightValue = range.location+range.length - newRange.location;
                                if (leftValue >= rightValue) {
                                    wSelf.selectedRange = NSMakeRange(wSelf.selectedRange.location-leftValue, 0);
                                }else{
                                    wSelf.selectedRange = NSMakeRange(wSelf.selectedRange.location+rightValue, 0);
                                }
                            }
                        }
                    }];
                }
            }
            //长按选择文字，移动选中文字时移动左右大头针
            else{
                //右边大头针移动
                if (newRange.location == oldRange.location) {
                    NSUInteger rightIndex = newRange.location + newRange.length;
                    [self getSelextIndex:rightIndex isLeft:NO completion:^(NSUInteger index) {
                        wSelf.selectedRange = NSMakeRange(newRange.location, index-newRange.location);
                    }];
                }
                //左边大头针移动
                else {
                    //左边大头针选中不可编辑文本的判断，交由menuControllerDidShow方法判断
                }
                
            }
        }
        wSelf.typingAttributes = wSelf.defaultAttributes;
        if (wSelf.myDelegate && [wSelf.myDelegate respondsToSelector:@selector(CJUITextView:changeSelectedRange:)]) {
            [wSelf.myDelegate CJUITextView:wSelf changeSelectedRange:wSelf.selectedRange];
        }
        
    } judgeBlock:^BOOL(NSString *path, void *context) {
        return (context == TextViewObserverSelectedTextRange && [path isEqual:@"selectedTextRange"] && !wSelf.enableEditInsterText);
    }];
    self.addObserverTime ++;
}

+ (NSRange)selectedRange:(UITextView *)textView selectTextRange:(UITextRange *)selectedTextRange {
    UITextPosition* beginning = textView.beginningOfDocument;
    UITextRange* selectedRange = selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    const NSInteger location = [textView offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [textView offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

- (void)currentTextLengthAndInsterSpecialTextIndexArray {
    NSUInteger textLength = self.text.length;
    if (textLength == 0) {
        textLength = self.attributedText.length;
    }
    if (textLength != self.currentTextLength) {
        [self.insterSpecialTextIndexArray removeAllObjects];
        [self.attributedText enumerateAttribute:kCJInsterSpecialTextKeyAttributeName inRange:NSMakeRange(0, self.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            NSString *key = (NSString *)attrs;
            if (key && ![key isEqualToString:kCJTextAttributeName]) {
                for (NSInteger i = 1; i < range.length; i++) {
                    [self.insterSpecialTextIndexArray addObject:@(range.location + i)];
                }
            }
        }];
        self.currentTextLength = textLength;
    }
}

- (void)getSelextIndex:(NSInteger)index isLeft:(BOOL)isLeft completion:(void (^)(NSUInteger index))completion {
    //当选中内容刚好在插入的不可编辑文本内时才要移动光标
    if ([self.insterSpecialTextIndexArray containsObject:@(index)]) {
        [self caculateSelextIndex:index isLeft:isLeft completion:completion];
    }
}

- (void)caculateSelextIndex:(NSInteger)index isLeft:(BOOL)isLeft completion:(void (^)(NSUInteger index))completion {
    if ([self.insterSpecialTextIndexArray containsObject:@(index)]) {
        if (isLeft) {
            index = index - 1;
        }else{
            index = index + 1;
        }
        [self caculateSelextIndex:index isLeft:isLeft completion:completion];
    }else{
        if (completion) {
            completion(index);
        }
    }
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
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewDidEndEditing:)]) {
        [self.myDelegate CJUITextViewDidEndEditing:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //输入了done
    _enterDone = NO;
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
    
    //处理右对齐无法输入空格的系统问题
    if (self.textAlignment == NSTextAlignmentRight) {
        if (range.location == textView.text.length && [text isEqualToString:@" "]) {
            if (self.text.length == 0) {
                return NO;
            }
            BOOL overNum = (self.maxEditNum > 0 && self.text.length >= self.maxEditNum);
            if (!overNum) {
                // ignore replacement string and add your own
                if (textView.attributedText.length > 0) {
                    NSAttributedString *blankStr = [[NSAttributedString alloc]initWithString:@"\u00a0" attributes:self.defaultAttributes];
                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
                    [str appendAttributedString:blankStr];
                    textView.attributedText = str;
                }else{
                    textView.text = [textView.text stringByAppendingString:@"\u00a0"];
                }
            }
            [self textViewTextChange:textView];
            return NO;
        }
    }
    
    //输入删除判断
    _shouldChangeText = YES;
    self.typingAttributes = self.defaultAttributes;
    if (text && [text isEqualToString:@""]) {
        //不允许编辑插入的特殊字符
        if (!self.enableEditInsterText) {
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
            if (deleteSpecial) {
                [self textViewTextChange:textView];
                return NO;
            }
        }
        
        //右对齐删除，如果文本最后都是空格时，那么空格全部删除
        if (self.textAlignment == NSTextAlignmentRight) {
            __block NSRange blankRange = NSMakeRange(NSNotFound, 0);
            [textView.text enumerateSubstringsInRange:NSMakeRange(0, [textView.text length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
            ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                if ([substring isEqualToString:@" "]) {
                    if (blankRange.location == NSNotFound) {
                        blankRange = substringRange;
                    }else{
                        blankRange = NSMakeRange(blankRange.location, blankRange.length+substringRange.length);
                    }
                }else{
                    blankRange = NSMakeRange(NSNotFound, 0);
                }
            }];
            
            if (blankRange.location+blankRange.length == range.location+range.length) {
                
                if (textView.attributedText.length > 0) {
                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
                    textView.attributedText = [str attributedSubstringFromRange:NSMakeRange(0, blankRange.location)];
                }else{
                    textView.text = [textView.text substringToIndex:blankRange.location];
                }
                [self textViewTextChange:textView];
                return NO;
            }
        }
        
        //iOS13 三指撤销
        BOOL result = YES;
        if (range.location >= textView.text.length) {
            result = NO;
        }
        else {
            if ((range.location + range.length) >= textView.text.length) {
                if (self.attributedText.length > 0) {
                    NSInteger length = range.location;
                    NSAttributedString *attStr = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, length)];
                    self.attributedText = attStr;
                }else{
                    NSInteger length = range.location;
                    NSString *attStr = [self.text substringWithRange:NSMakeRange(0, length)];
                    self.text = attStr;
                }
                result = NO;
            }
            else{
                if (self.attributedText.length > 0) {
                    NSInteger length = range.location;
                    NSInteger tailLocation = range.location+range.length;
                    NSAttributedString *attStr = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, length)];
                    NSAttributedString *tailAttStr = [self.attributedText attributedSubstringFromRange:NSMakeRange((tailLocation), (self.attributedText.length-tailLocation))];
                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithAttributedString:attStr];
                    [str appendAttributedString:tailAttStr];
                    self.attributedText = str;
                    self.selectedRange = NSMakeRange(length, 0);
                }else{
                    NSInteger length = range.location;
                    NSInteger tailLocation = range.location+range.length;
                    NSString *attStr = [self.text substringWithRange:NSMakeRange(0, length)];
                    NSString *tailAttStr = [self.text substringWithRange:NSMakeRange((tailLocation), (self.text.length-tailLocation))];
                    NSMutableString *str = [[NSMutableString alloc]initWithString:attStr];
                    [str appendString:tailAttStr];
                    self.text = str;
                    self.selectedRange = NSMakeRange(length, 0);
                }
                result = NO;
            }
        }
        
        if (!result) {
            [textView unmarkText];
            textView.layoutManager.allowsNonContiguousLayout = NO;
            [self scrollRangeToVisible:NSMakeRange(self.selectedRange.location+self.selectedRange.length, 0)];
            [self layoutIfNeeded];
            [self textViewTextChange:textView];
            return result;
        }
    }
    
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextView:shouldChangeTextInRange:replacementText:)]) {
        return [self.myDelegate CJUITextView:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)textViewTextChange:(UITextView *)textView {
    if (self.maxEditNumCallBlock) {
        BOOL overNum = (self.text.length >= self.maxEditNum && self.maxEditNum > 0);
        self.maxEditNumCallBlock(textView.text.length, overNum, self);
    }
    if (self.autoLayoutHeight) {
        [self changeSize];
    }
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewDidChangeSelection:)]) {
        [self.myDelegate CJUITextViewDidChangeSelection:self];
    }
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewDidChange:)]) {
        [self.myDelegate CJUITextViewDidChange:self];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CJUITextViewDidChange:)]) {
        [self.myDelegate CJUITextViewDidChange:self];
    }
    
    if (self.maxEditNum > 0) {
        //获取高亮部分
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (textView.text.length > self.maxEditNum) {
                void (^substringTextBlock)(void) = ^{
                    /*
                     三指操作撤销时执行textChange，获取到的markedTextRange是nil，即便是存在markedText。这就导致text有可能会被修改。
                     修改文案后再继续执行撤销操作，必定会产生 crash。所以这里将文本截取的操作异步添加到主队列，在下一个runloop执行。
                     */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.attributedText.length > 0) {
                            NSInteger length = self.maxEditNum>[self.attributedText.string length]?[self.attributedText.string length]:self.maxEditNum;
                            NSAttributedString *attStr = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, length)];
                            self.attributedText = attStr;
                            self.selectedRange = NSMakeRange(length, 0);
                        }else{
                            NSInteger length = self.maxEditNum>[self.text length]?[self.text length]:self.maxEditNum;
                            NSString *attStr = [self.text substringWithRange:NSMakeRange(0, length)];
                            self.text = attStr;
                            self.selectedRange = NSMakeRange(length, 0);
                        }
                        
                        [textView unmarkText];
                        textView.layoutManager.allowsNonContiguousLayout = NO;
                        [self scrollRangeToVisible:NSMakeRange(self.selectedRange.location+self.selectedRange.length, 0)];
                        [self layoutIfNeeded];
                    });
                };
                if (self.maxEditNumCallBlock) {
                    BOOL canEdit = self.maxEditNumCallBlock(textView.text.length, YES, self);
                    if (!canEdit) {
                        substringTextBlock();
                    }
                }else{
                    substringTextBlock();
                }
            }else{
                if (self.maxEditNumCallBlock) {
                    self.maxEditNumCallBlock(textView.text.length, NO, self);
                }
            }
        }
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    _afterLayout = YES;
    self.typingAttributes = self.defaultAttributes;
    BOOL changeText = _shouldChangeText;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
        changeText = YES;
    }
    if (changeText) {
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
    
    //更新插入的不可编辑文本的位置信息
    [self currentTextLengthAndInsterSpecialTextIndexArray];
    
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


@implementation CJTextViewObserver
- (void)dealloc {
    NSLog(@"CJTextViewObserver dealloc");
}
- (void)observerForTarget:(NSObject *)target forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context resultBlock:(ObserverResultBlock)resultBlock judgeBlock:(ObserverJudgeBlock)judgeBlock {
    [target addObserver:self forKeyPath:keyPath options:options context:context];
    self.resultBlock = resultBlock;
    self.judgeBlock = judgeBlock;
}
- (void)observeValueForKeyPath:(NSString*)path ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    BOOL needObserver = NO;
    if (self.judgeBlock) {
        needObserver = self.judgeBlock(path,context);
    }
    if (needObserver){
        UITextRange *newContentStr = [change objectForKey:@"new"];
        UITextRange *oldContentStr = [change objectForKey:@"old"];
        if (self.resultBlock) {
            self.resultBlock(oldContentStr, newContentStr);
        }
    }else{
//        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}
@end
