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
    
    @IBOutlet weak var ReceivedText: UILabel!
    @IBOutlet weak var ExtractText: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var selected = false
    var identifyPhoto = UIImage()
    var identifyText = String()
    var wikiResult = WikipediaResult(title: "", extract: "")
    let findWiki = WikipediaAPIManager()
    let dataManager = PersistanceManager()
    let locationFinder = LocationFinder()
    
    override func viewWillAppear(_ animated: Bool) {
        ReceivedText.text = identifyText.capitalized
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        findWiki.delegate = self
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        findWiki.fetchWiki(identifyText: identifyText)
    }

    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        if selected {
            let alert = UIAlertController (title: "Do you want to delete it from your list?", message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //delete from favorite list
                self.favoriteButton.setImage(UIImage(named: "blank_heart"), for: .normal)
                self.selected = false
                //TODO
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController (title: "Do you want to add it to your list", message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //find location
                MBProgressHUD.showAdded(to: self.view, animated: true)
                self.locationFinder.findLocation()
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
    
    //Wiki Safari page
    @IBAction func WikiButtonPressed(_ sender: UIButton) {
        let queryText = identifyText.replacingOccurrences(of: " ", with: "_")
        if let url = URL(string: "https://en.wikipedia.org/wiki/\(queryText)") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
    
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let twitView: TwitSearchTimelineViewController = segue.destination as! TwitSearchTimelineViewController
        
        twitView.searchText = identifyText
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//LocationFinderDelegate protocol
extension PhotoDetailsViewController: LocationFinderDelegate {
    func locationFound(latitude: Double, longitude: Double) {
        print(longitude)
        print(latitude)
        //save to favorite list
        self.favoriteButton.setImage(UIImage(named: "red_heart"), for: .normal)
        self.selected = true
        //Save name
        let title = self.identifyText
        //Save imageData
        let image = self.identifyPhoto
        let imageData: NSData = UIImageJPEGRepresentation(image, 0.3)! as NSData
        //let imageuuid = NSUUID().uuidString
        
        let favorite = Favorite(name: title, imageData: imageData, latitude: latitude, longitude: longitude)
        self.dataManager.saveFavorite(favorite)
        print(favorite)
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func locationNotFound(reason: LocationFinder.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
           
            let alertController = UIAlertController(title: "Problem finding location", message: reason.rawValue, preferredStyle: .alert)
            
            switch reason {
            case .timeout:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.locationFinder.findLocation()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
                
            case .noPermission, .error:
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
