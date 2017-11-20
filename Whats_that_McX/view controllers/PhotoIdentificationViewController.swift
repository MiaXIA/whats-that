//
//  PhotoIdentificationViewController.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/17.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import UIKit

class PhotoIdentificationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var identifyPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func liberary(_ sender: Any) {
        //check the info if allow the album privacy
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //initial image picker
            let picker = UIImagePickerController()
            //set the delegate
            picker.delegate = self
            //set allow editing
            picker.allowsEditing = true
            //set the type
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //show the view
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("error when reading the album")
        }
    }
    
    //After choose a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //check the info object
        print(info)
        
        //show the image
        let image:UIImage!
        //get the original image
        image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        identifyPhoto.image = image
        //图片控制器退出
        picker.dismiss(animated: true, completion: {
            () -> Void in
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
