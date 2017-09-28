//
//  CJTextViewModel.m
//  TextViewDemo
//
//  Created by C.K.Lian on 16/6/26.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import "CJTextViewModel.h"


@implementation CJTextViewModel

+ (CJTextViewModel *)modelWithIdentifier:(NSString *)identifier
                              attrString:(NSAttributedString *)attrString
                               parameter:(id)parameter
{
    CJTextViewModel *model = [[CJTextViewModel alloc]init];
    model.insertIdentifier = identifier;
    model.attrString = attrString;
    model.parameter = parameter;
    return model;
}

- (id)copyWithZone:(NSZone *)zone {
    CJTextViewModel *model = [[CJTextViewModel alloc]init];
    model.range = self.range;
    model.isInsertText = self.isInsertText;
    model.insertIdentifier = self.insertIdentifier;
    model.attrString = self.attrString;
    model.parameter = self.parameter;
    model.isLink = self.isLink;
    return model;
}
@end

