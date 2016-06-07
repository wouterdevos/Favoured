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
    
    static let EntityName = "Photo"
    
    @NSManaged var id: String
    @NSManaged var pollId: String?
    @NSManaged var uploaded: Bool
    @NSManaged var isThumbnail: Bool
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override func prepareForDeletion() {
        ImageCache.sharedInstance().deleteImage(id)
    }
    
    init(id: String, pollId: String?, uploaded: Bool, isThumbnail: Bool, image: UIImage?, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = id
        self.pollId = pollId
        self.uploaded = uploaded
        self.isThumbnail = isThumbnail
        self.image = image
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
}
