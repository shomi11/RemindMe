//
//  DataController.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import Foundation
import CoreData


class DataController: ObservableObject {

    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "Task", managedObjectModel: Self.model)
        container.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("cant load data, app is dead \(String(describing: error?.localizedDescription))") }
        }
    }

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Task", withExtension: "momd") else {
            fatalError("cant find Main")
        }
        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("cant load model") }
        return model
    }()

    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }

    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
        let batchRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? container.viewContext.execute(batchRequest1)
    }

}
