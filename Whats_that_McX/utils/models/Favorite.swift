//
//  PersistantList.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/30.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation

/**
    App will save user's favorite identified things
    with its name, imageurl, latitude, longitude and date
 */
class Favorite: NSObject {
    let name: String
    let imageurl: String
    let latitude: Double?
    let longitude: Double?
    let startDate: Date
    
    let nameKey = "name"
    let imageurlKey = "imageurl"
    let latitudeKey = "latitude"
    let longitudeKey = "longitude"
    let startDateKey = "startDate"
    
    init(name: String, imageurl: String, latitude: Double?, longitude: Double?, startDate: Date) {
        self.name = name
        self.imageurl = imageurl
        self.latitude = latitude
        self.longitude = longitude
        self.startDate = startDate
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: nameKey) as! String
        imageurl = aDecoder.decodeObject(forKey: imageurlKey) as! String
        latitude = aDecoder.decodeObject(forKey: latitudeKey) as? Double
        longitude = aDecoder.decodeObject(forKey: latitudeKey) as? Double
        startDate = aDecoder.decodeObject(forKey: startDateKey) as! Date
    }
}

extension Favorite: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: nameKey)
        aCoder.encode(imageurl, forKey: imageurlKey)
        aCoder.encode(latitude, forKey: latitudeKey)
        aCoder.encode(longitude, forKey: longitudeKey)
        aCoder.encode(startDate, forKey: startDateKey)
    }
}
