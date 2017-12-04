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
    var identifyText = String()
    var wikiResults = [WikipediaResult]()
    let findWiki = WikipediaAPIManager()
    
    override func viewWillAppear(_ animated: Bool) {
        ReceivedText.text = identifyText.capitalized
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        findWiki.delegate = self
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        //findWiki.fetchWiki(identifyText: identifyText)
    }

    //share button activity
    @IBAction func shareButtonPressed(_ sender: Any) {
        let textToShare = "Check what I found in my photo using Waht's That: \(identifyText.uppercased())!"
        let shareViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        present(shareViewController, animated: true, completion: nil)
    }
    
    //Wiki Safari page
    @IBAction func WikiButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "https://en.wikipedia.org/wiki/\(identifyText.capitalized)") {
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

//WikiResult protocol
extension PhotoDetailsViewController: WikiDelegate {
        
    func wikiFound(wiki:[WikipediaResult]) {
        self.wikiResults = wiki
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for:self.view, animated: true)
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
