//
//  MapPointTableViewCell.swift
//  Stop by at the shop
//
//  Created by ろーんでぃね on 2020/08/08.
//  Copyright © 2020 ろーんでぃね. All rights reserved.
//



import UIKit
import RealmSwift

class MapPointTableViewCell: UITableViewCell {
    
  
    
    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pointNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
    }
    
}

