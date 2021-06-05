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
    @State private var eventDate: Date?
    @State private var shouldAddEvent: Bool
    @State private var eventActive: Bool = false
    @State private var event: EKEvent?

    init(task: Task) {
        self.task = task
        _name = State(wrappedValue: task.unwrappedName)
        _detail = State(wrappedValue: task.detail ?? "Enter detail")
        _isCompleted = State(wrappedValue: task.isCompleted)
        _shouldAddEvent = State(wrappedValue: task.eventAdded)
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Basic settings:")) {
                    TextField("Task name", text: $name.onChange(updateTask))
                        .font(.titleFont)
                    ZStack {
                        TextEditor(text: $detail.onChange(updateTask))
                            .font(.subTitleFont)
                        Text(name).opacity(0)
                    }
                }

                Section(header: Text("Calendar")) {
                        Button(action: {
                            createEvent()
                        }, label: {
                            Text("Create event")
                                .font(.titleFont)
                        })
                }
            }
            navLinkEvent
        }
        .navigationBarTitle(Text(task.unwrappedName), displayMode: .inline)
    }

    var navLinkEvent: some View {
        NavigationLink(
            destination: EventView(eventStore: dataController.eventStore, event: event),
            isActive: $eventActive,
            label: {
                EmptyView()
            })
            .opacity(0.0)
            .frame(width: 0, height: 0)
            .hidden()
    }

    private func createEvent() {
        dataController.addEvent(for: task) { success in
            if success {
                let event = EKEvent(eventStore: dataController.eventStore)
                event.title = task.unwrappedName
                task.eventIdentifier = event.calendarItemIdentifier
                self.event = event
                updateTask()
                eventActive.toggle()
            }
        }
    }

    private func updateTask() {
        task.name = name
        task.detail = detail
        if shouldAddEvent == false {
            task.eventAdded = false
            dataController.removeEvent(task: task)
        } else {
            task.eventAdded = true
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
