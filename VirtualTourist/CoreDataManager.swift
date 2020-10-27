//
//  CoreDataManager.swift
//  VirtualTourist
//
//  Created by Heiner Bruß on 28.08.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import CoreData

class CoreDataManager: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = CoreDataManager()
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    private override init() {
        
    }
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VirtualTouristModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Loading of Store failed \(error)")
            }
        }
        return container
    }()
    
    //MARK:- FetchData
    
    func fetchPins() -> [Pin] {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do{
            let pins = try context.fetch(fetchRequest)
            return pins
        } catch let error {
            print("Could not fetch data: \(error)")
            return []
        }
    }
    
    func fetchPhotos(pin: Pin) -> [Photo] {
        var photoArray: [Photo] = []
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        let sortDescriptor = NSSortDescriptor(key: "imageURL", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            let countedPhotos = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            for index in 0..<countedPhotos {
                photoArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)))
            }
            return photoArray
        } catch let error {
            print("Fetching photos failed:", error)
            return []
        }
    }
    
    //MARK:- Save
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            
            do {
                try context.save()
            } catch let error {
                fatalError("Context failed to save:\(error)" )
            }
        }
    }
}
