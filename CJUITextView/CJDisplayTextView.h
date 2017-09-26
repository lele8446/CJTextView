//
//  CJDisplayTextView.h
//  TextViewDemo
//
//  Created by ChiJinLian on 2017/9/22.
//  Copyright © 2017年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CJTextAttachment;
typedef enum : NSUInteger {
    PhoneNumberLink = 0,
    UrlLink,
    AddressLink,
    OtherLink
} CJTextViewLinkType;

@interface CJDisplayTextView : UITextView

@property(nonatomic, getter=isEditable) BOOL editable;

//- (CGSize)caculateTextViewSize:(CGSize)textSize;

@end


@interface CJTextAttachment: NSTextAttachment
@property (nonatomic, assign) CJTextViewLinkType linkType;
@property (nonatomic, strong) id parameter;
@end
