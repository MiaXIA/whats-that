//
//  TwitSearchTimelineViewController.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/17.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import UIKit
import TwitterKit

//call for TwitterKit pod to show the time line with the identified text search
class TwitSearchTimelineViewController: TWTRTimelineViewController {
    
    var searchText = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the twitter API client
        let client = TWTRAPIClient()
        
        //self.dataSource = TWTRListTimelineDataSource(listSlug: searchText, listOwnerScreenName: "stevenhepting", apiClient: client)
        //self.dataSource = TWTRUserTimelineDataSource(screenName: searchText, apiClient: client)
        
        //call for search time line data with identified text
        self.dataSource = TWTRSearchTimelineDataSource(searchQuery: searchText, apiClient: client)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

