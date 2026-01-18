//
//  ContentView.swift
//  EventCount
//
//  Created by Esther Ramos on 02/07/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var showingAddEvent = false
    @State private var editingEvent: Event?
    
    var upcomingEvents: [Event] {
        eventStore.events.filter { $0.date > Date() }
    }
    
    var pastEvents: [Event] {
        eventStore.events.filter { $0.date <= Date() }
    }
    
    var nextEvent: Event? {
        upcomingEvents.first
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Next Event Countdown
                        if let nextEvent = nextEvent {
                            nextEventView(event: nextEvent)
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                        } else {
                            noEventsView
                                .padding(.horizontal, 20)
                                .padding(.top, 40)
                        }
                        
                        // All Upcoming Events
                        if !upcomingEvents.isEmpty {
                            eventsListView(events: upcomingEvents, title: "Upcoming Events")
                                .padding(.horizontal, 20)
                        }
                        
                        // Past Events
                        if !pastEvents.isEmpty {
                            eventsListView(events: pastEvents, title: "Past Events")
                                .padding(.horizontal, 20)
                        }
                        
                        // Quick Add Suggestions
                        quickAddSuggestions
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        addEventButton
                            .padding(.trailing, 20)
                            .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("EventCount")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEvent = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(event: nil) { event in
                    eventStore.addEvent(title: event.title, date: event.date, colorName: event.colorName, iconName: event.iconName)
                }
            }
            .sheet(item: $editingEvent) { event in
                AddEventView(event: event) { updatedEvent in
                    eventStore.updateEvent(event, title: updatedEvent.title, date: updatedEvent.date, colorName: updatedEvent.colorName, iconName: updatedEvent.iconName)
                }
            }
        }
    }
    
    private func nextEventView(event: Event) -> some View {
        VStack(spacing: 20) {
            // Event Header
            HStack {
                Image(systemName: event.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(event.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(event.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(event.relativeDateString)
                        .font(.caption)
                        .foregroundColor(event.isToday ? .red : .secondary)
                }
                
                Spacer()
            }
            
            // Countdown Timer
            CountdownTimerView(event: event)
            
            // Progress Bar
            if !event.timeRemaining.hasPassed {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time remaining: \(event.timeRemaining.detailedFormatted)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(event.color)
                                .frame(width: calculateProgressWidth(for: event, in: geometry.size.width), height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
        )
    }
    
    private func calculateProgressWidth(for event: Event, in totalWidth: CGFloat) -> CGFloat {
        guard !event.timeRemaining.hasPassed else { return 0 }
        
        // Simple progress based on time until event
        let totalDuration = event.timeRemaining.totalSeconds + 1 // Avoid division by zero
        let remaining = max(0, totalDuration)
        let progress = 1.0 - Double(remaining) / Double(totalDuration + 86400) // Add buffer for long events
        return totalWidth * CGFloat(progress)
    }
    
    private var noEventsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 70))
                .foregroundColor(.blue)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 8) {
                Text("No Upcoming Events")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Add your first event to start counting down")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func eventsListView(events: [Event], title: String) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 5)
            
            LazyVStack(spacing: 12) {
                ForEach(events) { event in
                    eventRow(event: event)
                        .contextMenu {
                            Button {
                                editingEvent = event
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                eventStore.deleteEvent(event)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
    
    private func eventRow(event: Event) -> some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(event.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: event.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(event.color)
            }
            
            // Event Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if event.isToday {
                        Text("Today")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.red))
                    } else if event.isTomorrow {
                        Text("Tomorrow")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.orange))
                    }
                }
                
                Text(event.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(event.timeRemaining.formatted)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundColor(event.timeRemaining.hasPassed ? .gray : event.color)
            }
            
            Spacer()
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private var quickAddSuggestions: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Add")
                .font(.headline)
                .padding(.horizontal, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    quickAddButton(title: "Tomorrow", icon: "sun.max", color: .orange, days: 1)
                    quickAddButton(title: "Next Week", icon: "calendar", color: .blue, days: 7)
                    quickAddButton(title: "In 30 Days", icon: "calendar.badge.clock", color: .purple, days: 30)
                    quickAddButton(title: "Next Year", icon: "sparkles", color: .teal, days: 365)
                }
            }
        }
    }
    
    private func quickAddButton(title: String, icon: String, color: Color, days: Int) -> some View {
        Button(action: {
            let newDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
            let event = Event(
                title: "New Event",
                date: newDate,
                colorName: color == .blue ? "Blue" :
                          color == .orange ? "Orange" :
                          color == .purple ? "Purple" : "Teal",
                iconName: icon
            )
            editingEvent = event
        }) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(width: 80)
        }
    }
    
    private var addEventButton: some View {
        Button(action: { showingAddEvent = true }) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct CountdownTimerView: View {
    let event: Event
    @State private var now = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var timeRemaining: TimeRemaining {
        event.timeRemaining
    }
    
    var body: some View {
        HStack(spacing: 15) {
            if timeRemaining.hasPassed {
                VStack(spacing: 5) {
                    Text("00")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    Text("DAYS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Text(":")
                    .font(.title)
                    .foregroundColor(.gray)
                
                VStack(spacing: 5) {
                    Text("00")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    Text("HOURS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Text(":")
                    .font(.title)
                    .foregroundColor(.gray)
                
                VStack(spacing: 5) {
                    Text("00")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    Text("MINUTES")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Text(":")
                    .font(.title)
                    .foregroundColor(.gray)
                
                VStack(spacing: 5) {
                    Text("00")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    Text("SECONDS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                countdownDigit(value: timeRemaining.days, label: "DAYS")
                
                Text(":")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                countdownDigit(value: timeRemaining.hours, label: "HOURS")
                
                Text(":")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                countdownDigit(value: timeRemaining.minutes, label: "MINUTES")
                
                Text(":")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                countdownDigit(value: timeRemaining.seconds, label: "SECONDS")
            }
        }
        .onReceive(timer) { _ in
            now = Date()
        }
    }
    
    private func countdownDigit(value: Int, label: String) -> some View {
        VStack(spacing: 5) {
            Text(String(format: "%02d", value))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(event.color)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: value)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
