//
//  SecondViewController.m
//  TextViewDemo
//
//  Created by ChiJinLian on 2017/9/21.
//  Copyright © 2017年 YiChe. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.textModelArray.count > 0) {
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]init];
        for (CJTextViewModel *model in self.textModelArray) {
            if (model.isLink) {
                NSAttributedString *linkStr = [CJDisplayTextView linkAttStr:model.attrString attributes:nil parameter:model.parameter];
                [attStr appendAttributedString:linkStr];
            }else{
                [attStr appendAttributedString:model.attrString];
            }
        }
        self.textView.attributedText = attStr;
    }
    else{
        NSString *str = @"CJDisplayTextView是继承自UITextView的自定义控件，它只支持浏览模式，不允许编辑。它可以根据显示内容动态调整高度，并自动识别网址、日期、地址、电话，点击则触发系统默认行为；同时允许插入自定义点击链点，自定义链点请通过类方法`+linkStr:attributes:parameter:`生成，点击自定义链点会触发点击回调block和长按回调（长按只支持iOS10之后的系统）。相关链接https://github.com/lele8446/TextViewDemo 更多……";
        
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineSpacing = 5;
        paragraph.alignment = NSTextAlignmentLeft;
        NSDictionary *attDic = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName:[UIColor blackColor],
                                 NSParagraphStyleAttributeName:paragraph};
        
        NSDictionary *linkDic = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                  NSUnderlineStyleAttributeName:@1,
                                  NSForegroundColorAttributeName:[UIColor blueColor],
                                  NSParagraphStyleAttributeName:paragraph};
        //
        //    NSDictionary *afterLinkDic = @{NSForegroundColorAttributeName:[UIColor redColor]};
        
        NSAttributedString *userStr = [[NSAttributedString alloc]initWithString:@"@用户"];
        NSAttributedString *linkStr = [CJDisplayTextView linkAttStr:userStr attributes:linkDic parameter:@"用户id"];
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:str attributes:attDic];
        [attStr insertAttributedString:linkStr atIndex:111];
        
        self.textView.attributedText = attStr;
    }
    
    __weak typeof(self)wSelf = self;
    self.textView.displayViewLayoutBlock = ^(CGSize size){
        wSelf.textViewHeight.constant = size.height;
    };
    self.textView.clickBlock = ^(CJTextViewModel *textModel){
        NSLog(@"点击 linkAttstr = %@",textModel.attrString);
        NSLog(@"点击 parameter = %@",textModel.parameter);
    };
    self.textView.pressBlock = ^(CJTextViewModel *textModel){
        NSLog(@"长按 linkAttstr = %@",textModel.attrString);
        NSLog(@"长按 parameter = %@",textModel.parameter);

    };
    self.textView.backgroundColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
