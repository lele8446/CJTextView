//
//  CJDisplayTextView.m
//  TextViewDemo
//
//  Created by C.K.Lian on 16/6/26.
//  Copyright © 2016年 C.K.Lian.. All rights reserved.
//

#import "CJDisplayTextView.h"

//标记link链点的自定义参数
NSString * const kCJLinkParameterAttributeName   = @"kCJLinkParameterAttributeName";
NSString * const kCJLinkAfterClickAttributesName = @"kCJLinkAfterClickAttributesName";

typedef enum : NSUInteger {
    PhoneNumberLink = 0,
    UrlLink,
    AddressLink,
    OtherLink
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
    self.contentInset = UIEdgeInsetsMake(-100, 0, 0, 0);
    self.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
    [self setValue:self forKey:@"delegate"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGSize textSize = [self caculateTextViewSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
    NSLog(@"size = %@",NSStringFromCGSize(textSize));
    self.bounds = CGRectMake(0, 0, self.frame.size.width, textSize.height);
    self.contentSize = self.bounds.size;
    self.textContainer.size = textSize;
    [self scrollRangeToVisible:NSMakeRange(0,0)];
    [self setContentOffset:CGPointMake(0, 0)];
    if(self.displayViewLayoutBlock) {
        self.displayViewLayoutBlock(textSize);
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
    
#warning 不知为毛，这里设置 NSAttachmentAttributeName 无效了，改为通过 NSLinkAttributeName 设置
//    CJLinkTextAttachment *textAttachment = [[CJLinkTextAttachment alloc]init];
//    textAttachment.textModel = linkModel;
//    [linkStr addAttribute:NSAttachmentAttributeName value:textAttachment range:NSMakeRange(0, linkStr.length)];
    
    CJLinkNSURL *url = [CJLinkNSURL URLWithString:@"https://github.com/lele8446/TextViewDemo"];
    url.textModel = linkModel;
    [linkStr addAttribute:NSLinkAttributeName value:url range:NSMakeRange(0, linkStr.length)];
    
    NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc]initWithString:@" "];
    [resultStr appendAttributedString:linkStr];
    
    linkModel.attrString = resultStr;
    
    return resultStr;
}

- (CGSize)caculateTextViewSize:(CGSize)textSize {
    return [self sizeThatFits:textSize];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self) {
        CGRect bounds = self.bounds;
        bounds.origin.y = 0;
        self.bounds = bounds;
    }
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
            CJLinkNSURL *linkUrl = (CJLinkNSURL *)link;
            CJTextViewModel *linkModel = linkUrl.textModel;
            
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
                NSURL *linkUrl = (NSURL *)link;
                return self.shouldInteractUrlBlock(linkUrl, characterRange,interaction);
            }else{
                return YES;
            }
        }
    }
    
    if ([link isKindOfClass:[NSTextAttachment class]]) {
        if ([link isKindOfClass:[CJLinkTextAttachment class]]) {
            CJLinkTextAttachment *linkTextAttachment = (CJLinkTextAttachment *)link;
            CJTextViewModel *linkModel = linkTextAttachment.textModel;
            
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
                NSTextAttachment *textAttachment = (NSTextAttachment *)link;
                return self.shouldInteractAttachmentBlock(textAttachment, characterRange,interaction);
            }else{
                return YES;
            }
        }
    }
    
    return YES;
}

- (void)linkModel:(CJTextViewModel *)linkModel haveInteraction:(BOOL)haveInteraction interaction:(UITextItemInteraction)interaction {
    if (haveInteraction) {
        if (interaction == UITextItemInteractionInvokeDefaultAction) {
            if (self.clickBlock) {
                self.clickBlock(linkModel);
            }
        }else if (interaction == UITextItemInteractionPresentActions) {
            if (self.pressBlock) {
                self.pressBlock(linkModel);
            }
        }
    }else{
        if (self.clickBlock) {
            self.clickBlock(linkModel);
        }
    }
}
@end
