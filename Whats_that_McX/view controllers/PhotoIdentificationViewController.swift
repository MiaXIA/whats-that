//
//  PhotoIdentificationViewController.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/17.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import UIKit
import MBProgressHUD

class PhotoIdentificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var identifyList: UITableView!
    var results = [GoogleVisionResult]()
    let picker = UIImagePickerController()
    let googleVisionAPIManager = GoogleVisionAPIManager()
    @IBOutlet weak var identifyPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        googleVisionAPIManager.delegate = self
        picker.delegate = self
        self.identifyList.delegate = self
        self.identifyList.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = identifyList.dequeueReusableCell(withIdentifier: "googleIdentifyCell", for: indexPath)
        
        // Configure the cell...
        let result = results[indexPath.row]
        cell.textLabel?.text = "\(result.name)"
        return cell
    }

    @IBAction func liberary(_ sender: UIButton) {
        //check the info if allow the album privacy
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //set allow editing
            picker.allowsEditing = false
            //set the type
            picker.sourceType = .photoLibrary
            //show the view
            present(picker, animated: true, completion: nil)
        }else{
            print("error when reading the album")
        }
    }
    
    @IBAction func Camera(_ sender: UIButton) {
        //check the info if allow the camera privacy
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        }else{
            print("error when using the camera")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoDetailView: PhotoDetailsViewController = segue.destination as! PhotoDetailsViewController
        
        let textIndex = identifyList.indexPathForSelectedRow?.row
        photoDetailView.identifyText = results[textIndex!].name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

//networking
extension PhotoIdentificationViewController {
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

////adhere to the LocationFinderDelegate protocol
extension PhotoIdentificationViewController: GoogleVisionResultDelegate {
    func resultsFound(GoogleVisionResults: [GoogleVisionResult]) {
        self.results = GoogleVisionResults
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for:self.view, animated: true)
            self.identifyList.reloadData()
        }
        
    }
    func resultsNotFound(reason: GoogleVisionAPIManager.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for:self.view, animated: true)
            
            let alertController = UIAlertController (title: "Problem identifying image", message: reason.rawValue, preferredStyle: .alert)
            
            switch reason {
            case .networkRequestFailed:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    //TODO
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
