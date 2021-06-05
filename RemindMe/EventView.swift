//
//  EventView.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import Foundation
import SwiftUI
import EventKitUI

struct EventView: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentationMode

    let eventStore: EKEventStore
    let event: EKEvent?

    func makeCoordinator() -> EventCoordinator {
        return EventCoordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<EventView>) -> EKEventEditViewController {

        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.eventStore = eventStore

        if let event = event {
            eventEditViewController.event = event
        }
        eventEditViewController.editViewDelegate = context.coordinator

        return eventEditViewController
    }

    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: UIViewControllerRepresentableContext<EventView>) {
        
    }

    func updateUIView(_ uiView: EKEventEditViewController, context: Context) {

    }

}
