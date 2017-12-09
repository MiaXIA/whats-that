//
//  FavoriteListTableViewController.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/12/6.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import UIKit

class FavoriteListTableViewController: UITableViewController {
    
    var favorites = [Favorite]()
    let persistanceManager = PersistanceManager()
    
    override func viewWillAppear(_ animated: Bool) {
        favorites = persistanceManager.fetchFavorites()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
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
        cell.locationLabel?.text = favorite.startDate.description
        cell.locationLabel?.textColor = .gray
        
        //get the image
        let imageurl = favorite.imageurl
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: imageurl) {
            cell.identifyImage?.image = UIImage(contentsOfFile: imageurl)
        } else {
            //show nothing
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoDetailView: PhotoDetailsViewController = segue.destination as! PhotoDetailsViewController
        
        let textIndex = tableView.indexPathForSelectedRow?.row
        
        photoDetailView.identifyText = favorites[textIndex!].name
        let imageurl = favorites[textIndex!].imageurl
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: imageurl) {
            photoDetailView.identifyPhoto = UIImage(contentsOfFile: imageurl)!
        } else {
            //do nothing
        }
        photoDetailView.selected = true
        photoDetailView.textIndex = textIndex!
    }
}
