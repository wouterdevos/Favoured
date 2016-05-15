//
//  AddPollViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/15.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class AddPollViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let AddPhoto = "Add Photo"
    
    let activityIndicatorUtils = ActivityIndicatorUtils.sharedInstance()
    let defaultCenter = NSNotificationCenter.defaultCenter()
    var pollPictures = [UIImage?]()
    var alertController: UIAlertController?

    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func addPoll(sender: AnyObject) {
//        DataModel.addPoll()
    }
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pollPictures.append(nil)
        
        // Configure the collection view.
//        let screenSize = UIScreen.mainScreen().bounds
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        print("Collection view width \(collectionView.frame.size.width / 2)")
//        layout.itemSize = CGSize(width: collectionView.frame.size.width / 2, height: collectionView.frame.size.width / 2)
        
//        collectionView.frame.size.height = collectionView.frame.size.width
        collectionView.dataSource = self
        collectionView.delegate = self
//        collectionView.setCollectionViewLayout(layout, animated: true)

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate methods.
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            if pollPictures.count < ImageConstants.PollPictureTotal {
                pollPictures.insert(pickedImage, atIndex: pollPictures.count - 1)
            } else {
                pollPictures[ImageConstants.PollPictureTotal - 1] = pickedImage
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDatasource and UICollectionViewDelegateFlowlayout methods.
    
    //    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    //        return pollOptions.count
    //    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pollPictures.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddPollCollectionViewCell", forIndexPath: indexPath) as! AddPollCollectionViewCell
        
        let pollPicture = pollPictures[indexPath.row]
        let isPollPicture = pollPicture != nil
        cell.imageView.backgroundColor = isPollPicture ? UIColor.whiteColor() : UIColor.grayColor()
//        let profilePicture = UIImage(named: "ProfilePicture")
        cell.imageView.image = pollPicture
        cell.label.hidden = isPollPicture
        cell.label.text = AddPhoto
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let pollPicture = pollPictures[indexPath.row] else {
            createImagePickerAlertController()
            return
        }
        
        // View full screen picture
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.frame.size.width
//        let spacing = width * 0.06
        let cellWidth = (width - 10) / 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Initialisation methods.
    
    func addObservers() {
//        defaultCenter.addObserver(self, selector: "authUserCompleted:", name: NotificationNames.AuthUserCompleted, object: nil)
//        defaultCenter.addObserver(self, selector: "resetPasswordForUserCompleted:", name: NotificationNames.ResetPasswordForUserCompleted, object: nil)
    }
    
    func removeObservers() {
//        defaultCenter.removeObserver(self, name: NotificationNames.AuthUserCompleted, object: nil)
//        defaultCenter.removeObserver(self, name: NotificationNames.ResetPasswordForUserCompleted, object: nil)
    }
    
    // MARK: - REST calls and response methods.
    
    func addPoll() {
        
    }
    
    // MARK: - Handler methods for alert controller.
    
    func cameraHandler(alertAction: UIAlertAction) {
        let imagePickerController = Utils.getImagePickerController(.Camera, delegate: self)
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func photoLibraryHandler(alertAction: UIAlertAction) {
        let imagePickerController = Utils.getImagePickerController(.PhotoLibrary, delegate: self)
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Convenience methods.
    
    func createImagePickerAlertController() {
        let isCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        if isCamera {
            alertController = Utils.createImagePickerAlertController(Title.AddProfilePicture, cameraHandler: cameraHandler, photoLibraryHandler: photoLibraryHandler)
            presentViewController(alertController!, animated: true, completion: nil)
        } else {
            let imagePickerController = Utils.getImagePickerController(.PhotoLibrary, delegate: self)
            presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
}
