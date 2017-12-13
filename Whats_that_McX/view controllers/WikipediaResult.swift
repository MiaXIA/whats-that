//
//  WikipediaResult.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/17.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation

/**
    App will need the wiki response's title and extract to give the user more information about identified label
 */
struct WikipediaResult {
    let title: String
    let extract: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case extract
    }
}
