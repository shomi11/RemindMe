//
//  ContentView.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TaskView(showClosedTask: false)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Open")
                }
            TaskView(showClosedTask: true)
                .tabItem {
                    Image(systemName: "pencil.slash")
                    Text("Closed")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var dataController = DataController.preview

    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
