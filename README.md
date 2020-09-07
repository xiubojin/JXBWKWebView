如果你有好的想法，欢迎`Issue`或贡献代码！

如果你在使用该库的过程中遇到任何问题，可以通过我的邮箱或`Issue`联系到我。


## 使用CocoaPods安装

```
pod 'JXBWebKit', '~> 1.2.1'
```



## 手动安装

拖动`JXBWebKit`文件夹到你的项目.

注意`Copy`选项需要选择`"Copy items into destination group's folder" and select "Create groups for any folders".`



## 示例

打开`JXBWebKitProject`直接执行项目。



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
export GOPATH=/Users/<your name>/Documents/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
````

（4）切换到`Documents`文件夹，创建`go`文件夹，再在`go`文件夹下分别创建`bin`、`src`文件夹，`src`就是以后存放项目的文件夹.

（5）在终端输入`go env`命令查看配置是否正确，`GOBIN`有值表示配置没问题.

（6）在本工程内搜索文件夹`GoProject > src > OfflineServer`，将`OfflineServer`文件夹拷贝至`Documents > go > src`目录下.

（7）切换至`Documents > go > src`

（8）`go build`编译项目.

（9）`go run main.go`运行项目.

（10）不再需要开启`server`服务可以`control+c`退出.



## 整体架构

![image](https://github.com/xiubojin/JXBWebKit/blob/master/doc_imgs/share01.png)



## 关于JSBridge的实现原理

### 图解

![image](https://github.com/xiubojin/JXBWebKit/blob/master/doc_imgs/share02.png)



### JS调用Native

示例代码大家可以通过两种方式获取到，如下：

（1）找到当前工程目录，再找到`GoProject -> src -> OfflineServer -> source`，在`source`文件下有个压缩文件`offline_pkg.zip`，将该文件拷贝至别处解压，找到`resource`目录下的`offline.js`文件，里面就有示例代码，比如：

获取`native`的推送权限状态

```objective-c
function getPushAuthState() {
    window.JXBJSBridge.call({
           target : "push",
           action : "getAuthorityState",
           data : { 
             "id" : "123456789",
             "name" : "zhangsan"
           },
           callback : {
           success : function(result){document.getElementById('message').innerHTML = result;},
           fail : function(result){document.getElementById('message').innerHTML = result;},
           progress : function(result){document.getElementById('message').innerHTML = result;},
           }
	});
}
```

（2）在当前工程目录下有个`JSResources.bundle`文件，显示包内容，里面有个`index.html`，同样也有示例代码。



### Object-C代码如何写？

与`JS`约定好参数，`target、action、data、callback`等。

`target`：对应原生的目标类，格式为`Service_target`。

`action`：对应目标类的目标方法，格式为`func_action:`。

`data`：`JS`传给`Native`的数据。

`callback`：`Native`处理完业务后回调给`JS`的结果。

示例：

```objective-c
//获取推送权限状态
- (void)func_getAuthorityState:(NSDictionary *)param {
    BOOL isOpen = NO;
  
  	//获取id
  	NSString *ID = param[@"id"];
  
  	//获取name
  	NSString *name = param[@"name"];
    
    //iOS8.0以上
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (setting.types != UIUserNotificationTypeNone) {
        isOpen = YES;
    }
    
    void(^successCallback)(NSDictionary *result) = param[@"success"];
    
    NSDictionary *resultDict = @{@"isOpen":@(isOpen)};
    
    successCallback(resultDict);
}
```

### 如何与Android统一调用方式

当前库加载的注入脚本是`JXBJSBridge.js`，当`WebView`加载`HTML`时会在`window`上挂一个`call`方法，此时`call`方法相当于一个全局方法，供`JS`调用，这个脚本文件同样可以提供给`Android`使用，达到调用方式统一的目的。
