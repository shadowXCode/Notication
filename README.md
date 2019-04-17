# Notication
iOS Notification

参考文章：[iOS 推送通知及推送扩展](https://juejin.im/post/5bc9a6e45188254a075e305c)

[iOS推送之远程推送](https://www.jianshu.com/p/4b947569a548)

[玩转 iOS 10 推送 —— UserNotifications Framework（上）](https://www.jianshu.com/p/2f3202b5e758)

[玩转 iOS 10 推送 —— UserNotifications Framework（中）](https://www.jianshu.com/p/5a4b88874f3a)

[玩转 iOS 10 推送 —— UserNotifications Framework（下）](https://www.jianshu.com/p/25ca24215f75)

[iOS 10 消息推送（UserNotifications）秘籍总结（二）](https://www.jianshu.com/p/81c6bd16c7ac)

[APNs Auth Key Token 验证模式](https://www.jianshu.com/p/b700f0237b0e)

[WWDC 2018：iOS 12 通知的新特性](https://juejin.im/post/5b1b7c3de51d4506ca62d787)

[iOS App Extension入门](https://www.jianshu.com/p/8cf08db29356)



```json
{
    "aps": {
        "alert": {
            "title": "Title...",
            "subtitle": "Subtitle...",
            "body": "Body..."
        },
        "sound": "default",
        "badge": 1,
        "mutable-content": 1,
	    "content-available":1,
        "category": "UNInviteCategoryIdentifier"
    },
    "msgid": "123",
    "media": {
        "type": "image",
        "url": "https://www.fotor.com/images2/features/photo_effects/e_bw.jpg"
    }
}

{
    "aps": {
        "alert": {
            "body": "好几天都不开看我啦？送一个@张小伙jsme的视频给你，看看我嘛！"
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



com.ershuai.notication
com.ershuai.notication.NotificationService
com.ershuai.notication.NotificationContent


com.touker.HBStockWarning
com.touker.HBStockWarning.Service
com.touker.HBStockWarning.Content

```