//
//  FullScreenImageViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/16.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

protocol FullScreenImageViewControllerDelegate {
    func imageChanged(image: UIImage?)
}

class FullScreenImageViewController: ImagePickerViewController {

    var delegate: FullScreenImageViewControllerDelegate?
    
    var image: UIImage!
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func changePhoto(sender: AnyObject) {
        createImagePickerAlertController()
    }
    
    @IBAction func deletePhoto(sender: AnyObject) {
        delegate?.imageChanged(nil)
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

    // MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate methods.
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            delegate?.imageChanged(pickedImage)
            image = pickedImage
            imageView.image = image
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
