# TextViewDemo
## 简介
自定义UITextView：
* 1、添加placeHold提示
* 2、输入时可插入不可编辑的自定义文本（如＃主题＃，@人名）；
* 3、UITextView高度可根据输入内容动态调整<br/><br/>
![](http://7xnrwl.com1.z0.glb.clouddn.com/textView.gif)
<br />

##调用方法
### 文件引用
下载demo后直接把CJUITextView文件夹添加到项目中
<br />
### cocoapods安装
* Podfile<br/>
```ruby
platform :ios, '7.0'
pod 'CJTextView', '~> 0.0.1'
```

###属性介绍
```objective-c
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
```

###调用方法
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
