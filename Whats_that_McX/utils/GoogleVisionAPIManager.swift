//
//  GoogleVisionAPIManager.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/27.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation

//Google Vision Result Protocol
protocol GoogleVisionResultDelegate {
    func resultsFound(GoogleVisionResults: [GoogleVisionResult])
    func resultsNotFound(reason: GoogleVisionAPIManager.FailureReason)
}

class GoogleVisionAPIManager {
    //API key and request URL
    var googleAPIKey = "AIzaSyDEiEmpi-P2lXHKSRKQd8ff3u26SSiGVj8"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    //Failure reason in protocol
    enum FailureReason: String {
        case networkRequestFailed = "Your request failed, please try again."
        case noData = "No identify data received."
        case badJSONResponse = "Bad JSON response."
    }
    
    var delegate: GoogleVisionResultDelegate?
    
    /**
        Use image string data to fetch the google vision api result
     
        @param image string data
     
        @return GoogleVisionResult arrays
     */
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
        
        //get response from the request URL
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            //check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.resultsNotFound(reason: .networkRequestFailed)
                return
            }
            
            //check if data exist
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
            
            //declare GoogleVisionResult arrays
            var googleVisionResults = [GoogleVisionResult]()
            
            //parse datas into arrays
            let labelAnnotations = rootData.responses[0].labelAnnotations
            for labelAnnotation in labelAnnotations {
                let googleVisionResult = GoogleVisionResult(name: labelAnnotation.description)
                googleVisionResults.append(googleVisionResult)
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
