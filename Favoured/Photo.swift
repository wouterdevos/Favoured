//
//  Image.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/04.
//  Copyright © 2016 Wouter. All rights reserved.
//

import CoreData
import UIKit

class Photo: NSManagedObject {
    
    @NSManaged var id: String
    @NSManaged var uploaded: Bool
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override func prepareForDeletion() {
        ImageCache.sharedInstance().deleteImage(id)
    }
    
    init(id: String, uploaded: Bool, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = id
        self.uploaded = uploaded
    }
    
    var image: UIImage? {
        get {
            return ImageCache.sharedInstance().imageWithIdentifier(id)
        }
        
        set {
            ImageCache.sharedInstance().storeImage(newValue, withIdentifier: id)
        }
    }
    
    var path: String? {
        get {
            return ImageCache.sharedInstance().pathForIdentifier(id)
        }
    }
    
    class func getPhoto(id: String, image: UIImage?, uploaded: Bool, context: NSManagedObjectContext) -> Photo {
        let photo = Photo(id: id, uploaded: uploaded, context: context)
        photo.image = image
        return photo
    }
    
    class func getPhoto(id: String, imageName: String, index: Int, image: UIImage?, context: NSManagedObjectContext) -> Photo {
        let id = id + String(format: imageName, index)
        return getPhoto(id, image: image, uploaded: false, context: context)
    }
}
