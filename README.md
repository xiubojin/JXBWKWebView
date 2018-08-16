
##使用CocoaPods安装

```
pod 'JXBWebKit', '~> 1.0.1'
```



## 手动安装

拖动`JXBWebKit`文件夹到你的项目.

注意`Copy`选项需要选择`"Copy items into destination group's folder" and select "Create groups for any folders".`



## 示例

打开`JXBWebKitProject`执行项目。



## 使用方法

1.可以直接使用`JXBWebViewController`实例对象打开远程和本地的`HTML`.

2.可以从`JXBWebViewController`派生出一个子类，使用该子类实例打开远程和本地的`HTML`.

3.还可以从`JXBWKWebViewPool`获取一个可复用的`WebView`，使用该`WebView`打开远程和本地的`HTML`.



## 提供的功能

1.`WebView`适配不通机型.

2.`UI`支持（进度条、进度条颜色、back&close按钮）.

3.支持拦截URL.

4.通过`JSBridge`和`Web`进行交互,实测任何场景的交互操作都可满足!比如

- 打开`naive`任意页面.
- 获取`native`定位、推送、相册、相机等权限.
- 获取`native`数据。
- 调用`native`的任意`API`。
- 其他

5.对子类提供`WebView`父类的`hook`操作.

6.支持`WKWebView`的复用，通过复用优化启动性能以及内存占用.

7.支持各种自定义浏览器的`UserAgent`.

8.支持拦截`WebView`的网络请求.

9.支持操作`Cookie`.

10.`demo`中提供了让业务`H5`页面秒开的方案（`HTML`模板渲染 & 静态资源离线包）.

- 现在市面上绝大部分新闻类APP使用的都是HTML模板渲染方案.
- 除了资讯类页面外其他业务场景的H5都可使用离线包方案.



## 注意

关于上述第10条中提到的H5秒开方案需要`server`进行配合，因此在这里我使用`Go`语言进行后台开发，`server`提供了两个`API`：

1.一个普通的`get`请求，`client`通过获取响应数据中的`html`渲染模板进行渲染。

2.一个下载服务器离线包资源的接口。

当然，要想看这个功能的具体实现效果，需要在本地配置`Go`的开发环境，详见如下步骤：

1.使用`brew install go`安装golang.

2.环境配置

（1）使用`cd ~`切换到根目录.

（2）使用`ls -all`查看所有文件，看有没有`.bash_profile`文件.

（3）没有就创建一个`touch .bash_profile`

使用`vim`打开`.bash_profile`进行编辑，`i`进行编辑，编辑完成后`:wq`退出，编辑内容如下：

````
export GOPATH=/Users/<your name>/Document/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
````

（4）切换到`Documents`文件夹，创建`go`文件夹，再在`go`文件夹下分别创建`bin`、`src`文件夹，`src`就是以后存放项目的文件夹.

（5）在终端输入`go env`命令查看配置是否正确，`GOBIN`有值表示配置没问题.

（6）在本工程内搜索文件夹`GoProject > src > OfflineServer`，将`OfflineServer`文件夹拷贝至`Doument > go > src`目录下.

（7）切换至`Document > go > src`

（8）`go build`编译项目.

（9）`go run`运行项目.

（10）不再需要开启`server`服务可以`control+c`退出.



## 整体架构

![image](https://github.com/xiubojin/JXBWebKit/blob/master/doc_imgs/share01.png)



## 关于JSBridge的实现原理图解

![image](https://github.com/xiubojin/JXBWebKit/blob/master/doc_imgs/share02.png)