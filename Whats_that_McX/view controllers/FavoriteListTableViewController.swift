//
//  FavoriteListTableViewController.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/12/6.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import UIKit

class FavoriteListTableViewController: UITableViewController {
    
    //declare variables
    var favorites = [Favorite]()
    let persistanceManager = PersistanceManager()
    
    //fetch the Favorite arrays before the view appear
    override func viewWillAppear(_ animated: Bool) {
        favorites = persistanceManager.fetchFavorites()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //reload the data if the view is appeared
    //but user do further actions after that (e.g. delete data)
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    //return the cells count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    //set the cell information
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteIdentifierCell", for: indexPath) as! FavoriteListTableViewCell
        
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
            //will show nothing
            //when rebuilt the app, it will lost the image storage
            //but in daily usage, it will never enter this status
        }
        return cell
    }
    
    //parse the information to PhotoDetailsView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoDetailView: PhotoDetailsViewController = segue.destination as! PhotoDetailsViewController
        
        //parse the index if user want to delete the data
        let textIndex = tableView.indexPathForSelectedRow?.row
        photoDetailView.identifyText = favorites[textIndex!].name
        //fetch the image from the memory and parse it to PhotoDetailsView
        //to be the same status when open the PhotoDetailsView from PhotoIdentificationView or FavoriteListTableView
        let imageurl = favorites[textIndex!].imageurl
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: imageurl) {
            photoDetailView.identifyPhoto = UIImage(contentsOfFile: imageurl)!
        } else {
            //will do nothing
            //when rebuilt the app, it will lost the image storage, and will enter this status
            //but in daily usage, it will never enter this status
        }
        
        //parse the information
        photoDetailView.selected = true
        photoDetailView.textIndex = textIndex!
        photoDetailView.imageurltodelete = imageurl
    }
}
