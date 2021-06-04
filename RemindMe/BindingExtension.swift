//
//  BindingExtension.swift
//  RemindMe
//
//  Created by Milos Malovic on 4.6.21..
//

import Foundation
import SwiftUI

extension Binding {
    /// Binding extension for calling directly on @State properties
    /// This will save us calling default onChange method on body many times.
    /// - Parameter handler: here we need to execute method that we want when value is changed.
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
