//
//  UIImage-Extention.swift
//  Stop by at the shop
//
//  Created by ろーんでぃね on 2020/08/09.
//  Copyright © 2020 ろーんでぃね. All rights reserved.
//

import UIKit
import MapKit
//   MARK: 画像のリサイズ
extension UIImage {
func resize(size _size: CGSize) -> UIImage? {
       let widthRatio = _size.width / size.width
       let heightRatio = _size.height / size.height
       let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
       
       let resizeSize = CGSize(width: size.width * ratio, height: size.height * ratio)
       
       UIGraphicsBeginImageContextWithOptions(resizeSize, false, 0.0)
       draw(in: CGRect(origin: .zero, size: resizeSize))
       let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       
       return resizedImage
   }
}

//　MARK:ピンに任意の画像をつける
class MapAnnotationSetting: MKPointAnnotation{
    var pinImage: UIImage?
    var pinNum: Int = 0
}
