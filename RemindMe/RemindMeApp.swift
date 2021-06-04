//
//  RemindMeApp.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import SwiftUI

@main
struct RemindMeApp: App {

    @StateObject var dataController: DataController

    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .onReceive(
                    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                    perform: save)
        }
    }

    func save(_ notification: Notification) {
        dataController.save()
    }
}
