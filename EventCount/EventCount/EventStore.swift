//
//  EventStore.swift
//  EventCount
//
//  Created by Esther Ramos on 17/01/26.
//

import Foundation
import Combine
import SwiftUI

class EventStore: ObservableObject {
    @Published var events: [Event] = []
    @Published var timer: Timer?
    @Published var currentTime = Date()
    
    private let saveKey = "SavedEvents"
    
    init() {
        loadEvents()
        startTimer()
        scheduleNotifications()
    }
    
    func addEvent(title: String, date: Date, colorName: String, iconName: String) {
        let event = Event(title: title, date: date, colorName: colorName, iconName: iconName)
        events.append(event)
        events.sort { $0.date < $1.date }
        saveEvents()
        scheduleNotification(for: event)
    }
    
    func updateEvent(_ event: Event, title: String, date: Date, colorName: String, iconName: String) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = Event(id: event.id, title: title, date: date, colorName: colorName, iconName: iconName)
            events.sort { $0.date < $1.date }
            saveEvents()
            updateNotification(for: events[index])
        }
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        saveEvents()
        cancelNotification(for: event)
    }
    
    func deleteEvent(at indexSet: IndexSet) {
        events.remove(atOffsets: indexSet)
        saveEvents()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.currentTime = Date()
        }
    }
    
    private func saveEvents() {
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadEvents() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Event].self, from: data) {
            events = decoded.sorted { $0.date < $1.date }
        } else {
            // Add sample events for first-time users
            addSampleEvents()
        }
    }
    
    private func addSampleEvents() {
        let calendar = Calendar.current
        
        // Tomorrow's event
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) {
            addEvent(
                title: "Meeting with Team",
                date: calendar.date(bySettingHour: 14, minute: 30, second: 0, of: tomorrow) ?? tomorrow,
                colorName: "Blue",
                iconName: "briefcase"
            )
        }
        
        // In 3 days
        if let threeDays = calendar.date(byAdding: .day, value: 3, to: Date()) {
            addEvent(
                title: "Movie Night",
                date: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: threeDays) ?? threeDays,
                colorName: "Purple",
                iconName: "film"
            )
        }
        
        // Next week
        if let nextWeek = calendar.date(byAdding: .day, value: 7, to: Date()) {
            addEvent(
                title: "Birthday Party",
                date: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: nextWeek) ?? nextWeek,
                colorName: "Pink",
                iconName: "birthday.cake"
            )
        }
    }
    
    // MARK: - Notifications
    
    private func scheduleNotifications() {
        // Request permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    private func scheduleNotification(for event: Event) {
        guard event.date > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Event Countdown"
        content.body = "\(event.title) is starting now!"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: event.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func updateNotification(for event: Event) {
        cancelNotification(for: event)
        scheduleNotification(for: event)
    }
    
    private func cancelNotification(for event: Event) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.id.uuidString])
    }
    
    deinit {
        timer?.invalidate()
    }
}
