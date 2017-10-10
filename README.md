***注意***

V2.0.0版本新增CJDisplayTextView，提供富文本显示功能，可自动识别网址、日期、地址、电话以及添加自定义点击链点。<br/>
引入CJTextViewModel，CJUITextView插入特殊文本改用<br/>
`-insertSpecialText:(CJTextViewModel *)textModel atIndex:(NSUInteger)loc`方法，<br/>
同时优化了内部实现。


## CJTextView
### 简介
自定义UITextView：
* 1、添加placeHold提示
* 2、输入时可插入不可编辑的自定义文本（如＃主题＃，@人名）；
* 3、UITextView高度可根据输入内容动态调整<br/><br/>
![](http://7xnrwl.com1.z0.glb.clouddn.com/textView.gif)
<br />

##引用到项目中
### 文件引用
下载demo后直接把CJUITextView文件夹添加到项目中
<br />
### cocoapods安装
* Podfile<br/>
```ruby
platform :ios, '7.0'
pod 'CJTextView', '~> 0.0.3'
```

##属性介绍
```objective-c
/**
 *  placeHold提示内容Insets值(default (4, 4, 4, 4))
 */
@property (nonatomic, assign, setter=setPlaceHoldContainerInset:) UIEdgeInsets placeHoldContainerInset;
/**
 *  是否根据输入内容自动调整高度(default NO)
 */
@property (nonatomic, assign, setter=setAutoLayoutHeight:) BOOL autoLayoutHeight;
/**
 *  autoLayoutHeight为YES时的最大高度(default MAXFLOAT)
 */
@property (nonatomic, assign) CGFloat maxHeight;
/**
 *  插入文本的颜色(default self.textColor)
 */
@property (nonatomic, strong, getter=getSpecialTextColor) UIColor *specialTextColor;
/**
 *  插入文本是否可编辑(default NO)
 */
@property (nonatomic, assign) BOOL enableEditInsterText;
```

##调用方法
  ```objective-c
  /**
   *  在指定位置插入字符，并返回插入字符后的SelectedRange值
   *
   *  @param specialText    要插入的字符
   *  @param selectedRange  插入位置
   *  @param attributedText 插入前的文本
   *
   *  @return 插入字符后的光标位置
   */
  - (NSRange)insterSpecialTextAndGetSelectedRange:(NSAttributedString *)specialText
                                  selectedRange:(NSRange)selectedRange
                                           text:(NSAttributedString *)attributedText;
  ```
  调用示例:
  ```objective-c
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"#插入文本#"];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, str.length)];
    [self.textView insterSpecialTextAndGetSelectedRange:str selectedRange:self.textView.selectedRange text:self.textView.attributedText];
  ```

## 更新日志
#### 0.0.1
发布版本，支持：1、添加placeHold提示；2、输入时可插入不可编辑的自定义文本（如＃主题＃，@人名）；3、UITextView高度可根据输入内容动态调整

#### 0.0.2
修复移除KVO监测的bug，添加placeHoldContainerInset设置

#### 0.0.3、0.0.4
修复KVO监测问题

#### 0.0.5
设置默认字体

#### 0.0.6
增加`CJUITextView:placeHoldLabelHidden:`以及`CJUITextView:changeSelectedRange:`回调

#### 0.0.7
插入特殊字符判空处理

#### 0.0.8
修复iOS9以下系统的KVO问题

#### 0.0.9
修复语音输入空白语音的错误
