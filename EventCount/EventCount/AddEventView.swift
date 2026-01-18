//
//  AddEventView.swift
//  EventCount
//
//  Created by Esther Ramos on 17/01/26.
//

import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    let event: Event?
    let onSave: (Event) -> Void
    
    @State private var title: String
    @State private var date: Date
    @State private var selectedColor: String
    @State private var selectedIcon: String
    
    init(event: Event?, onSave: @escaping (Event) -> Void) {
        self.event = event
        self.onSave = onSave
        
        _title = State(initialValue: event?.title ?? "")
        _date = State(initialValue: event?.date ?? Date().addingTimeInterval(86400)) // Tomorrow
        _selectedColor = State(initialValue: event?.colorName ?? "Blue")
        _selectedIcon = State(initialValue: event?.iconName ?? "calendar")
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Info Section
                Section {
                    TextField("Event Title", text: $title)
                    
                    DatePicker("Date & Time",
                             selection: $date,
                             in: Date()...,
                             displayedComponents: [.date, .hourAndMinute])
                }
                
                // Color Selection
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(Color.availableColors, id: \.name) { appColor in
                                colorOption(appColor: appColor)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                // Icon Selection
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                        ForEach(availableIcons, id: \.self) { icon in
                            iconOption(iconName: icon)
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                // Quick Date Suggestions
                Section("Quick Dates") {
                    VStack(spacing: 10) {
                        quickDateButton(title: "Tomorrow", days: 1)
                        quickDateButton(title: "Next Week", days: 7)
                        quickDateButton(title: "30 Days", days: 30)
                        quickDateButton(title: "Next Year", days: 365)
                    }
                }
            }
            .navigationTitle(event == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newEvent = Event(
                            id: event?.id ?? UUID(),
                            title: title.isEmpty ? "New Event" : title,
                            date: date,
                            colorName: selectedColor,
                            iconName: selectedIcon
                        )
                        onSave(newEvent)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func colorOption(appColor: AppColor) -> some View {
        Button(action: {
            selectedColor = appColor.name
        }) {
            VStack(spacing: 8) {
                Circle()
                    .fill(appColor.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if selectedColor == appColor.name {
                                Circle()
                                    .stroke(appColor.color, lineWidth: 3)
                                    .frame(width: 50, height: 50)
                            }
                        }
                    )
                
                Text(appColor.name)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(width: 60)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconOption(iconName: String) -> some View {
        Button(action: {
            selectedIcon = iconName
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(selectedIcon == iconName ? Color.from(name: selectedColor).opacity(0.2) : Color(.systemGray6))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(selectedIcon == iconName ? Color.from(name: selectedColor) : .primary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func quickDateButton(title: String, days: Int) -> some View {
        Button(action: {
            if let newDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) {
                date = newDate
            }
        }) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("+\(days) days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
}
