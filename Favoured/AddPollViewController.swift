//
//  AddPollViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/15.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class AddPollViewController: ImagePickerViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate, FullScreenImageViewControllerDelegate {

    let PollPictureMax = 4
    let PollPictureMin = 2
    let AddPhoto = "Add Photo"
    let FullScreenImageSegue = "FullScreenImageSegue"
    let DefaultQuestionText = "Question"
    
    var selectedPictureIndex = 0
    var pollPictures = [UIImage?]()

    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func addPoll(sender: AnyObject) {
        // Check if the question has been completed.
        guard let question = questionTextView.text where question.characters.count > 0 else {
            createAlertController(Title.AddPollQuestion, message: Message.AddPollQuestion)
            return
        }
        
        // Check if the minimum number of pictures have been added.
        guard pollPictures.count > PollPictureMin else {
            createAlertController(Title.AddPollPictures, message: Message.AddPollPictures)
            return
        }
        
        addNewPoll(question)
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialise the poll pictures array with a nil image.
        pollPictures.append(nil)
        
        questionTextView.delegate = self
        questionTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
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
            if pollPictures.count < PollPictureMax {
                pollPictures.insert(pickedImage, atIndex: pollPictures.count - 1)
            } else {
                pollPictures[PollPictureMax - 1] = pickedImage
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
    
    // MARK: - UITextViewDelegate methods.
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == DefaultQuestionText {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = DefaultQuestionText
        }
    }
    
    // MARK: - FullScreenImageViewControllerDelegate method.
    
    func imageChanged(image: UIImage?) {
        if image == nil {
            // Check if the maximum number of images were selected.
            let hasReachedTotal = pollPictures.count == PollPictureMax && pollPictures[PollPictureMax - 1] != nil
            
            // Remove the deleted image from the image list.
            pollPictures.removeAtIndex(selectedPictureIndex)
            if hasReachedTotal {
                // Append an empty image to the end of the list because the maximum number of images were selected.
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
    
    func addNewPoll(question: String) {
        var finalPollPictures = [UIImage]()
        for pollPicture in pollPictures {
            if let finalPollPicture = pollPicture {
                finalPollPictures.append(finalPollPicture)
            }
        }
        DataModel.addPoll(question, pollPictures: finalPollPictures)
    }
}
