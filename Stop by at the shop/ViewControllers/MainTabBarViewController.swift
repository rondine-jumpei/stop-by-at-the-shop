//
//  MainTabBarViewController.swift
//  Stop by at the shop
//
//  Created by ろーんでぃね on 2020/08/09.
//  Copyright © 2020 ろーんでぃね. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers?.enumerated().forEach({ (index, viewController) in
            switch index {
            case 0:
                viewController.tabBarItem.image = UIImage(named: "地図")?.resize(size: .init(width: 25, height: 25))
                viewController.tabBarItem.title = "マップ"
            case 1:
                viewController.tabBarItem.image = UIImage(named: "メモ")?.resize(size: .init(width: 25, height: 25))
                viewController.tabBarItem.title = "買い物メモ"
            default:
                break
            }
        })
    }
    

}
