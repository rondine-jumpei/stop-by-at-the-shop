//
//  AppDelegate.swift
//  Stop by at the shop
//
//  Created by ろーんでぃね on 2020/08/08.
//  Copyright © 2020 ろーんでぃね. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import NotificationCenter
import CoreLocation
import Onboard
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager!
    var myTimer: Timer!

    
    func applicationWillEnterForeground(_ application: UIApplication) {

        locationManager.startUpdatingLocation()

        myTimer = Timer.scheduledTimer(timeInterval: Double(5), target: self, selector: #selector(locationUpdate), userInfo: nil, repeats: true)
                           myTimer.fire()
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return true }

        locationManager.startUpdatingLocation()
        myTimer = Timer.scheduledTimer(timeInterval: Double(5), target: self, selector: #selector(locationUpdate), userInfo: nil, repeats: true)
        myTimer.fire()
//        locationUpdate()
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
// 初回のみオンボード
        let realm = try! Realm()
        let alreadyOnboard = realm.objects(onboardRealm.self)
        if alreadyOnboard.count == 0{
            setOnBoard(application)
            let firstOnboard = onboardRealm()
            firstOnboard.onboard = 1
            try! realm.write { realm.add(firstOnboard) }
        }
        
        UNUserNotificationCenter.current().delegate = self
        IQKeyboardManager.shared.enable = true
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        myTimer = Timer.scheduledTimer(timeInterval: Double(5), target: self, selector: #selector(locationUpdate), userInfo: nil, repeats: true)
        myTimer.fire()
//        locationUpdate()
    }
    
//    通知からアプリ起動したらsegue
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "MainTabBar", bundle: nil)
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarViewController")as! MainTabBarViewController
        
        let nextStoryboard = UIStoryboard(name: "Map", bundle: nil)
        let nextViewController = nextStoryboard.instantiateViewController(withIdentifier: "NotificationViewController")as! NotificationViewController
        
        nextViewController.modalPresentationStyle = .automatic
        self.window?.rootViewController = firstViewController
        self.window?.makeKeyAndVisible()
        self.window!.rootViewController!.present(nextViewController, animated: true, completion: nil)
        
        completionHandler()
        
    }
 
    @objc func locationUpdate() {
               // stop -> start で位置情報更新させる
               locationManager.stopUpdatingLocation()
               locationManager.startUpdatingLocation()
           }
        
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let notification = Notification(name: NSNotification.Name(rawValue: "notice"), object:self, userInfo: userInfo)
        NotificationQueue.default.enqueue(notification, postingStyle: .whenIdle)
    }
    
    func setOnBoard(_ application: UIApplication) {
        if true {
            let content1 = OnboardingContentViewController(
                title: "Thanks For Downroad！",
                body: "Stop at the Shop!へようこそ！\nこのアプリで、日々の買い物忘れを防ごう。",
                image: UIImage(named: "0")?.resize(size: .init(width: 184.32, height: 184.32)),
                buttonText: "",
                action: nil
            )
            let content2 = OnboardingContentViewController(
                title: "使い方①\n設定",
                body: "検索か長押しで地点を設定しよう。\n「通知」をタップすれば通知設定完了。",
                image: UIImage(named: "1")?.resize(size: .init(width: 223.56, height: 268.38)),
                buttonText: "",
                action: nil
            )
            let content3 = OnboardingContentViewController(
                title: "使い方②\n買い物メモ",
                body: "「買い物メモ」を入力しておけば、\n通知からアプリを開いた時にお知らせ。",
                image: UIImage(named: "2")?.resize(size: .init(width: 223.56, height: 268.38)),
                buttonText: "",
                action: nil
            )
            let content4 = OnboardingContentViewController(
                        title: "使い方③\n通知タイミングの変更",
                        body: "マップの円の半径を変えたり、\nお店に到着した時に通知するようにしたり。",
                image: UIImage(named: "3")?.resize(size: .init(width: 223.56, height: 161.82)),
                        buttonText: "はじめる",
                        action: {
                            let storyboard: UIStoryboard = UIStoryboard(name: "MainTabBar", bundle: nil)
                            let firstVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarViewController")as! MainTabBarViewController
                            self.window?.rootViewController = firstVC
                            self.window?.makeKeyAndVisible()
                        }
                    )
                    
            content1.titleLabel.font = content1.titleLabel.font.withSize(24)
            content1.bodyLabel.font = content1.bodyLabel.font.withSize(14)
            content2.titleLabel.font = content2.titleLabel.font.withSize(24)
            content2.bodyLabel.font = content2.bodyLabel.font.withSize(14)
            content3.titleLabel.font = content3.titleLabel.font.withSize(24)
            content3.bodyLabel.font = content3.bodyLabel.font.withSize(14)
            content4.titleLabel.font = content4.titleLabel.font.withSize(24)
            content4.bodyLabel.font = content4.bodyLabel.font.withSize(14)
            
            let vc = OnboardingViewController(
                backgroundImage: UIImage(named: "back"),
                contents: [content1, content2, content3, content4]
            )
            
            vc?.allowSkipping = true
            vc?.skipHandler = {
                let storyboard: UIStoryboard = UIStoryboard(name: "MainTabBar", bundle: nil)
                let homeView = storyboard.instantiateViewController(withIdentifier: "MainTabBarViewController")as! MainTabBarViewController
                self.window?.rootViewController = homeView
                self.window?.makeKeyAndVisible()
            }

            content4.viewWillAppearBlock = { vc?.skipButton.isHidden = true }
            content4.viewDidDisappearBlock = { vc?.skipButton.isHidden = false }
            window?.rootViewController = vc
        }
    }
}

