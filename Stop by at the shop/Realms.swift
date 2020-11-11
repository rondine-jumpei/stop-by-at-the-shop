//
//  Realms.swift
//  Stop by at the shop
//
//  Created by ろーんでぃね on 2020/08/08.
//  Copyright © 2020 ろーんでぃね. All rights reserved.
//

import Foundation
import RealmSwift


class mapPointRealm: Object {
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var switchState: Int = 0
}

class shoppingListRealm: Object {
    @objc dynamic var shoppingText = ""
}

class noticeTimingRealm: Object {
    @objc dynamic var spot: String = ""
   
}

class radiusRealm: Object {
    @objc dynamic var radius: Int = 0
}

class onboardRealm: Object {
    @objc dynamic var onboard: Int = 0
}

