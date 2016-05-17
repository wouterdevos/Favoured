//
//  AddPollViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/15.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class AddPollViewController: ImagePickerViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FullScreenImageViewControllerDelegate {

    let AddPhoto = "Add Photo"
    let FullScreenImageSegue = "FullScreenImageSegue"
    
    var selectedPictureIndex = 0
    var pollPictures = [UIImage?]()

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
        
        collectionView.dataSource = self
        collectionView.delegate = self

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == FullScreenImageSegue {
            let viewController = segue.destinationViewController as! FullScreenImageViewController
            let pollPicture = sender as! UIImage
            viewController.image = pollPicture
            viewController.delegate = self
        }
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pollPictures.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddPollCollectionViewCell", forIndexPath: indexPath) as! AddPollCollectionViewCell
        
        let pollPicture = pollPictures[indexPath.row]
        let isPollPicture = pollPicture != nil
        cell.imageView.backgroundColor = isPollPicture ? UIColor.whiteColor() : UIColor.grayColor()
        cell.imageView.image = pollPicture
        cell.label.hidden = isPollPicture
        cell.label.text = AddPhoto
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedPictureIndex = indexPath.row
        guard let pollPicture = pollPictures[selectedPictureIndex] else {
            createImagePickerAlertController()
            return
        }
        
        // Instantiate full screen image view controller
        performSegueWithIdentifier(FullScreenImageSegue, sender: pollPicture)
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
    
    // MARK: - FullScreenImageViewControllerDelegate method.
    
    func imageChanged(image: UIImage?) {
        if image == nil {
            let hasReachedTotal = pollPictures.count == ImageConstants.PollPictureTotal && pollPictures[ImageConstants.PollPictureTotal - 1] != nil
            pollPictures.removeAtIndex(selectedPictureIndex)
            if hasReachedTotal {
                pollPictures.append(nil)
            }
        } else {
            pollPictures[selectedPictureIndex] = image
        }
        collectionView.reloadData()
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
}
