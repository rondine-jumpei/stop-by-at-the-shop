//
//  NoticeViewController.swift
//  Stop by at the shop
//
//  Created by ろーんでぃね on 2020/08/08.
//  Copyright © 2020 ろーんでぃね. All rights reserved.
//


import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import UserNotifications
import NotificationCenter
import MapKit
import CoreLocation

class NoticeConfigViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    

    @IBOutlet weak var shoppingListTableView: UITableView!
    @IBOutlet weak var shoppingListAddButton: UIButton!
    //    MARK:買い物リスト作成
    @IBAction func shoppingListAddButton(_ sender: Any) {
        let alertController = UIAlertController(title: "買い物リストを追加しますか？", message: nil, preferredStyle: .alert)
        let action:UIAlertAction = UIAlertAction(title: "追加", style: .default) { (void) in
            let textField = alertController.textFields![0] as UITextField
            if let text = textField.text {
                let shoppingLists = shoppingListRealm()
                shoppingLists.shoppingText = text
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(shoppingLists)
                }
                self.shoppingListTableView.reloadData()
            }
        }
        let cancel:UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "買うものを入力してください"
        }
        alertController.addAction(action)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    //    MARK:キーボードに決定ボタン追加
    @IBOutlet weak var inputRadiusTextField: UITextField! {
        didSet{
            self.addDoneCancelToolbar()
        }
    }
    
    @IBOutlet weak var arrivalSwitch: UISwitch!
    @IBOutlet weak var intoRadiusSwitch: UISwitch!
  
    
    //    　各スイッチを押したら該当スイッチ以外は切る
    @IBAction func arrivalSwitch(_ sender: Any) {
        intoRadiusSwitch.setOn(false, animated: true)
        didSwitched(spot: "arrival")
    }
    
    @IBAction func intoRadiusSwitch(_ sender: Any) {
        arrivalSwitch.setOn(false, animated: true)
        didSwitched(spot: "intoRadius")
    }
    
    
    private let shoppingCellId = "shoppingListCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInfo()
    }
    
// MARK:通知の半径設定
//    キーボード内のreturnから
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        configRadius(textField: textField)
        return true
    }
//    付け足した決定ボタンから
    @objc func doneButtonTapped() {
        configRadius(textField: inputRadiusTextField)
    }
    @objc func cancelButtonTapped() { inputRadiusTextField.resignFirstResponder() }
//    半径設定　configRadius
    func configRadius(textField: UITextField) {
        textField.resignFirstResponder()
        if textField.text?.hasPrefix("0") == true {
            textField.text?.removeAll()
            textField.reloadInputViews()
        }
        let realm = try! Realm()
        let radiuses = realm.objects(radiusRealm.self)
//        realmがまだないなら新規作成
        if radiuses.count == 0 {
            if let text = textField.text {
                if let numberText: Int = Int(text) {
                    let radius = radiusRealm()
                    radius.radius = numberText
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(radius)
                    }
                    inputRadiusTextField.placeholder = String(radius.radius)
                }
            }
        } else {
//            realmがあるなら上書き
            if let text = textField.text {
                if let numberText: Int = Int(text) {
                    try! realm.write{
                        radiuses[0].radius = numberText
                    }
                    inputRadiusTextField.placeholder = String(radiuses[0].radius)
                }
            }
        }
    }
    
//　 MARK:買い物リストのセル内容
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let shoppingLists = realm.objects(shoppingListRealm.self)
        return shoppingLists.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = shoppingListTableView.dequeueReusableCell(withIdentifier: shoppingCellId, for:  indexPath) as! ShoppingListTableViewCell
        
        let realm = try! Realm()
        let shoppingLists = realm.objects(shoppingListRealm.self)
        let shoppingList = shoppingLists[indexPath.row]
        cell.shoppingListLabel.text = shoppingList.shoppingText
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let realm = try! Realm()
            let shoppingLists = realm.objects(shoppingListRealm.self)
            let shoppingList = shoppingLists[indexPath.row]
            try! realm.write {
                realm.delete(shoppingList)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
//   MARK:setUpInfo
    func setUpInfo() {
        self.overrideUserInterfaceStyle = .light
        shoppingListTableView.delegate = self
        shoppingListTableView.dataSource = self
        shoppingListTableView.register(UINib(nibName: "ShoppingListTableViewCell", bundle: nil), forCellReuseIdentifier: shoppingCellId)
        shoppingListTableView.rowHeight = 30
        shoppingListAddButton.layer.borderWidth = 1
        shoppingListAddButton.layer.cornerRadius = 10
        let realm = try! Realm()
        let radius = realm.objects(radiusRealm.self)
        if radius.count == 0 {
            inputRadiusTextField.placeholder = String(300)
        } else {
            let rad = radius[0].radius
            inputRadiusTextField.placeholder = String(rad)
        }

        let timing = realm.objects(noticeTimingRealm.self)
        if timing.count == 0 || timing[0].spot == "intoRadius"{
            intoRadiusSwitch.setOn(true, animated: false)
        } else if timing[0].spot == "arrival" {
            arrivalSwitch.setOn(true, animated: false)
        }
        
        inputRadiusTextField.delegate = self
    }
    //    MARK:通知タイミングのスイッチ切り替え
    func didSwitched(spot: String){
        let realm = try! Realm()
        let noticeTimings = realm.objects(noticeTimingRealm.self)
        //        realmがまだないなら新規作成
        if noticeTimings.count == 0 {
            let noticeTiming = noticeTimingRealm()
            noticeTiming.spot = spot
            let realm = try! Realm()
            try! realm.write {
                realm.add(noticeTiming)
            }
            
            } else {
            //            realmがあるなら上書き
            try! realm.write{
                noticeTimings[0].spot = spot
            }
        }
    }
//    MARK:キーボードに決定とキャンセル追加
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "キャンセル", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "決定", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        inputRadiusTextField.inputAccessoryView = toolbar
    }

}
