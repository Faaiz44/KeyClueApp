//
//  AppDelegate.swift
//  keyclue
//
//  Created by confiz-2333 on 10/7/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import UIKit
import FirebaseRemoteConfig
import FirebaseDynamicLinks
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , UNUserNotificationCenterDelegate, MessagingDelegate{
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
    }
    

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("app registered for APNS")
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().remoteMessageDelegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
//         FirebaseOptions.defaultOptions()?.deepLinkURLScheme = self.customURLScheme
        FirebaseApp.configure ()
        return true
    }

    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return application(app, open: url, sourceApplication: nil, annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let dynamicLink = DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
        if let dynamicLink = dynamicLink {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            self.HandleIncomingDynamicLink(dynamiclink: dynamicLink)
            return true
        }
        
        return false
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let dynamicLinks = DynamicLinks.dynamicLinks() else {
            return false
        }
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
                            if let dynamiclink =  dynamiclink, let _ = dynamiclink.url {
                                self.HandleIncomingDynamicLink(dynamiclink: dynamiclink)
                            }
        }
        
        
        return handled
    }
    
        func HandleIncomingDynamicLink(dynamiclink: DynamicLink)
        {
            print ("your incoming url is: \(dynamiclink.url) ")
        }
    
    
    //    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    //        if let incomingURL = userActivity.webpageURL{
    //            let linkHandled = DynamicLinks.dynamicLinks()!.handleUniversalLink(incomingURL, completion: { (dynamiclink, error) in
    //                if let dynamiclink =  dynamiclink, let _ = dynamiclink.url {
    //                    self.HandleIncomingDynamicLink(dynamiclink: dynamiclink)
    //                }
    //            })
    //            return linkHandled
    //        }
    //        return false
    //    }
    //    func HandleIncomingDynamicLink(dynamiclink: DynamicLink)
    //    {
    //        print ("your incoming url is: \(dynamiclink.url) ")
    //    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

