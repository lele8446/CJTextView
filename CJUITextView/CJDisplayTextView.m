//
//  CJDisplayTextView.m
//  TextViewDemo
//
//  Created by C.K.Lian on 16/6/26.
//  Copyright © 2016年 C.K.Lian.. All rights reserved.
//

#import "CJDisplayTextView.h"
#import "CJUITextView.h"

static inline CGFLOAT_TYPE CJTextViewCGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

//标记link链点的自定义参数
NSString * const kCJLinkParameterAttributeName   = @"kCJLinkParameterAttributeName";
NSString * const kCJLinkAfterClickAttributesName = @"kCJLinkAfterClickAttributesName";

typedef enum : NSUInteger {
    CJPhoneNumberLink = 0,
    CJUrlLink,
    CJAddressLink,
    CJOtherLink
} CJTextViewLinkType;

@interface CJLinkNSURL : NSURL
@property (nonatomic, strong) CJTextViewModel *textModel;
@end
@implementation CJLinkNSURL
@end

@interface CJLinkTextAttachment : NSTextAttachment
@property (nonatomic, strong) CJTextViewModel *textModel;
@end
@implementation CJLinkTextAttachment
@end

@interface CJDisplayTextView ()<UITextViewDelegate>
{
}
@end

@implementation CJDisplayTextView

@dynamic editable;
@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (void)commonInit {
    [self setValue:@(NO) forKey:@"editable"];
    self.selectable = YES;
    self.clipsToBounds = YES;
    self.showsVerticalScrollIndicator = NO;
    self.bounces = NO;
    self.dataDetectorTypes = UIDataDetectorTypeAll;
    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self setValue:self forKey:@"delegate"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.clickDisplayViewBlock) {
        self.clickDisplayViewBlock();
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:) || action == @selector(select:) || action == @selector(selectAll:)) {
        return YES;
    }
    return NO;
}

+ (NSAttributedString *)linkAttStr:(NSAttributedString *)attStr attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs parameter:(id)parameter {
    return [self linkAttStr:attStr attributes:attrs afterClickAttributes:nil parameter:parameter];
}

+ (NSAttributedString *)linkAttStr:(NSAttributedString *)attStr
                        attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs
              afterClickAttributes:(NSDictionary<NSAttributedStringKey, id> *)afterClickAttributes
                         parameter:(id)parameter
{
    if (attStr.length == 0) {
        return [[NSAttributedString alloc]init];
    }
    NSRange range = NSMakeRange(0, attStr.length);
    NSMutableAttributedString *linkStr = [[NSMutableAttributedString alloc]initWithAttributedString:attStr];
    if (attrs) {
        NSMutableDictionary *dicAtt = [NSMutableDictionary dictionaryWithCapacity:3];
        [dicAtt addEntriesFromDictionary:[linkStr attributesAtIndex:0 effectiveRange:&range]];
        [dicAtt addEntriesFromDictionary:attrs];
        [linkStr addAttributes:dicAtt range:range];
    }

    CJTextViewModel *linkModel = [[CJTextViewModel alloc]init];
    linkModel.parameter = parameter;
    linkModel.afterClickAttributes = afterClickAttributes;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@",[NSUUID UUID].UUIDString];
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CJLinkNSURL *url = [CJLinkNSURL URLWithString:urlStr];
    url.textModel = linkModel;
    [linkStr addAttribute:NSLinkAttributeName value:url range:NSMakeRange(0, linkStr.length)];
    
    //链点前面加空格，避免NSLinkAttributeName 连续出现时，系统将其识别为同一个链点
    NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc]initWithString:@" "];
    [resultStr appendAttributedString:linkStr];
    
    linkModel.attrString = resultStr;
    
    return resultStr;
}

- (CGSize)caculateTextViewSize:(CGSize)textSize {
    CGSize caculateSize = [self sizeThatFits:textSize];
    caculateSize = CGSizeMake(CJTextViewCGFloat_ceil(caculateSize.width), CJTextViewCGFloat_ceil(caculateSize.height));
    return caculateSize;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    return [self textView:textView shouldInteraction:URL inRange:characterRange haveInteraction:YES interaction:interaction];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    return [self textView:textView shouldInteraction:textAttachment inRange:characterRange haveInteraction:YES interaction:interaction];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return [self textView:textView shouldInteraction:URL inRange:characterRange haveInteraction:NO interaction:UITextItemInteractionInvokeDefaultAction];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    return [self textView:textView shouldInteraction:textAttachment inRange:characterRange haveInteraction:NO interaction:UITextItemInteractionInvokeDefaultAction];
}

- (BOOL)textView:(UITextView *)textView shouldInteraction:(id)link inRange:(NSRange)characterRange haveInteraction:(BOOL)haveInteraction interaction:(UITextItemInteraction)interaction
{
    if ([link isKindOfClass:[NSURL class]]) {
        if ([link isKindOfClass:[CJLinkNSURL class]]) {
            CJTextViewModel *linkModel = [(CJLinkNSURL *)link textModel];
            
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
            
            if (linkModel.afterClickAttributes) {
                NSMutableDictionary *dicAtt = [NSMutableDictionary dictionaryWithCapacity:3];
                [dicAtt addEntriesFromDictionary:[attStr attributesAtIndex:characterRange.location effectiveRange:&characterRange]];
                [dicAtt addEntriesFromDictionary:linkModel.afterClickAttributes];
                [attStr addAttributes:dicAtt range:characterRange];
                textView.attributedText = attStr;
            }
            [self linkModel:linkModel haveInteraction:haveInteraction interaction:interaction];
            return NO;
        }
        else{
            if (self.shouldInteractUrlBlock) {
                return self.shouldInteractUrlBlock(link, characterRange,interaction);
            }else{
                return YES;
            }
        }
    }
    
    if ([link isKindOfClass:[NSTextAttachment class]]) {
        if ([link isKindOfClass:[CJLinkTextAttachment class]]) {
            CJTextViewModel *linkModel = [(CJLinkTextAttachment *)link textModel];
            
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
            
            if (linkModel.afterClickAttributes) {
                NSMutableDictionary *dicAtt = [NSMutableDictionary dictionaryWithCapacity:3];
                [dicAtt addEntriesFromDictionary:[attStr attributesAtIndex:characterRange.location effectiveRange:&characterRange]];
                [dicAtt addEntriesFromDictionary:linkModel.afterClickAttributes];
                [attStr addAttributes:dicAtt range:characterRange];
                textView.attributedText = attStr;
            }
            [self linkModel:linkModel haveInteraction:haveInteraction interaction:interaction];
            return NO;
        }
        else{
            if (self.shouldInteractAttachmentBlock) {
                return self.shouldInteractAttachmentBlock(link, characterRange,interaction);
            }else{
                return YES;
            }
        }
    }
    
    return YES;
}

- (void)linkModel:(CJTextViewModel *)linkModel haveInteraction:(BOOL)haveInteraction interaction:(UITextItemInteraction)interaction {
    if (haveInteraction) {
        if (@available(iOS 10.0, *)) {
            if (interaction == UITextItemInteractionInvokeDefaultAction) {
                if (self.clickBlock) {
                    self.clickBlock(linkModel);
                }
            }else if (interaction == UITextItemInteractionPresentActions) {
                if (self.pressBlock) {
                    self.pressBlock(linkModel);
                }
            }else if (interaction == UITextItemInteractionPreview) {
                if (self.pressBlock) {
                    self.pressBlock(linkModel);
                }
            }else{
                if (self.clickBlock) {
                    self.clickBlock(linkModel);
                }
            }
        } else {
            if (self.clickBlock) {
                self.clickBlock(linkModel);
            }
        }
    }else{
        if (self.clickBlock) {
            self.clickBlock(linkModel);
        }
    }
}
@end

