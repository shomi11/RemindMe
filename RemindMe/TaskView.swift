//
//  TaskView.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import SwiftUI

struct TaskView: View {

    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var manageObjectContext

    static let openTag: String? = "OpenTaskView"
    static let closeTag: String? = "ClosedTaskView"

    let showClosedTask: Bool
    let tasks: FetchRequest<Task>

    init(showClosedTask: Bool) {
        self.showClosedTask = showClosedTask
        tasks = FetchRequest<Task>(entity: Task.entity(), sortDescriptors: [
            NSSortDescriptor(keyPath: \Task.name, ascending: false)
        ], predicate: NSPredicate(format: "isCompleted = %d", showClosedTask))
    }


    var body: some View {
        NavigationView {
            Group {
                if tasks.wrappedValue.isEmpty {
                    emptyList
                } else {
                    taskList
                        .padding(.top)
                }
            }
            .navigationTitle(showClosedTask ? "Closed Tasks" : "Open Tasks")
            .toolbar {
                addProjectToolBarItem
            }
        }
    }

    private func addNewTask() {
        withAnimation {
            let task = Task(context: manageObjectContext)
            task.isCompleted = false
            dataController.save()
        }
    }

    private func deleteTask(at offsets: IndexSet) {
        for offset in offsets {
            let task = tasks.wrappedValue[offset]
            dataController.delete(task)
        }
        dataController.save()
    }
}

extension TaskView {
    var taskList: some View {
        List {
            ForEach(tasks.wrappedValue) { task in
                TaskRowView(task: task)
            }
            .onDelete { indexSet in
                deleteTask(at: indexSet)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    var emptyList: some View {
        HStack(spacing: 16) {
            Text(showClosedTask ? "No closed tasks." : "Start new task.")
                .font(.title)
                .italic()
                .foregroundColor(.secondary)
        }
    }

    var addProjectToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if showClosedTask == false {
                Button {
                   addNewTask()
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
            }
        }
    }
}

struct TaskView_Previews: PreviewProvider {

    static var dataController = DataController.preview

    static var previews: some View {
        TaskView(showClosedTask: false)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
