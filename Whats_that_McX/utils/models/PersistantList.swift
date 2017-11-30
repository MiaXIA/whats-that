//
//  PersistantList.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/30.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation

class PersistantList {
    let name: String
    let image: String
    let latitude: Double
    let longitude: Double
    
    let nameKey = "name"
    let imageKey = "image"
    let locationKey = "location"
    
    init(name: String, image: String, latitude: Double, longitude: Double) {
        self.name = name
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
    }
}
