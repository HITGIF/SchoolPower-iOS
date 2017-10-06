//
//  Copyright 2017 SchoolPower Studio

//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at

//  http://www.apache.org/licenses/LICENSE-2.0

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


import UIKit
import Material
import GoogleMobileAds
import UserNotifications
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let userDefaults = UserDefaults.standard
    let KEY_NAME = "loggedin"
    let TOKEN_KEY_NAME = "apns_token"
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
        IQKeyboardManager.sharedManager().enable = true
        DGLocalization.sharedInstance.startLocalization()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9841217337381410~2237579488")
        registerForPushNotifications(application: application)
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        var gotoController: UIViewController
        if userDefaults.object(forKey: KEY_NAME) == nil {
            
            userDefaults.register(defaults: [KEY_NAME: false])
            userDefaults.synchronize()
        }
        if userDefaults.bool(forKey: KEY_NAME) {
            
            gotoController = story.instantiateViewController(withIdentifier: "DashboardNav")
            gotoController.view.tag = 1
            let leftViewController = story.instantiateViewController(withIdentifier: "Drawer")
            UIApplication.shared.delegate?.window??.rootViewController = AppNavigationDrawerController(rootViewController: gotoController, leftViewController: leftViewController, rightViewController: nil)
        } else {
            
            gotoController = story.instantiateViewController(withIdentifier: "login")
            window = UIWindow(frame: Screen.bounds)
            window!.rootViewController = gotoController
        }
        window!.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        
        if userDefaults.object(forKey: TOKEN_KEY_NAME) == nil {
            userDefaults.register(defaults: [TOKEN_KEY_NAME: token])
            userDefaults.synchronize()
        } else {
            userDefaults.set(token, forKey: TOKEN_KEY_NAME)
        }
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        if userDefaults.object(forKey: TOKEN_KEY_NAME) == nil {
            userDefaults.register(defaults: [TOKEN_KEY_NAME: ""])
            userDefaults.synchronize()
        } else {
            userDefaults.set("", forKey: TOKEN_KEY_NAME)
        }
        print("Failed to register: \(error)")
    }
    
    func registerForPushNotifications(application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                guard granted else { return }
                //See if the premission is still there
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    guard settings.authorizationStatus == .authorized else { return }
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            //For lower than iOS 10.0
            let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
            let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            application.registerUserNotificationSettings(pushNotificationSettings)
            application.registerForRemoteNotifications()
        }
    }
}

