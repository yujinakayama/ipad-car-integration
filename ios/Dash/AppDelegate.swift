//
//  AppDelegate.swift
//  ETC
//
//  Created by Yuji Nakayama on 2019/05/28.
//  Copyright © 2019 Yuji Nakayama. All rights reserved.
//

import UIKit
import ParkingSearchKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    var tabBarController: TabBarController {
        return window?.rootViewController as! TabBarController
    }

    lazy var tabBarBadgeManager = TabBarBadgeManager(tabBarController: tabBarController)

    let assistant = Assistant()

    var modalViewController: UIViewController?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        _ = Firebase.shared
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if !Defaults.shared.isETCIntegrationEnabled {
            tabBarController.removeTab(.etc)
        }

        UserNotificationCenter.shared.setUp()

        Vehicle.default.connect()

        _ = tabBarBadgeManager

        return true
    }

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

    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        if let savedStateBundleVersion = coder.decodeObject(forKey: UIApplication.stateRestorationBundleVersionKey) as? String {
            let currentBundleVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
            return savedStateBundleVersion == currentBundleVersion
        } else {
            return false
        }
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if Firebase.shared.authentication.handle(url) {
            return true
        } else if let urlItem = ParkingSearchURLItem(url: url) {
            searchParkingsInMaps(mapItem: urlItem.mapItem)
            return true
        } else {
            return false
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Firebase.shared.messaging.deviceToken = deviceToken
    }

    private func searchParkingsInMaps(mapItem: MKMapItem) {
        let navigationController = tabBarController.viewController(for: .maps) as! UINavigationController
        let mapsViewController = navigationController.topViewController as! MapsViewController
        mapsViewController.startSearchingParkings(destination: mapItem)
        tabBarController.selectedViewController = navigationController
    }
}
