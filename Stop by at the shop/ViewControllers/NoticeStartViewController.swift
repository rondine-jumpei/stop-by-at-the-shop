//
//  NoticeStartViewController.swift
//  Stop by at the shop
//
//  Created by ろーんでぃね on 2020/09/08.
//  Copyright © 2020 ろーんでぃね. All rights reserved.
//

import UIKit
import UserNotifications
import NotificationCenter
import RealmSwift
import MapKit



class NoticeStartViewController: UIViewController {
    
    @IBOutlet weak var noticeStartButton: UIButton!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        noticeStartButton.layer.cornerRadius = 60
        noticeStartButton.layer.borderWidth = 5
        noticeStartButton.layer.borderColor = UIColor.link.cgColor
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
        }
        
        
        let realm = try! Realm()
        let noticeTiming = realm.objects(noticeTimingRealm.self)
        
        if noticeTiming.count == 0 || noticeTiming[0].spot == "intoRadius"{
            let noticePoint = realm.objects(mapPointRealm.self).filter("switchState == 1")
            let noticeRadius = realm.objects(radiusRealm.self)
            if noticePoint.count != 0 {
                let location = CLLocation(latitude: noticePoint[0].latitude, longitude: noticePoint[0].longitude)
                CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                    guard let placemark = placemarks?.first, error == nil else { return }
                    self.pointLabel.text = placemark.name
                }
                if noticeRadius.count == 0{
                    self.radiusLabel.text = "の300m以内に入ったら通知します！"
                } else if noticeRadius.count != 0{
                    self.radiusLabel.text = "の\(noticeRadius[0].radius)m以内に入ったら通知します！"
                }
            } else if noticePoint.count == 0{
                self.pointLabel.text = "地点が設定されていません！"
                self.radiusLabel.text = "「マップ」タブにて、\n地点を設定してください！"
                self.noticeStartButton.isEnabled = false
                self.noticeStartButton.layer.borderColor = UIColor.gray.cgColor
            }

        } else if noticeTiming[0].spot == "arrival" {
            let noticePoint = realm.objects(mapPointRealm.self).filter("switchState == 1")
            if noticePoint.count != 0{
                let location = CLLocation(latitude: noticePoint[0].latitude, longitude: noticePoint[0].longitude)
                CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                    guard let placemark = placemarks?.first, error == nil else { return }
                    self.pointLabel.text = placemark.name
                }
                self.radiusLabel.text = "の付近に着いたら通知します！"
            } else if noticePoint.count == 0{
                self.pointLabel.text = "地点が設定されていません！"
                self.radiusLabel.text = "「マップ」タブにて、\n地点を設定してください！"
                self.noticeStartButton.isEnabled = false
                self.noticeStartButton.layer.borderColor = UIColor.gray.cgColor
            }
        }
        
    }
    
    
    @IBAction func noticeStartButton(_ sender: Any){
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  
        let realm = try! Realm()
        let noticeTiming = realm.objects(noticeTimingRealm.self)
        
        
        if noticeTiming.count == 0 || noticeTiming[0].spot == "intoRadius" {
            let content = UNMutableNotificationContent()
            content.title = "買い物通知です！"
            content.body = "帰る前にお店に寄りましょう！"
            content.sound = UNNotificationSound.default
            let realm = try! Realm()
            let noticePoint = realm.objects(mapPointRealm.self).filter("switchState == 1")
            let radius = realm.objects(radiusRealm.self)
            if radius.count != 0 && noticePoint.count != 0{
                let rad: Double = Double(radius[0].radius)
                let lat = noticePoint[0].latitude
                let lon = noticePoint[0].longitude
                let coordinate = CLLocationCoordinate2DMake(lat, lon)
                let region = CLCircularRegion.init(center: coordinate, radius: rad, identifier: "notice")
                region.notifyOnExit = false
                region.notifyOnEntry = true
                let trigger = UNLocationNotificationTrigger.init(region: region, repeats: false)
                let request = UNNotificationRequest.init(identifier: "notice", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            } else if radius.count == 0 && noticePoint.count != 0 {
                let lat = noticePoint[0].latitude
                let lon = noticePoint[0].longitude
                let coordinate = CLLocationCoordinate2DMake(lat, lon)
                let region = CLCircularRegion.init(center: coordinate, radius: 300.0, identifier: "notice")
                region.notifyOnExit = false
                region.notifyOnEntry = true
                let trigger = UNLocationNotificationTrigger.init(region: region, repeats: false)
                let request = UNNotificationRequest.init(identifier: "notice", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        } else if noticeTiming[0].spot == "arrival" {
            let content = UNMutableNotificationContent()
            content.title = "買い物通知です！"
            content.body = "買い物忘れはないですか？"
            content.sound = UNNotificationSound.default
            let realm = try! Realm()
            let noticePoint = realm.objects(mapPointRealm.self).filter("switchState == 1")
            if noticePoint.count != 0 {
                let lat = noticePoint[0].latitude
                let lon = noticePoint[0].longitude
                let coordinate = CLLocationCoordinate2DMake(lat, lon)
                let region = CLCircularRegion.init(center: coordinate, radius: 5.0, identifier: "notice")
                region.notifyOnExit = false
                region.notifyOnEntry = true
                let trigger = UNLocationNotificationTrigger.init(region: region, repeats: false)
                let request = UNNotificationRequest.init(identifier: "notice", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
        self.dismiss(animated: true, completion: nil)
        
    }
}
