//
//  ViewController.swift
//  Stop by at the shop
//
//  Created by ろーんでぃね on 2020/08/08.
//  Copyright © 2020 ろーんでぃね. All rights reserved.
//





import UIKit
import MapKit
import RealmSwift
import UserNotifications


class MapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
   
    @IBOutlet weak var pointSearchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backToPresentLocationButton: UIButton!
    @IBOutlet weak var mapPointTableView: UITableView!
    @IBOutlet weak var segueToNoticeStartButton: UIButton!
    
    private let cellId = "mapPointCellId"
    private var locationManager: CLLocationManager!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInfo()
        mapView.userTrackingMode = .follow
        setRegion(coodinate: mapView.userLocation.coordinate)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(recognizeLongPress(sender:)))
        self.mapView.addGestureRecognizer(longPress)
    }
    
    
    
//   MARK: 現在地に戻る
    @IBAction func backToPresentLocationButton(_ sender: Any) {
        setRegion(coodinate: mapView.userLocation.coordinate)
    }
    
//    MARK:長押しでピン立て
    @objc func recognizeLongPress(sender: UILongPressGestureRecognizer) {
        //        1回目じゃないならreturn
        if sender.state != UIGestureRecognizer.State.began { return }
        let location = sender.location(in: self.mapView)
        let coodinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        let geo = CLLocation(latitude: coodinate.latitude, longitude: coodinate.longitude)
        setRegion(coodinate: coodinate)
        CLGeocoder().reverseGeocodeLocation(geo) { (placemarks, error) in
            guard let placemark = placemarks?.first, error == nil else { return }
            if let pinTitle = placemark.name{
                self.setPin(coodinate: coodinate, title: pinTitle)
                self.setCircle(coodinate: coodinate)
                self.addPoint(coodinate: coodinate)
            }
        }
    }
    
    //　　MARK:検索したとこにピン立て
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text {
            //            緯度経度を計算するクラスを生成
            let geocoder = CLGeocoder()
            //            上で生成した緯度経度計算クラスを使って、textの場所の緯度経度を取り出す
            geocoder.geocodeAddressString(text, completionHandler: {(placemarks, error) in
                if let unwrapPlacemarks = placemarks {
                    if let firstPlacemarks = unwrapPlacemarks.first {
                        if let location = firstPlacemarks.location {
                            let targetCoodinate = location.coordinate
                            self.setPin(coodinate: targetCoodinate, title: text)
                            self.setCircle(coodinate: targetCoodinate)
                            self.addPoint(coodinate: targetCoodinate)
                        }
                    }
                }
            })
        }
    }
    
    
    
    //    MARK:ピン立ての式 setPin
    private func setPin(coodinate: CLLocationCoordinate2D, title: String) {
        removePinAndCircle()

        let realm = try! Realm()
        let oldPoint = realm.objects(mapPointRealm.self).filter("switchState == 1")
        if oldPoint.count != 0{
            try! realm.write {
                oldPoint[0].switchState = 0
            }
        }
        
        let pin = MapAnnotationSetting()
        pin.coordinate = coodinate
        pin.title = title
        pin.pinImage = UIImage(named: "pin")?.resize(size: .init(width: 50, height: 70))
        
        self.mapView.addAnnotation(pin)
        setRegion(coodinate: coodinate)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
          // 自分の現在地は置き換えない(青いフワフワのマークのままにする)
          if (annotation is MKUserLocation) {
              return nil
          }

          let identifier = "pin"
          var annotationView: MKAnnotationView!

          if annotationView == nil {
              annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
          }

          // ピンにセットした画像をつける
          if let pin = annotation as? MapAnnotationSetting {
              if let pinImage = pin.pinImage {
                 annotationView.image = pinImage
              }
          }
          annotationView.annotation = annotation
          // ピンをタップした時の吹き出しの表示
          annotationView.canShowCallout = true

          return annotationView
      }

    
    //    MARK:中心になるよう移動 setRegion
    private func setRegion(coodinate: CLLocationCoordinate2D){
        self.mapView.region = MKCoordinateRegion(center: coodinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
    
    //    MARK:realmに位置追加　addPoint
    func addPoint(coodinate: CLLocationCoordinate2D)  {
        let realm = try! Realm()

        let newPoint = mapPointRealm()
        newPoint.latitude = Double(coodinate.latitude)
        newPoint.longitude = Double(coodinate.longitude)
        newPoint.switchState = 1

        try! realm.write {
            realm.add(newPoint)
        }
        self.mapPointTableView.reloadData()
    }
    
//    MARK:マップに円作成の式 setCircle
    func setCircle(coodinate: CLLocationCoordinate2D) {
        var circleSize = 300

        let realm = try! Realm()
        let circleSizeRealms = realm.objects(radiusRealm.self)
        if circleSizeRealms.count != 0 {
            let circleSizeRealm = circleSizeRealms[0]
            circleSize = circleSizeRealm.radius
        }
        let circle = MKCircle(center: coodinate, radius: CLLocationDistance(circleSize))
        mapView.addOverlay(circle)
    }
//    円を設置する式（上のmapView.addOverlay(circle)で呼ばれる）
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let circleView: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
        circleView.fillColor = UIColor.red
        circleView.strokeColor = UIColor.black
        circleView.alpha = 0.4
        circleView.lineWidth = 5
        return circleView
    }
//    pinと円を削除する式
    private func removePinAndCircle(){
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
//    MARK:セルの内容
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let mapPointList = realm.objects(mapPointRealm.self)
        return mapPointList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mapPointTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MapPointTableViewCell
        let realm = try! Realm()
        let mapPoints = realm.objects(mapPointRealm.self)
        let mapPoint = mapPoints[indexPath.row]
        let location = CLLocation(latitude: mapPoint.latitude, longitude: mapPoint.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first, error == nil else { return }
            cell.pointNameLabel.text = placemark.name
        }

        if mapPoint.switchState == 1{
            cell.pinImage.image = UIImage(named: "pin")?.resize(size: .init(width: 20, height: 30))
        }
        if mapPoint.switchState == 0{ cell.pinImage.image = nil }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realm = try! Realm()
        let newPoint = realm.objects(mapPointRealm.self)[indexPath.row]
        
        let coodinate = CLLocationCoordinate2DMake(newPoint.latitude, newPoint.longitude)
        let location = CLLocation(latitude: newPoint.latitude, longitude: newPoint.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first, error == nil else { return }
            if let title = placemark.name {
                self.setPin(coodinate: coodinate, title: title)
                self.setCircle(coodinate: coodinate)
            }
            try! realm.write { newPoint.switchState = 1 }
            self.mapPointTableView.reloadData()
            self.mapPointTableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let realm = try! Realm()
            let mapPointLists = realm.objects(mapPointRealm.self)
            let mapPointList = mapPointLists[indexPath.row]
            if mapPointList.switchState == 1 { removePinAndCircle() }
            try! realm.write { realm.delete(mapPointList) }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
//    MARK:setUpInfo
    func setUpInfo() {
        self.overrideUserInterfaceStyle = .light
        pointSearchBar.delegate = self
        mapView.delegate = self
        mapPointTableView.delegate = self
        mapPointTableView.dataSource = self
        mapPointTableView.register(UINib(nibName: "MapPointTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        mapPointTableView.rowHeight = 50
        backToPresentLocationButton.layer.cornerRadius = 20
        backToPresentLocationButton.layer.borderWidth = 2
        backToPresentLocationButton.layer.borderColor = UIColor.link.cgColor
        segueToNoticeStartButton.layer.cornerRadius = 10
        segueToNoticeStartButton.layer.borderWidth = 2
        segueToNoticeStartButton.layer.borderColor = UIColor.link.cgColor
        
        let realm = try! Realm()
        let points = realm.objects(mapPointRealm.self).filter("switchState == 1")
        if points.count != 0{
            let point = points[0]
            let coodinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
            let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                guard let placemark = placemarks?.first, error == nil else { return }
                if let title = placemark.name {
                    self.setPin(coodinate: coodinate, title: title)
                    self.setCircle(coodinate: coodinate)
                    try! realm.write { point.switchState = 1 }
                }
            }
        }
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager) {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.distanceFilter = 30
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status{
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            print("位置情報の取得許可が未設定のため、このアプリを最大限に利用できません。「常に許可」を選択してください。")
        case .restricted, .denied:
            print("位置情報の取得許可が「許可しない」になっているため、このアプリを最大限に利用できません。設定から「常に許可」を選択してください。")
        case .authorizedWhenInUse:
            locationManager(manager: manager)
            print("位置情報の取得許可が「一時的に許可」になっています。そのためこのアプリがバックグラウンドに行った場合、正常に通知がされない場合があります。このアプリを常に正しく利用したい場合は、「設定」から「常に許可」を選択してください。")
            break
        case .authorizedAlways:
            locationManager(manager: manager)
            break
            
        default:
            break
        }
    }

}


