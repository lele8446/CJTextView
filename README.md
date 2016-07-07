# TextViewDemo
## 简介
自定义UITextView：
* 1、输入时可插入不可编辑的自定义文本（如＃主题＃，@人名）；
* 2、UITextView高度可根据输入内容动态调整<br/>
![](https://o44fado6w.qnssl.com/test.gif)
<br />

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
  ```
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"#插入文本#"];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, str.length)];
    [self.textView insterSpecialTextAndGetSelectedRange:str selectedRange:self.textView.selectedRange text:self.textView.attributedText];
  ```
