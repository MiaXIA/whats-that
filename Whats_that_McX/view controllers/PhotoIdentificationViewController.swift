//
//  PhotoIdentificationViewController.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/17.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import UIKit
import MBProgressHUD
import Photos
import AVFoundation

class PhotoIdentificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //declare variables
    @IBOutlet weak var identifyList: UITableView!
    var results = [GoogleVisionResult]()
    let picker = UIImagePickerController()
    let googleVisionAPIManager = GoogleVisionAPIManager()
    @IBOutlet weak var identifyPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //declare protocols
        googleVisionAPIManager.delegate = self
        picker.delegate = self
        self.identifyList.delegate = self
        self.identifyList.dataSource = self
    }
    
    //return the numbers of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    //build the cell's information
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = identifyList.dequeueReusableCell(withIdentifier: "googleIdentifyCell", for: indexPath)

        let result = results[indexPath.row]
        cell.textLabel?.text = "\(result.name)"
        return cell
    }

    //Liberary button function
    @IBAction func liberary(_ sender: UIButton) {
        //check the library authorizationStatus
        let library: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        //request the authorization or show the photo library
        if(library == PHAuthorizationStatus.denied || library == PHAuthorizationStatus.restricted) {
            DispatchQueue.main.async(execute: { () -> Void in
                //build the alert window
                let alert = UIAlertController(title: "No authorization to use the photo", message: "Press the Setting to set the authorization", preferredStyle: .alert)
                
                //cancel action
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                //jump to system setting to change the authorization
                let setting = UIAlertAction(title: "Setting", style: .default, handler: { (action) -> Void in
                    //open system setting
                    let url = URL(string: UIApplicationOpenSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        })
                    }
                })
                
                //add actions to alert window
                alert.addAction(cancel)
                alert.addAction(setting)
                //show the alert window
                self.present(alert, animated: true, completion: nil)
            })
        } else {
            //set allow editing
            picker.allowsEditing = false
            //set the type
            picker.sourceType = .photoLibrary
            //show the view
            present(picker, animated: true, completion: nil)
        }
    }
    
    //camera button function
    @IBAction func Camera(_ sender: UIButton) {
        //check the camera authorization status
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        //request the authorization or show the camera
        if (authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted) {
            DispatchQueue.main.async(execute: { () -> Void in
                let alert = UIAlertController(title: "No authorization to use the camera", message: "Press the Setting to set the authorization", preferredStyle: .alert)
            
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let setting = UIAlertAction(title: "Setting", style: .default, handler: { (action) -> Void in
                    let url = URL(string: UIApplicationOpenSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        })
                    }
                })
            
                alert.addAction(cancel)
                alert.addAction(setting)
            
                self.present(alert, animated: true, completion: nil)
            })
        } else {
            picker.allowsEditing = false
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        }
    }
    
    //parse the selected cell text, the image to PhotoDetails View
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //set the segue destination to PhotoDetailsView
        let photoDetailView: PhotoDetailsViewController = segue.destination as! PhotoDetailsViewController
        let textIndex = identifyList.indexPathForSelectedRow?.row
        let image = self.identifyPhoto.image
        //parse the information
        photoDetailView.identifyText = results[textIndex!].name
        photoDetailView.identifyPhoto = image!
        //the segue from PhotoIdentificationView to PhotoDetailsView will never be saved before
        //it is different from the segue between FavoriteListTableView and PhotoDetailsView
        photoDetailView.selected = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//Image Processing
extension PhotoIdentificationViewController {
    //After choose a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            identifyPhoto.image = pickedImage
            //Show the back working processing
            MBProgressHUD.showAdded(to: self.view, animated: true)
            // Base64 encode the image and create the request
            let binaryImageData = base64EncodeImage(pickedImage)
            //Call for the google vision API
            googleVisionAPIManager.fetchGoogleVisionAPIUsingCodable(with: binaryImageData)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //resize the image if it is too big to parse into Google Vision API
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

//networking processing
extension PhotoIdentificationViewController {
    //parse the image into string image
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata!.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
}

//adhere to the LocationFinderDelegate protocol
extension PhotoIdentificationViewController: GoogleVisionResultDelegate {
    func resultsFound(GoogleVisionResults: [GoogleVisionResult]) {
        //fill the tables with result
        self.results = GoogleVisionResults
        DispatchQueue.main.async {
            MBProgressHUD.hide(for:self.view, animated: true)
            self.identifyList.reloadData()
        }
        
    }
    func resultsNotFound(reason: GoogleVisionAPIManager.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for:self.view, animated: true)
            //check the failure reason and show the alert window
            let alertController = UIAlertController (title: "Problem identifying image", message: reason.rawValue, preferredStyle: .alert)
            switch reason {
            case .networkRequestFailed:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    //show the progress HUB and retry to fetch the result from Google Vision API
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    let retryimage = self.identifyPhoto.image
                    let binaryImageData = self.base64EncodeImage(retryimage!)
                    self.googleVisionAPIManager.fetchGoogleVisionAPIUsingCodable(with: binaryImageData)
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
