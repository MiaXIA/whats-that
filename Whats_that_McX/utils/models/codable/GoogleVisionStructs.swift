//
//  GoogleVisionStructs.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/29.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation

struct Root: Codable {
    let labelAnnotations: [LabelAnnotations]
}

struct LabelAnnotations: Codable {
    let description: String
}
