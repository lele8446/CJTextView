//
//  CJTextViewModel.h
//  TextViewDemo
//
//  Created by C.K.Lian on 16/6/26.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 文本对象model
 */
@interface CJTextViewModel : NSObject
/**
 插入文本标识符
 */
@property (nonatomic, copy) NSString *insertIdentifier;
/**
 文本range
 */
@property (nonatomic, assign) NSRange range;
/**
 文本的NSAttributedString
 */
@property (nonatomic, strong) NSAttributedString *attrString;
/**
 文本自定义参数
 */
@property (nonatomic, strong) id parameter;

/**
 是否为插入文本（CJUITextView中用到）
 */
@property (nonatomic, assign) BOOL isInsertText;

/**
 是否为点击链点（CJDisplayTextView中用到）
 */
@property (nonatomic, assign) BOOL isLink;
/**
 点击链点之后的文本属性（CJDisplayTextView中用到）
 */
@property (nonatomic, strong) NSDictionary <NSAttributedStringKey, id>* afterClickAttributes;

/**
 插入特殊文本时，根据identifier，初始化CJTextViewModel
 
 @param identifier 插入文本标识符
 @param attrString 插入的NSAttributedString
 @param parameter  自定义参数
 @return CJTextViewModel
 */
+ (CJTextViewModel *)modelWithIdentifier:(NSString *)identifier
                              attrString:(NSAttributedString *)attrString
                               parameter:(id)parameter;

@end
