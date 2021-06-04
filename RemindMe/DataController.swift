//
//  DataController.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import Foundation
import CoreData
import EventKit
import UserNotifications

class DataController: ObservableObject {

    let container: NSPersistentCloudKitContainer
    let eventStore: EKEventStore!

    init(inRAMMemoryUsage: Bool = false) {

        container = NSPersistentCloudKitContainer(name: "Task", managedObjectModel: Self.model)
        eventStore = EKEventStore()

        if inRAMMemoryUsage {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
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

    static var preview: DataController = {
        let controller = DataController(inRAMMemoryUsage: true)
        do {
            try controller.createSampleData()
        } catch {
            fatalError("fatal error creating preview \(error.localizedDescription)")
        }
        return controller
    }()

    func createSampleData() throws {
        let context = container.viewContext
        for jus in 1...10 {
            let task = Task(context: context)
            task.name = "Task \(jus)"
            task.remindMe = Date()
            task.detail = "Task detail \(jus)"
            task.isCompleted = Bool.random()
        }
        try context.save()
    }
}

extension DataController {

    func addEvent(for task: Task, completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            completion(granted)
        }
    }

    func removeEvent(task: Task) {
        let taskID = task.objectID.uriRepresentation().absoluteString
        guard let event = eventStore.event(withIdentifier: taskID) else { return }
        try? eventStore.remove(event, span: .thisEvent, commit: true)
    }

    func setNotification(for task: Task, completion: @escaping (Bool) -> Void) {
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotification { granted in
                    switch granted {
                    case true:
                        self.placeNotification(for: task, completion: completion)
                    case false:
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .authorized:
                self.placeNotification(for: task, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    func removeNotification(for task: Task) {
        let userNotificationCenter = UNUserNotificationCenter.current()
        let taskID = task.objectID.uriRepresentation().absoluteString
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [taskID])
    }

    private func requestNotification(completion: @escaping (Bool) -> Void) {
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.requestAuthorization(options: [.alert, .sound]) { isGranted, _ in
            completion(isGranted)
        }
    }

    private func placeNotification(for task: Task, completion: @escaping (Bool) -> Void) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = task.unwrappedName
        notificationContent.sound = .default
        if let detail = task.detail {
            notificationContent.subtitle = detail
        }

        let dateComponents = Calendar.current.dateComponents(
            [.hour, .minute],
            from: task.remindMe ?? Date()
        )

        let notificationTrigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let notificationID = task.objectID.uriRepresentation().absoluteString
        let notificationRequest = UNNotificationRequest(
            identifier: notificationID,
            content: notificationContent,
            trigger: notificationTrigger
        )

        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.add(notificationRequest) { error in
            DispatchQueue.main.async {
                if error != nil {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
