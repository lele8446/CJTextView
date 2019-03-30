#
#  Be sure to run `pod spec lint CJTextView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "CJTextView"
  s.version      = "2.0.2"
  s.summary      = "自定义UITextView，显示默认提示语，自动调整高度，编辑可插入@人名，#标签#。"
  s.homepage     = "https://github.com/lele8446/TextViewDemo"

  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
  s.author       = { "lele8446" => "641003000@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/lele8446/TextViewDemo.git", :tag => "2.0.2" }
  s.source_files  = "CJUITextView/*"

  
end
