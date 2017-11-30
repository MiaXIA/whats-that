//
//  GoogleVisionAPIManager.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/27.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation

protocol GoogleVisionResultDelegate {
    func resultsFound(GoogleVisionResults: [GoogleVisionResult])
    func resultsNotFound(reason: GoogleVisionAPIManager.FailureReason)
}

class GoogleVisionAPIManager {
    
    enum FailureReason: String {
        case networkRequestFailed = "Your request failed, please try again."
        case noData = "No identify data received."
        case badJSONResponse = "Bad JSON response."
    }
    
    var delegate: GoogleVisionResultDelegate?
    
    func fetchGoogleVisionAPIUsingCodable(with imageBase64: String) {
        var googleAPIKey = "AIzaSyDEiEmpi-P2lXHKSRKQd8ff3u26SSiGVj8"
        
        var googleURL: URL {
            return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
        }
        
    }
    

//    func identifyLabelInImage (with imageBase64: String) {
//        //TODO
//    }
    
    private func resultsFromJsonData(data: Data) -> [GoogleVisionResult] {
        let decoder = JSONDecoder()
        let GoogleVisionResults = try? decoder.decode([GoogleVisionResult].self, from: data)
        
        return GoogleVisionResults ?? [GoogleVisionResult]()
    }
}
