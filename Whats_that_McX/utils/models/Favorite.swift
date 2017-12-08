//
//  PersistantList.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/30.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation

class Favorite: NSObject {
    let name: String
    let imageData: NSData
    let latitude: Double
    let longitude: Double
    
    let nameKey = "name"
    let imagedataKey = "imagedata"
    let latitudeKey = "latitude"
    let longitudeKey = "longitude"
    
    init(name: String, imageData: NSData, latitude: Double, longitude: Double) {
        self.name = name
        self.imageData = imageData
        self.latitude = latitude
        self.longitude = longitude
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: nameKey) as! String
        imageData = aDecoder.decodeObject(forKey: imagedataKey) as! NSData
        latitude = aDecoder.decodeObject(forKey: latitudeKey) as! Double
        longitude = aDecoder.decodeObject(forKey: latitudeKey) as! Double
    }
}

extension Favorite: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: nameKey)
        aCoder.encode(imageData, forKey: imagedataKey)
        aCoder.encode(latitude, forKey: latitudeKey)
        aCoder.encode(longitude, forKey: longitudeKey)
    }
}
