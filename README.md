**注意**

***V2.0.0 版本新增CJDisplayTextView，提供富文本显示功能，可自动识别网址、日期、地址、电话以及添加自定义点击链点。<br/>
引入CJTextViewModel，CJUITextView插入特殊文本改用:<br/>
`-insertSpecialText:(CJTextViewModel *)textModel atIndex:(NSUInteger)loc`方法，<br/>
同时优化了内部实现。***

## 效果图
![](http://7xnrwl.com1.z0.glb.clouddn.com/CJTextView.gif)

## CJTextView简介
自定义UITextView：
* 1、可设置placeHold默认提示语；
* 2、高度自动改变（autoLayoutHeight）设置，开启后TextView高度可根据输入内容动态调整
* 3、支持插入特殊文本，比如 @人名 、#主题#，同时设置插入文本是否可编辑，插入文本可携带自定义参数
* 4、TextView输入内容，可通过 `-allTextModel` 等相关方法建模输出<br/>

## CJDisplayTextView简介
CJDisplayTextView功能概要：
* 1、只支持浏览模式，不允许编辑。
* 2、可以根据显示内容动态调整高度，并自动识别网址、日期、地址、电话，点击则触发系统默认行为；
* 3、允许插入自定义点击链点，自定义链点请通过类方法`+linkStr:attributes:parameter:`生成，点击自定义链点会触发点击回调block和长按回调（长按只支持iOS10之后的系统）。

## 引用到项目中
### 文件引用
下载demo后直接把CJUITextView文件夹添加到项目中
<br />
### cocoapods安装
* Podfile<br/>
```ruby
platform :ios, '7.0'
pod 'CJTextView', '~> 2.0.0'
```

## 更新日志
* 2.0.0
优化内部实现，修复已知的一些问题。
新增CJDisplayTextView，提供富文本显示功能，可自动识别网址、日期、地址、电话以及添加自定义点击链点。
引入CJTextViewModel，插入与显示富文本均通过CJTextViewModel实现
* 0.0.9
修复语音输入空白语音的错误
* 0.0.8
修复iOS9以下系统的KVO问题
* 0.0.7
插入特殊字符判空处理
* 0.0.6
增加`CJUITextView:placeHoldLabelHidden:`以及`CJUITextView:changeSelectedRange:`回调
* 0.0.5
设置默认字体
* 0.0.3、0.0.4
修复KVO监测问题
* 0.0.2
修复移除KVO监测的bug，添加placeHoldContainerInset设置
* 0.0.1
发布版本，支持：1、添加placeHold提示；2、输入时可插入不可编辑的自定义文本（如＃主题＃，@人名）；3、UITextView高度可根据输入内容动态调整














