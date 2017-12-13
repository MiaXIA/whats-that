//
//  GoogleVisionResult.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/17.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation

/**
    App will need the description of the label to show what is identified from the image
 */
struct GoogleVisionResult {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "description"
    }
}
