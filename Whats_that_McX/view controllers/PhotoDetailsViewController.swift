//
//  PhotoDetailsViewController.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/17.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import UIKit
import MBProgressHUD
import SafariServices

class PhotoDetailsViewController: UIViewController {
    
    //declare variables
    @IBOutlet weak var ReceivedText: UILabel!
    @IBOutlet weak var ExtractText: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    var selected = Bool()
    var identifyPhoto = UIImage()
    var identifyText = String()
    var wikiResult = WikipediaResult(title: "", extract: "")
    let findWiki = WikipediaAPIManager()
    let dataManager = PersistanceManager()
    let locationFinder = LocationFinder()
    var latitude = Double()
    var longitude = Double()
    var textIndex = Int()
    var imageurltodelete = String()
    
    override func viewWillAppear(_ animated: Bool) {
        ReceivedText.text = identifyText.capitalized
        //check if the segue is from PhotoIdentificationView or FavoriteListTableView
        //to determine if the "favorite" image should be red or blank heart
        if selected {
            self.favoriteButton.setImage(UIImage(named: "red_heart"), for: .normal)
        } else {
            self.favoriteButton.setImage(UIImage(named: "blank_heart"), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //declare the protocols
        findWiki.delegate = self
        locationFinder.delegate = self
        
        //show the networking processing and fetch the result from data, find the location
        MBProgressHUD.showAdded(to: self.view, animated: true)
        findWiki.fetchWiki(identifyText: identifyText)
        locationFinder.findLocation()
    }
    
    //favorite button function
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        //check the user's action: to save or to delete
        if selected {
            //will delete the data
            //add alert window to make sure user want to delete the data
            let alert = UIAlertController (title: "Do you want to delete it from your list?", message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //delete from favorite list
                //change the favorite button image
                self.favoriteButton.setImage(UIImage(named: "blank_heart"), for: .normal)
                //change the favorite button status
                self.selected = false
                //call the function to remove data
                self.dataManager.removeFavorite(self.textIndex)
                //delete the image from core data in order to save the memory space
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: self.imageurltodelete) {
                    try! fileManager.removeItem(atPath: self.imageurltodelete)
                } else {
                    //If the app is rebuilt, the FavoriteListTable will lost the image storage
                    //then it will come to this status
                    //But in normal using it will never enter this status
                    //because when delete the app the persistance data will also be deleted
                    print("No image to delete!")
                }
                
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            //will save the data
            let alert = UIAlertController (title: "Do you want to add it to your list", message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //change the favorite button image and status
                self.favoriteButton.setImage(UIImage(named: "red_heart"), for: .normal)
                self.selected = true
                //Save name
                let title = self.identifyText
                //Save imageData
                let image = self.identifyPhoto
                //represente the image data to 30% of the quality
                //in order to reduce the memory space
                //because the FavoriteListTableView only shows the thumbnails
                let imageData: NSData = UIImageJPEGRepresentation(image, 0.3)! as NSData
                let imageuuid = NSUUID().uuidString
                let fileManager = FileManager.default
                //set the imageurl
                let imagepath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageuuid)
                fileManager.createFile(atPath: imagepath, contents: imageData as Data, attributes: nil)
                //Save date
                let date = Date()
                let favorite = Favorite(name: title, imageurl: imagepath, latitude: self.latitude, longitude: self.longitude, startDate: date)
                self.dataManager.saveFavorite(favorite)

            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //share button activity
    @IBAction func shareButtonPressed(_ sender: Any) {
        let textToShare = "Check what I found in my photo using What's That: \(identifyText.uppercased())!"
        let shareViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        present(shareViewController, animated: true, completion: nil)
    }
    
    //Wiki Safari page function
    @IBAction func WikiButtonPressed(_ sender: UIButton) {
        //replace the space in identified text to _
        //in order to the query text to call the wiki safari do not allow the space
        let queryText = identifyText.replacingOccurrences(of: " ", with: "_")
        //call the request url
        if let url = URL(string: "https://en.wikipedia.org/wiki/\(queryText)") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
    
    //parse the identified text to the twitter time line view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let twitView: TwitSearchTimelineViewController = segue.destination as! TwitSearchTimelineViewController
        twitView.searchText = identifyText
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//LocationFinderDelegate protocol
extension PhotoDetailsViewController: LocationFinderDelegate {
    func locationFound(latitude: Double, longitude: Double) {
        //if succeed, simply store the location information if it will be needed
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func locationNotFound(reason: LocationFinder.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
           
            let alertController = UIAlertController(title: "Problem finding location", message: reason.rawValue, preferredStyle: .alert)
            //set the alertwindow for different reasongs
            switch reason {
            case .timeout:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.locationFinder.findLocation()
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
            case .noPermission:
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let setting = UIAlertAction(title: "Setting", style: .default, handler: { (action) -> Void in
                    let url = URL(string: UIApplicationOpenSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        })
                    }
                })
                alertController.addAction(cancel)
                alertController.addAction(setting)
            case .error:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
            }
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
}

//WikiResult protocol
extension PhotoDetailsViewController: WikiDelegate {
    func wikiFound(wiki:WikipediaResult) {
        self.wikiResult = wiki
        DispatchQueue.main.async {
            MBProgressHUD.hide(for:self.view, animated: true)
            self.ExtractText.isEditable = false
            if self.wikiResult.extract.isEmpty {
                self.ExtractText.text = "Cannot find more information about \(self.wikiResult.title) in Wiki, please search more on Twitter :)"
            } else {
                self.ExtractText.text = self.wikiResult.extract
            }
        }
    }
    func wikiNotFound(reason: WikipediaAPIManager.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for:self.view, animated: true)
            let alertController = UIAlertController (title: "Problem fetching wiki information", message: reason.rawValue, preferredStyle: .alert)
            switch reason {
            case .networkRequestFailed:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.findWiki.fetchWiki(identifyText: self.identifyText)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
            case .badJSONResponse, .noData:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
            }
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
