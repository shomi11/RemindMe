//
//  TaskExtension.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import Foundation


extension Task {

    var unwrappedName: String {
        name ?? "New Task"
    }

    var unwrappedReminderDate: Date {
        remindMe ?? Date()
    }

    var unwrappedDetail: String {
        detail ?? ""
    }

    static let example: Task = {
        let controller = DataController.preview
        let task = Task(context: controller.container.viewContext)
        task.detail = "Some detail here"
        task.isCompleted = false
        task.name = "Here is name"
        task.remindMe = Date()
        return task
    }()

}
