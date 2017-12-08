//
//  FavoriteListTableViewController.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/12/6.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import UIKit

class FavoriteListTableViewController: UITableViewController {
    
    var favorites: [Favorite]!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favorites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteIdentifierCell", for: indexPath) as! FavoriteListTableViewCell
        
        // Configure the cell...
        let favorite = favorites[indexPath.row]
        cell.titleLabel?.text = "\(favorite.name)"
        
        return cell
    }
}
