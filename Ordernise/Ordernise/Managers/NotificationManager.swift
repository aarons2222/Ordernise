//
//  NotificationManager.swift
//  Ordernise
//
//  Created by Aaron Strickland on 18/08/2025.
//

import Foundation
import UserNotifications
internal import Combine

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        Task {
            await updateAuthorizationStatus()
        }
    }
    
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await updateAuthorizationStatus()
            return granted
        } catch {
            print("❌ [NotificationManager] Failed to request permission: \(error)")
            return false
        }
    }
    
    private func updateAuthorizationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    func scheduleOrderCompletionReminder(
        orderId: UUID,
        orderReference: String?,
        customerName: String?,
        completionDate: Date,
        timeBeforeCompletion: TimeInterval
    ) async -> String? {
        // Check permission first
        guard authorizationStatus == .authorized else {
            print("❌ [NotificationManager] Not authorized to send notifications")
            return nil
        }
        
        // Calculate notification date
        let notificationDate = completionDate.addingTimeInterval(-timeBeforeCompletion)
        
        // Don't schedule if notification date is in the past
        guard notificationDate > Date() else {
            print("⚠️ [NotificationManager] Notification date is in the past, skipping")
            return nil
        }
        
        let notificationId = "order_reminder_\(orderId.uuidString)"
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Order Completion Reminder")
        
        let displayName = customerName ?? (orderReference ?? "Unknown Order")
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .medium
        timeFormatter.timeStyle = .short
        
        content.body = String(localized: "Order for \(displayName) is due to complete on \(timeFormatter.string(from: completionDate))")
        content.sound = .default
        content.badge = 1
        
        // Add user info for handling when notification is tapped
        content.userInfo = [
            "orderId": orderId.uuidString,
            "type": "order_completion"
        ]
        
        // Create trigger
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        // Schedule notification
        let center = UNUserNotificationCenter.current()
        do {
            try await center.add(request)
            print("✅ [NotificationManager] Scheduled reminder for order \(orderId) at \(notificationDate)")
            return notificationId
        } catch {
            print("❌ [NotificationManager] Failed to schedule notification: \(error)")
            return nil
        }
    }
    
    func cancelReminder(notificationId: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationId])
        print("🗑️ [NotificationManager] Cancelled reminder: \(notificationId)")
    }
    
    func cancelAllOrderReminders(orderId: UUID) {
        let notificationId = "order_reminder_\(orderId.uuidString)"
        cancelReminder(notificationId: notificationId)
    }
}

// MARK: - Time Period Options
enum ReminderTimePeriod: CaseIterable, Identifiable {
    case fifteenMinutes
    case oneHour
    case fourHours
    case twelveHours
    case oneDay
    case twoDays
    case oneWeek
    
    var id: String { self.rawValue }
    
    var rawValue: String {
        switch self {
        case .fifteenMinutes: return "15_minutes"
        case .oneHour: return "1_hour"
        case .fourHours: return "4_hours"
        case .twelveHours: return "12_hours"
        case .oneDay: return "1_day"
        case .twoDays: return "2_days"
        case .oneWeek: return "1_week"
        }
    }
    
    var timeInterval: TimeInterval {
        switch self {
        case .fifteenMinutes: return 15 * 60 // 15 minutes
        case .oneHour: return 60 * 60 // 1 hour
        case .fourHours: return 4 * 60 * 60 // 4 hours
        case .twelveHours: return 12 * 60 * 60 // 12 hours
        case .oneDay: return 24 * 60 * 60 // 1 day
        case .twoDays: return 2 * 24 * 60 * 60 // 2 days
        case .oneWeek: return 7 * 24 * 60 * 60 // 1 week
        }
    }
    
    var localizedName: String {
        switch self {
        case .fifteenMinutes: return String(localized: "15 minutes before")
        case .oneHour: return String(localized: "1 hour before")
        case .fourHours: return String(localized: "4 hours before")
        case .twelveHours: return String(localized: "12 hours before")
        case .oneDay: return String(localized: "1 day before")
        case .twoDays: return String(localized: "2 days before")
        case .oneWeek: return String(localized: "1 week before")
        }
    }
}
