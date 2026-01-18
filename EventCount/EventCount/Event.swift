//
//  Event.swift
//  EventCount
//
//  Created by Esther Ramos on 17/01/26.
//

import Foundation
import SwiftUI

struct Event: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var colorName: String
    var iconName: String
    
    init(id: UUID = UUID(), title: String, date: Date, colorName: String = "Blue", iconName: String = "calendar") {
        self.id = id
        self.title = title
        self.date = date
        self.colorName = colorName
        self.iconName = iconName
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
    
    var color: Color {
        Color.availableColors.first { $0.name == colorName }?.color ?? .blue
    }
    
    var timeRemaining: TimeRemaining {
        let calendar = Calendar.current
        let now = Date()
        
        guard date > now else {
            return TimeRemaining(days: 0, hours: 0, minutes: 0, seconds: 0, hasPassed: true)
        }
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: date)
        
        return TimeRemaining(
            days: components.day ?? 0,
            hours: components.hour ?? 0,
            minutes: components.minute ?? 0,
            seconds: components.second ?? 0,
            hasPassed: false
        )
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var relativeDateString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(date)
    }
    
    var isThisWeek: Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now)!
        return date <= weekFromNow && date > now
    }
}

struct TimeRemaining {
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
    let hasPassed: Bool
    
    var totalSeconds: Int {
        days * 86400 + hours * 3600 + minutes * 60 + seconds
    }
    
    var formatted: String {
        if hasPassed {
            return "Event passed"
        }
        
        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    var detailedFormatted: String {
        if hasPassed {
            return "Event has already occurred"
        }
        
        var parts: [String] = []
        
        if days > 0 {
            parts.append("\(days) day\(days == 1 ? "" : "s")")
        }
        if hours > 0 {
            parts.append("\(hours) hour\(hours == 1 ? "" : "s")")
        }
        if minutes > 0 {
            parts.append("\(minutes) minute\(minutes == 1 ? "" : "s")")
        }
        if seconds > 0 || parts.isEmpty {
            parts.append("\(seconds) second\(seconds == 1 ? "" : "s")")
        }
        
        return parts.joined(separator: " ")
    }
}

struct AppColor {
    let name: String
    let color: Color
}

extension Color {
    static let availableColors: [AppColor] = [
        AppColor(name: "Blue", color: .blue),
        AppColor(name: "Red", color: .red),
        AppColor(name: "Green", color: .green),
        AppColor(name: "Orange", color: .orange),
        AppColor(name: "Purple", color: .purple),
        AppColor(name: "Pink", color: .pink),
        AppColor(name: "Teal", color: .teal),
        AppColor(name: "Indigo", color: .indigo)
    ]
}

extension Color {
    static func from(name: String) -> Color {
        availableColors.first { $0.name == name }?.color ?? .blue
    }
}

let availableIcons = [
    "calendar",
    "birthday.cake",
    "airplane",
    "gift",
    "graduationcap",
    "heart",
    "party.popper",
    "bell",
    "gamecontroller",
    "film",
    "music.note",
    "book",
    "figure.run",
    "car",
    "house",
    "briefcase"
]
