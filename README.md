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