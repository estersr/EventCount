//
//  EventCountApp.swift
//  EventCount
//
//  Created by Esther Ramos on 02/07/25.
//

import SwiftUI

@main
struct EventCountApp: App {
    @StateObject private var eventStore = EventStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(eventStore)
        }
    }
}
