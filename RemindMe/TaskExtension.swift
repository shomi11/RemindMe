//
//  TaskExtension.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import Foundation


extension Task {

    var unwrappedName: String {
        name ?? ""
    }

    var unwrappedReminderDate: Date {
        remindMe ?? Date()
    }

    var unwrappedDetail: String {
        detail ?? ""
    }

}
