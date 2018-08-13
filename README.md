# JXBWebKit



##使用CocoaPods安装
```
pod 'JXBWebKit', '~> 1.0.1'
```



## 手动安装

拖动`JXBWebKit`文件夹到你的项目.

注意`Copy`选项需要选择`"Copy items into destination group's folder" and select "Create groups for any folders".`



## 示例

打开`JXBWebKitProject`执行运行。



## 使用方法

1.可以直接使用`JXBWebViewController`实例对象打开远程和本地的`HTML`.

2.可以从`JXBWebViewController`派生出一个子类，使用该子类实例对象打开远程和本地的`HTML`.

3.还可以从`JXBWKWebViewPool`获取一个可复用的`WebView`，使用该`WebView`打开远程和本地的`HTML`.



## 提供的功能

1.`WebView`适配不通机型.

2.`UI`支持（进度条、进度条颜色、back&close按钮）.

3.支持拦截URL.

4.通过`JSBridge`和`Web`进行交互,实测任何场景的交互操作都可满足!

5.对子类提供`WebView`父类的`hook`操作.

6.支持`WKWebView`的复用.

7.支持各种自定义浏览器的`UserAgent`.

8.支持拦截`WebView`的网络请求.

9.支持操作`Cookie`.

10.`demo`中提供了让业务`H5`页面秒开的方案（`HTML`模板渲染 & 静态资源离线包）.



## 关于JSBridge的实现原理图解

![](https://github.com/xiubojin/JXBWebKit/tree/master/doc_imgs/share01.png)

