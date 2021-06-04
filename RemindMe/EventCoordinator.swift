//
//  EventCoordinator.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import Foundation
import SwiftUI
import EventKitUI

class EventCoordinator: NSObject, EKEventEditViewDelegate {

    let parent: EventView

    init(parent: EventView) {
        self.parent = parent
    }

    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        parent.presentationMode.wrappedValue.dismiss()

        if action != .canceled {
          //  NotificationCenter.default.post(name: .eventsDidChange, object: nil) // custom notification to reload UI when events changed
        }
    }

}
