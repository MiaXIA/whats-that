//
//  GoogleVisionStructs.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/29.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation

/**
    the responses JSON example is found in Google Cloud Platform Documents - Cloud Vision API
    website: https://cloud.google.com/vision/docs/request
 
    the sturct is generated from the JSON to Code Genderator website
    website: http://danieltmbr.github.io/JsonCodeGenerator/
 */

struct Root: Codable {
    let responses: [Responses]
}

struct Responses: Codable {
    let labelAnnotations: [LabelAnnotations]
}

struct LabelAnnotations: Codable {
    let description: String
}

