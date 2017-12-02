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
    var googleAPIKey = "AIzaSyDEiEmpi-P2lXHKSRKQd8ff3u26SSiGVj8"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    enum FailureReason: String {
        case networkRequestFailed = "Your request failed, please try again."
        case noData = "No identify data received."
        case badJSONResponse = "Bad JSON response."
    }
    
    var delegate: GoogleVisionResultDelegate?
    
    func fetchGoogleVisionAPIUsingCodable(with imageBase64: String) {
        
        //create requet URL
        var request = URLRequest(url:googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        let jsonObj = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION"
                    ]
                ]
            ]
        ]
        
        let data = try? JSONSerialization.data(withJSONObject: jsonObj)
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            //check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.resultsNotFound(reason: .networkRequestFailed)
                return
            }
            
            guard let data = data else {
                self.delegate?.resultsNotFound(reason: .noData)
                return
            }
            
            //use codable to parse JSON
            let decoder = JSONDecoder()
            guard let rootData = try? decoder.decode(Root.self, from: data) else {
                self.delegate?.resultsNotFound(reason: .badJSONResponse)
                
                return
            }
            
            var googleVisionResults = [GoogleVisionResult]()
            
            
            let labelAnnotations = rootData.responses
            for labelAnnotation in labelAnnotations {
                let googleVisionResult = GoogleVisionResult(name: labelAnnotation.labelAnnotations.description)
                googleVisionResults.append(googleVisionResult)
                print(googleVisionResult)
            }
            
            self.delegate?.resultsFound(GoogleVisionResults: googleVisionResults)
        }
        
        task.resume()
    }
    
    private func resultsFromJsonData(data: Data) -> [GoogleVisionResult] {
        let decoder = JSONDecoder()
        let GoogleVisionResults = try? decoder.decode([GoogleVisionResult].self, from: data)
        
        return GoogleVisionResults ?? [GoogleVisionResult]()
    }
}
