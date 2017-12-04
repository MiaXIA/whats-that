//
//  TwitSearchTimelineViewController.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/17.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import UIKit
import TwitterKit

class TwitSearchTimelineViewController: TWTRTimelineViewController {
    
    var searchText = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let client = TWTRAPIClient()
        //self.dataSource = TWTRListTimelineDataSource(listSlug: searchText, listOwnerScreenName: "stevenhepting", apiClient: client)
        //self.dataSource = TWTRUserTimelineDataSource(screenName: searchText, apiClient: client)
        
        self.dataSource = TWTRSearchTimelineDataSource(searchQuery: searchText, apiClient: client)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

