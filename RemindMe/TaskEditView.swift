//
//  TaskEditView.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import SwiftUI
import EventKit

struct TaskEditView: View {

    var task: Task
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteConfirmation = false

    @State private var name: String
    @State private var detail: String
    @State private var isCompleted: Bool
    @State private var remindMe: Date
    @State private var shouldRemindMe: Bool = false
    @State private var showNotificationError: Bool = false
    @State private var eventDate: Date?
    @State private var shouldAddEvent: Bool = false
    @State private var eventActive: Bool = false
    @State private var event: EKEvent?

    init(task: Task) {
        self.task = task
        _name = State(wrappedValue: task.unwrappedName)
        _detail = State(wrappedValue: task.unwrappedDetail)
        _isCompleted = State(wrappedValue: task.isCompleted)
        if let reminder = task.remindMe {
            _remindMe = State(wrappedValue: reminder)
            _shouldRemindMe = State(wrappedValue: true)
        } else {
            _remindMe = State(wrappedValue: Date())
            _shouldRemindMe = State(wrappedValue: false)
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Basic settings:")) {
                TextField("Task name", text: $name.onChange(updateTask))
                ZStack {
                    TextEditor(text: $detail)
                    Text(name).opacity(0)
                }
            }
            Section(header: Text("Reminder")) {
                Toggle("Show reminder", isOn: $shouldRemindMe.animation().onChange(updateTask))
                    .alert(isPresented: $showNotificationError) {
                        Alert(
                            title: Text("Something went wrong"),
                            message: Text("Notification problem"),
                            primaryButton: .default(Text("Show app settings"), action: showNotificationSettings),
                            secondaryButton: .cancel()
                        )
                    }
                if shouldRemindMe {
                    DatePicker(
                        "Time",
                        selection: $remindMe.onChange(updateTask),
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            Section(header: Text("Event")) {
                Toggle("Add event", isOn: $shouldAddEvent.animation().onChange(updateTask))
                    .onChange(of: shouldAddEvent, perform: { value in
                        if value == true {
                            dataController.addEvent(for: task) { success in
                                if success {
                                    let event = EKEvent(eventStore: dataController.eventStore)
                                    event.title = task.unwrappedName
                                    self.event = event
                                    eventActive.toggle()
                                }
                            }
                        }
                    })
                NavigationLink(destination:
                                EventView(eventStore: dataController.eventStore, event: event),
                               isActive: self.$eventActive) {
                    EmptyView()
                }
            }
        }
    }

    private func updateTask() {
        task.name = name
        task.detail = detail
        if shouldRemindMe {
            task.remindMe = remindMe
            dataController.setNotification(for: task) { success in
                if !success {
                    task.remindMe = nil
                    shouldRemindMe = false
                    showNotificationError = true
                }
            }
        } else {
            task.remindMe = nil
            dataController.removeNotification(for: task)
        }
    }

    private func showNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsURL)
    }
}

struct TaskEditView_Previews: PreviewProvider {
    static let dataController = DataController.preview
    static var previews: some View {
        TaskEditView(task: Task.example)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
