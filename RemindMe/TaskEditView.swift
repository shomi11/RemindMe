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

    @State private var eventAlreadyCreated: Bool
    @State private var name: String
    @State private var detail: String
    @State private var isCompleted: Bool
    @State private var eventDate: Date?
    @State private var eventActive: Bool = false
    @State private var event: EKEvent?

    init(task: Task) {
        self.task = task
        _name = State(wrappedValue: task.unwrappedName)
        _detail = State(wrappedValue: task.detail ?? "Enter detail")
        _isCompleted = State(wrappedValue: task.isCompleted)
        if let _ = task.eventIdentifier {
            _eventAlreadyCreated = State(wrappedValue: true)
        } else {
            _eventAlreadyCreated = State(wrappedValue: false)
        }
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
                    VStack {
                        Button(action: {
                            eventAction()
                        }, label: {
                            Text(eventAlreadyCreated ? "Delete event" : "Create event")
                                .font(.titleFont)
                        })
                    }
                }

                Section {
                    Button("Delete task", action: deleteTask)
                        .foregroundColor(.red)
                }

                if eventAlreadyCreated {
                    Section(header: Text("About event")) {
                        eventView
                    }
                }
            }

            navLinkEvent

        }.onAppear(perform: {
            eventAlreadyCreated = isAlreadyEventCreated()
        })
        .onTapGesture {
            endTextEditing()
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

    var eventView: some View {
        VStack {
            if let title = event?.title {
                Text(title)
                    .font(.titleFont)
            }
            if let date = eventAlarmDate {
                HStack {
                    Image(systemName: "alarm")
                    Text(date)
                }
            }
        }
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

    private func deleteEvent() {
        dataController.removeEvent(task: task)
        updateTask()
        dataController.save()
    }

    private func deleteTask() {
        dataController.delete(task)
        dataController.save()
    }

    private func eventAction() {
        if isAlreadyEventCreated() {
            deleteEvent()
        } else {
            createEvent()
        }
    }

    private func isAlreadyEventCreated() -> Bool {
        if let event = dataController.eventStore.event(withIdentifier: task.eventIdentifier ?? "") {
            self.event = event
            return true
        } else {
            return false
        }
    }

    private func updateTask() {
        task.name = name
        task.detail = detail
        eventAlreadyCreated = isAlreadyEventCreated()
    }

    private func showNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsURL)
    }

    var eventAlarmDate: String? {
        guard let date = event?.alarms?.first?.absoluteDate else { return nil }
        let dateString = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .medium)
        return dateString
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

extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil, for: nil
        )
    }
}
