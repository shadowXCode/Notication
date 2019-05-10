# Notication
iOS Notification

参考文章：
[iOS 推送通知及推送扩展](https://juejin.im/post/5bc9a6e45188254a075e305c)

[iOS推送之远程推送](https://www.jianshu.com/p/4b947569a548)

[玩转 iOS 10 推送 —— UserNotifications Framework（上）](https://www.jianshu.com/p/2f3202b5e758)

[玩转 iOS 10 推送 —— UserNotifications Framework（中）](https://www.jianshu.com/p/5a4b88874f3a)

[玩转 iOS 10 推送 —— UserNotifications Framework（下）](https://www.jianshu.com/p/25ca24215f75)

[iOS 10 消息推送（UserNotifications）秘籍总结（二）](https://www.jianshu.com/p/81c6bd16c7ac)

[APNs Auth Key Token 验证模式](https://www.jianshu.com/p/b700f0237b0e)
这种推送方式也需要开启对应推送权限，在开发者账号的appid中证书会显示警告，可以忽略。

[WWDC 2018：iOS 12 通知的新特性](https://juejin.im/post/5b1b7c3de51d4506ca62d787)

[iOS App Extension入门](https://www.jianshu.com/p/8cf08db29356)

[iOS10推送通知整理总结](https://www.jianshu.com/p/f465fde82c4b)

[iOS Push的前世今生](https://juejin.im/entry/5a9118d2f265da4e6f17fcfc)

[iOS图片推送的一些开发小Tips](https://www.jianshu.com/p/0ab721604877)

[ios 推送通知（四）](https://www.zybuluo.com/evolxb/note/482251)






## 远程推送原理，推送证书配置的两种方式
### 原理
iOS app大多数都是基于client/server模式开发的，client就是安装在我们设备上的app，server就是对应远程服务器，主要给app提供数据，也被成为Provider。那么当app处于terminate状态时，当client与server断开时，就需要通过APNs（Apple Push Notification service）进行通信。

推送消息传输路径： Provider-APNs-Client App

我们的设备联网时（无论是蜂窝联网还是Wi-Fi联网）都会与苹果的APNs服务器建立一个长连接（persistent IP connection），当Provider推送一条通知的时候，这条通知并不是直接推送给了我们的设备，而是先推送到苹果的APNs服务器上面，而苹果的APNs服务器再通过与设备建立的长连接进而把通知推送到我们的设备上（如下图）。而当设备处于非联网状态的时候，APNs服务器会保留Provider所推送的最后一条通知，当设备转换为连网状态时，APNs则把其保留的最后一条通知推送给我们的设备；如果设备长时间处于非联网状态下，那么APNs服务器为其保存的最后一条通知也会丢失。Remote Notification必须要求设备连网状态下才能收到，并且太频繁的接收远程推送通知对设备的电池寿命是有一定的影响的。
![](assets/notification/APNs_principle.png)

### deviceToken
当一个App注册接收远程通知时，系统会发送请求到APNs服务器，APNs服务器收到此请求会根据请求所带的key值生成一个独一无二的value值也就是所谓的deviceToken，而后APNs服务器会把此deviceToken包装成一个NSData对象发送到对应请求的App上。然后App把此deviceToken发送给我们自己的服务器，就是所谓的Provider。Provider收到deviceToken以后进行储存等相关处理，以后Provider给我们的设备推送通知的时候，必须包含此deviceToken。(参考下图理解)
![](assets/notification/APNs_deviceToken_1.png)
![](assets/notification/APNs_deviceToken_2.png)

* deviceToken是什么：deviceToken其实就是根据注册远程通知的时候向APNs服务器发送的Token key，Token key中包含了设备的UDID和App的Bundle Identifier，然后苹果APNs服务器根据此Token key编码生成一个deviceToken。deviceToken可以简单理解为就是包含了设备信息和应用信息的一串编码。

* deviceToken作用：上面提到Provider推送消息的时候必须带有此deviceToken，然后此消息就根据deviceToken（UDID + App's Bundle Identifier）找到对应的设备以及该设备上对应的应用，从而把此推送消息推送给此应用。

* deviceToken唯一性：苹果APNs的编码技术和deviceToken的独特作用保证了他的唯一性。唯一性并不是说一台设备上的一个应用程序永远只有一个不变的deviceToken，当用户升级系统、app重新安装的时候deviceToken是会变化的。

### JSON payload
远程推送主要通过JSON payload进行传递信息，payload中包含了不同推送类型，用户交互（alert、sound、badge）以及app自定义信息。（此处参考[官方文档](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification)）
![](assets/notification/APNs_interactions.png)

一个基础的远程推送payload包含Apple-defined keys和自定义keys，你可以添加不同的keys在payload中；但是APNs也针对如下情况进行推送限制：
   
1. Voice over Internet Protocol (VoIP)推送最大payload不能超过5k(5120 bytes)
2. 其他所有的远程推送，payload大小不能超过4k(4096 bytes)

payload就是一个json数据结构，payload数据结构中除了苹果定义的keys，开发者可以自定义keys，自定义的keys在UNNotificationContent中userInfo属性中。
sound字段中的音频文件必须是在设备中已存在的或者app的bundle中存在的。
避免在推送payload中放入一些敏感字段，防止信息泄露；如果迫不得已，需要对该信息进行加密。

payload数据结构示例
```json
{
    "aps": {
        "alert": {
            "body": "好几天都不开看我啦？送一个@张小伙jsme的视频给你，看看我嘛！",
            "loc-key": "LOC_KEY",
            "loc-args": ["替换参数一","替换参数二"]
        },
        "sound": "default",
        "badge": 1,
        "mutable-content": 1,
	   "category": "UNInviteCategoryIdentifier"
    },
    "msgid": "123",
    "media": {
        "type": "image",
        "url": "https://www.fotor.com/images2/features/photo_effects/e_bw.jpg"
    }
}
```
数据结构详细说明
```js
{
    "aps": {
        "alert": {//alert字段也支持字符串，因为在iOS10之前是仅有一个标题没有这么多扩展，例如："alert": "标题"
            "title": "标题",
            "subtitle": "副标题",
            "body": "主题内容",
            "loc-key": "主要用于本地化，本地化字符串标示；在本地化标示对应的value中可用使用%@,%n$@来从title-loc-args中添加格式化字符串",
            "loc-args": "loc-key对应值中的格式化字符串",
            "launch-image": ""
        },
        "sound": {//sound字段也支持字符串，例如：'sound': 'default'。针对扩展字段的支持iOS12系统才有效
            "critical": 1,//⚠️标示，设置为1有效，在iOS12下尝试，并没有效果体现
            "name": "default",//声音名称，若为自定义声音，要保证app bundle存在该声音资源；特殊值‘default’是指用系统默认声音提示
            "volume": 0.5//音量大小，范围0~1，在iOS12下尝试，并没有效果体现
        },
        "badge": 1,//通知icon的角标数量
        "content-available": 1,//若设置为1时有效，表示有新的内容。通常用于静默通知，通过alert、sound、badge字段为空。若app进程不存在情况下会唤醒app调用[UIApplicationDelegate application:didReceiveRemoteNotification:fetchCompletionHandler:]代理，有30s的时间处理通知。
        "mutable-content": 1,//设置为1，表示该通知会先会调起Notification Service Extension处理完后再进行通知
	    "category": "UNInviteCategoryIdentifier",//只要是指Notification Content Extension中使用哪个category进行展示
        "thread-id": "threadIdentifier",//线程标识符，主要应用于iOS12及以后系统，进行通知分组
        "launch-image": ""//用户通过通知进入应用时，使用这个文件（启动图文件或者storyboard文件）的启动图片。如果没有指定这个属性，系统会使用上次的应用快照或者Info.plist中UILaunchImageFile的图片或Default.png作为启动图片。该字段不适用于iOS，仅用于macos和tvos
    },
    
    //除aps字段中为官方定义keys外，以下字段都可以自定义

    "msgid": "123",
    "media": {
        "type": "image",
        "url": "https://www.fotor.com/images2/features/photo_effects/e_bw.jpg"
    }
}

```

### 证书配置 - [Certificate-Based Connection](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_certificate-based_connection_to_apns)

这种证书配置比较常见，通过应用App ID创建推送SSL证书，下载证书导出对应的P12文件进行推送。
![](assets/notification/APNs_SSL_Certificate.png)

证书通过应用程序的Bundle Identifier进行绑定。还必须将证书绑定到证书签名请求(CSR)，这是用于
