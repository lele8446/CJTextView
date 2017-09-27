//
//  CJDisplayTextView.m
//  TextViewDemo
//
//  Created by ChiJinLian on 2017/9/22.
//  Copyright © 2017年 YiChe. All rights reserved.
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

@interface CJTextNSURL: NSURL
@property (nonatomic, assign) CJTextViewLinkType linkType;
@property (nonatomic, strong) id parameter;
@property (nonatomic, strong) NSDictionary <NSAttributedStringKey, id>* afterClickAttributes;
@end

@implementation CJTextNSURL

@end


@interface CJDisplayTextView ()<UITextViewDelegate>
{
    
}
@end

@implementation CJDisplayTextView

@dynamic editable;

- (void)dealloc {
    self.delegate = nil;
}

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
    self.delegate = self;
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

+ (NSAttributedString *)linkStr:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs parameter:(id)parameter {
    return [self linkStr:str attributes:attrs afterClickAttributes:nil parameter:parameter];
}

+ (NSAttributedString *)linkStr:(NSString *)str
                        attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs
              afterClickAttributes:(NSDictionary<NSAttributedStringKey, id> *)afterClickAttributes
                         parameter:(id)parameter
{
    if (str.length == 0) {
        return [[NSAttributedString alloc]init];
    }
    NSRange range = NSMakeRange(0, str.length);
    NSMutableAttributedString *linkStr = [[NSMutableAttributedString alloc]initWithString:str];
    if (attrs) {
        NSMutableDictionary *dicAtt = [NSMutableDictionary dictionaryWithCapacity:3];
        [dicAtt addEntriesFromDictionary:[linkStr attributesAtIndex:0 effectiveRange:&range]];
        [dicAtt addEntriesFromDictionary:attrs];
        [linkStr addAttributes:dicAtt range:range];
    }
    
    CJTextNSURL *linkUrl = [CJTextNSURL URLWithString:@"https://github.com/lele8446/TextViewDemo"];
    linkUrl.parameter = parameter;
    linkUrl.afterClickAttributes = afterClickAttributes;
    [linkStr addAttribute:NSLinkAttributeName value:linkUrl range:NSMakeRange(0, linkStr.length)];
    return linkStr;
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

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if ([URL isKindOfClass:[CJTextNSURL class]]) {
        CJTextNSURL *linkUrl = (CJTextNSURL *)URL;
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
        
        if (linkUrl.afterClickAttributes) {
            NSMutableDictionary *dicAtt = [NSMutableDictionary dictionaryWithCapacity:3];
            [dicAtt addEntriesFromDictionary:[attStr attributesAtIndex:characterRange.location effectiveRange:&characterRange]];
            [dicAtt addEntriesFromDictionary:linkUrl.afterClickAttributes];
            [attStr addAttributes:dicAtt range:characterRange];
            textView.attributedText = attStr;
        }
        
        NSAttributedString *linkAttstr = [attStr attributedSubstringFromRange:characterRange];
        id parameter = linkUrl.parameter;
        if (interaction == UITextItemInteractionInvokeDefaultAction) {
            if (self.clickBlock) {
                self.clickBlock(linkAttstr, parameter);
            }
        }else if (interaction == UITextItemInteractionPresentActions) {
            if (self.pressBlock) {
                self.pressBlock(linkAttstr, parameter);
            }
        }
        return NO;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([URL isKindOfClass:[CJTextNSURL class]]) {
        CJTextNSURL *linkUrl = (CJTextNSURL *)URL;
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
        
        if (linkUrl.afterClickAttributes) {
            NSMutableDictionary *dicAtt = [NSMutableDictionary dictionaryWithCapacity:3];
            [dicAtt addEntriesFromDictionary:[attStr attributesAtIndex:characterRange.location effectiveRange:&characterRange]];
            [dicAtt addEntriesFromDictionary:linkUrl.afterClickAttributes];
            [attStr addAttributes:dicAtt range:characterRange];
            textView.attributedText = attStr;
        }
        
        NSAttributedString *linkAttstr = [attStr attributedSubstringFromRange:characterRange];
        id parameter = linkUrl.parameter;
        if (self.clickBlock) {
            self.clickBlock(linkAttstr, parameter);
        }
        return NO;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    return NO;
}

@end
