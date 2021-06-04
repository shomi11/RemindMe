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
        NavigationLink(destination: TaskEditView()) {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Text(task.unwrappedName)
                        .font(.largeTitle)
                    if let _ = task.remindMe {
                        Image(systemName: "alarm")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                    }
                }
                if let detail = task.detail {
                    Text(detail)
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
