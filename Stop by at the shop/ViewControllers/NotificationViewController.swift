//
//  NotificationViewController.swift
//  Stop by at the shop
//
//  Created by ろーんでぃね on 2020/08/23.
//  Copyright © 2020 ろーんでぃね. All rights reserved.
//



import UIKit
import RealmSwift


class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var shoppingListTableView: UITableView!
    @IBOutlet weak var notificationResetButton: UIButton!
    
//    買い物リストと通知スイッチをリセットして元のVIewに戻る
    @IBAction func notificationResetButton(_ sender: Any) {
        let realm = try! Realm()
        let shoppingLists = realm.objects(shoppingListRealm.self)
        try! realm.write {
            realm.delete(shoppingLists)
        }
//        通知タイミングリセット
        let noticeTiming = realm.objects(noticeTimingRealm.self)
        try! realm.write {
            realm.delete(noticeTiming)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private let shoppingCellId = "shoppingListCellId"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shoppingListTableView.delegate = self
        shoppingListTableView.dataSource = self
        shoppingListTableView.register(UINib(nibName: "ShoppingListTableViewCell", bundle: nil), forCellReuseIdentifier: shoppingCellId)
        notificationResetButton.layer.borderWidth = 1
        notificationResetButton.layer.borderColor = UIColor.link.cgColor
        notificationResetButton.layer.cornerRadius = 10
        }
    
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
    
}
