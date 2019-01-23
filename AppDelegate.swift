//
//  AppDelegate.swift
//  ladGame1.1
//
//  Created by Jiahuan Li on 1/19/16.
//  Copyright © 2016 Jiahuan Li. All rights reserved.
//

import UIKit
import CoreData
import AVOSCloud

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"
func fatalCoreDataError(error: ErrorType) {
    print("*** Fatal error: \(error)")
    NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: nil)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    //load data model & connect to SQLite
    lazy var managedObjectContext: NSManagedObjectContext = {
        guard let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") else {
            fatalError("Could not find data model in app bundle")
        }
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing model from: \(modelURL)")
        }
        let urls = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
        let documentsDirectory = urls[0]
        let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
        print(storeURL)
        do {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil, URL: storeURL, options: nil)
//            coordinator.persistentStoreForURL(storeURL)
            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            return context
        } catch {
            fatalError("Error adding persistent store at \(storeURL): \(error)")
        }
    }()
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //leanCloud
//        基础设置
//        [AVOSCloud setApplicationId:@"{{741389504@qq.com}}"
//        clientKey:@"{{passw0rd}}"];
         AVOSCloud.setApplicationId("4cEqI55saB9I86Uy9cBUgLyG-gzGzoHsz", clientKey: "V9fu3zYKSsKa0zOaGUdjivii")
//        如果想跟踪统计应用的打开情况，后面还可以添加下列代码
//        [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
//        AVObject *testObject = [AVObject objectWithClassName:@"TestObject"];
//        [testObject setObject:@"bar" forKey:@"foo"];
//        [testObject save];
        
//        运行 app，一个类名为 TestObject 的新对象会被发送到 LeanCloud 并保存下来。当做完这一切，访问 控制台 > 数据管理 可以看到上面创建的 TestObject 的相关数据。
        
        
        // Override point for customization after application launch.
        
        
        //ShareSDK1.1
//        ShareSDK.registerApp("43388a77b630")
        //新浪微博
//        ShareSDK.connectSinaWeiboWithAppKey("266554492", appSecret: "c13be563ce73bb06c7f8eab211e66f58", redirectUri: "http://www.ucai.cn")
//        //链接微信
//        ShareSDK.connectWeChatWithAppId("wx5f09f3b56fd1faf7", wechatCls: WXApi.classForCoder())
//        //微信好友
//        ShareSDK.connectWeChatSessionWithAppId("wx5f09f3b56fd1faf7", wechatCls:WXApi.classForCoder())
//        //微信朋友圈
//        ShareSDK.connectWeChatTimelineWithAppId("wx5f09f3b56fd1faf7", wechatCls: WXApi.classForCoder())
//        ShareSDK.connectRenRenWithAppKey("3899f3ffa97544a3a6767ce3d7530142", appSecret: "373c73a1202e02a")
        //SDK1.2
        ShareSDK.registerApp("iosv1101",
            
            activePlatforms: [SSDKPlatformType.TypeSinaWeibo.rawValue,
                SSDKPlatformType.TypeTencentWeibo.rawValue,
                SSDKPlatformType.TypeFacebook.rawValue,
                SSDKPlatformType.TypeWechat.rawValue,],
            onImport: {(platform : SSDKPlatformType) -> Void in
                
                switch platform{
                    
                case SSDKPlatformType.TypeWechat:
                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                    
                default:
                    break
                }
            },
            onConfiguration: {(platform : SSDKPlatformType,appInfo : NSMutableDictionary!) -> Void in
                switch platform {
                    
                case SSDKPlatformType.TypeSinaWeibo:
                    //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                    appInfo.SSDKSetupSinaWeiboByAppKey("568898243",
                        appSecret : "38a4f8204cc784f81f9f0daaf31e02e3",
                        redirectUri : "http://www.sharesdk.cn",
                        authType : SSDKAuthTypeBoth)
                    break
                    
                case SSDKPlatformType.TypeWechat:
                    //设置微信应用信息
                    appInfo.SSDKSetupWeChatByAppId("wx4868b35061f87885", appSecret: "64020361b8ec4c99936c0e3999a9f249")
                    break
                    
                    default:
                    break
                }

        })
        //end
//        let tabBarController = window!.rootViewController as! UITabBarController
//        if let tabBarViewControllers = tabBarController.viewControllers {
//            let firstnavigationController = tabBarViewControllers[0] as! UINavigationController
//            let checklistViewController = firstnavigationController.viewControllers[0] as! ChecklistViewController
//            checklistViewController.managedObjectContext = managedObjectContext
//            let secondnavigationController = tabBarViewControllers[1] as! UINavigationController
//            let historyViewController = secondnavigationController.viewControllers[2] as! HistoryViewController
//            historyViewController.managedObjectContext = managedObjectContext
//            
//            let thirdnavigationController = tabBarViewControllers[1] as! UINavigationController
//            let inventoryViewController = thirdnavigationController.viewControllers[1] as! InventoryViewController
//            inventoryViewController.managedObjectContext = managedObjectContext
//            //end
//
//        }
        listenForFatalCoreDataNotifications()
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
            print("didReceiveLocalNotification \(notification)")
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
        // listen for fatalCoreDataError()
    func listenForFatalCoreDataNotifications() {
        NSNotificationCenter.defaultCenter().addObserverForName(MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
            
            let alert = UIAlertController(title: "Internal Error",
                message: "There was a fatal error in the app and it cannot continue.\n\n"
                    + "Press OK to terminate the app. Sorry for the inconvenience.",
                preferredStyle: .Alert)
            
            let action = UIAlertAction(title: "OK", style: .Default) { _ in
                let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            }
            
            alert.addAction(action)
            
            self.viewControllerForShowingAlert().presentViewController(
                alert, animated: true, completion: nil)
        })
    }
    
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
}

//save extension
//extension ChecklistItem {
//    
//    @NSManaged var checked: Bool
//    @NSManaged var dueDate: NSDate
//    @NSManaged var itemID: NSNumber
//    @NSManaged var rank: NSNumber
//    @NSManaged var shouldRemind: Bool
//    @NSManaged var text: String
//    
//}

//extension InventoryItem {
//    
//    @NSManaged var name: String
//    @NSManaged var num: NSNumber
//    @NSManaged var used: Bool
//    
//}

//extension NamelistItem {
//    
//    @NSManaged var age: NSNumber
//    @NSManaged var alive: Bool
//    @NSManaged var gender: Bool
//    @NSManaged var name: String
//    @NSManaged var lastTime: NSDate?
//    @NSManaged var iconImg: String?
//    
//}



