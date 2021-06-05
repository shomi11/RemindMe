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
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    Text(task.unwrappedName)
                        .font(.titleFont)
                }
                if let detail = task.detail {
                    Text(detail)
                        .font(.subTitleFont)
                }
            }
            .padding([.top, .bottom], 8)
        }
    }
}

struct TaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        TaskRowView(task: Task.example)
    }
}

