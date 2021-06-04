//
//  TaskRowView.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import SwiftUI

struct TaskRowView: View {

    @ObservedObject var task: Task

    var body: some View {
        NavigationLink(destination: TaskEditView(task: task)) {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    if let _ = task.remindMe {
                        Image(systemName: "alarm")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    Text(task.unwrappedName)
                        .font(.title)
                }
                if let detail = task.detail {
                    Text(detail)
                        .font(.title3)
                }
            }
        }
    }
}

struct TaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        TaskRowView(task: Task.example)
    }
}
