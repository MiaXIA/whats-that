//
//  WikipediaAPIManager.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/27.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation

//WikipediaAPIManager protocol
protocol WikiDelegate {
    func wikiFound(wiki:WikipediaResult)
    func wikiNotFound(reason: WikipediaAPIManager.FailureReason)
}

class WikipediaAPIManager {
    
    //failurereason in protocol
    enum FailureReason: String {
        case networkRequestFailed = "Your request failed, please try again."
        case noData = "No wiki data received."
        case badJSONResponse = "Bad JSON response."
    }
    
    var delegate: WikiDelegate?
    
    /**
        Use this function to fetch the wiki result from wiki
     
        @param the specify identify text string that user selected
     
        @return WikipediaResult arrays
     */
    func fetchWiki(identifyText: String) {
        //request URL
        var urlComponents = URLComponents(string: "https://en.wikipedia.org/w/api.php")!
        //replace the space in identify text with _
        //in order to get the correct result that user wants
        let queryText = identifyText.replacingOccurrences(of: " ", with: "_")
        
        //wiki api requet attributes and keywords
        //format=json&action=query&prop=extracts&exintro=&explaintext=&titles=tree
        urlComponents.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "prop", value: "extracts"),
            URLQueryItem(name: "exintro", value: ""),
            URLQueryItem(name: "explaintext", value: ""),
            URLQueryItem(name: "titles", value: queryText)
        ]
        
        //create request url
        let url = urlComponents.url!
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        
        //get the response from wiki api
        let task = URLSession.shared.dataTask(with: request) { (data,response,error) in
            //check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.wikiNotFound(reason: .networkRequestFailed)
                return
            }
            
            //check if new data exist
            guard let data = data, let wikiJsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [String: Any]() else {
                self.delegate?.wikiNotFound(reason: .noData)
                return
            }
            
            //standard parsing the JSON data to arrays
            guard let queryJsonObject = wikiJsonObject["query"] as? [String: Any], let pageJsonObject = queryJsonObject["pages"] as? [String: Any] else {
                self.delegate?.wikiNotFound(reason: .badJSONResponse)
                return
            }
            
            let resultJsonObject = pageJsonObject[pageJsonObject.keys.first!] as? [String: Any]
            let title = resultJsonObject!["title"] as? String ?? ""
            let extract = resultJsonObject!["extract"] as? String ?? ""
            
            let wikiResult = WikipediaResult(title: title, extract: extract)
            
            self.delegate?.wikiFound(wiki: wikiResult)
        }
        task.resume()
    }
}

private func resultsFromJsonData(data: Data) -> [WikipediaResult] {
    let decoder = JSONDecoder()
    let WikiResults = try? decoder.decode([WikipediaResult].self, from: data)
    
    return WikiResults ?? [WikipediaResult]()
}
