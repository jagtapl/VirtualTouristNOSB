//
//  DataController.swift
//  Mooskine
//
//  Created by LALIT JAGTAP on 4/29/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    // 1> hold persistent container instance
    let persistentContainer: NSPersistentContainer
    
    var backgroundContext: NSManagedObjectContext!
    
    func configureContexts() {
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }

    // 2> load persistent store
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            // set initial auto save interval
            self.autoSaveViewContext()
            
            // configure context for background thread
            self.configureContexts()
            
            completion?()
        }
    }

    // 3> help us access the context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}

extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 30) {
        print("auto saving")
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
