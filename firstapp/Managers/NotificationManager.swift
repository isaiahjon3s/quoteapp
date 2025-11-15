//
//  NotificationManager.swift
//  firstapp
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI
import UserNotifications
import Combine

// MARK: - App Notification Model
struct AppNotification: Identifiable, Codable {
    let id: String
    let type: NotificationType
    let title: String
    let message: String
    let userId: String? // User who triggered the notification
    let relatedId: String? // Related conversation, post, etc.
    let createdAt: Date
    var isRead: Bool
    
    enum NotificationType: String, Codable {
        case newMessage
        case newFollower
        case newComment
        case newLike
        case productSold
    }
    
    init(
        id: String = UUID().uuidString,
        type: NotificationType,
        title: String,
        message: String,
        userId: String? = nil,
        relatedId: String? = nil,
        createdAt: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.userId = userId
        self.relatedId = relatedId
        self.createdAt = createdAt
        self.isRead = isRead
    }
}

@MainActor
class NotificationManager: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var hasUnreadNotifications: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        requestNotificationPermission()
        createMockNotifications()
        updateUnreadStatus()
    }
    
    // MARK: - Permission
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Create Notifications
    
    private func createMockNotifications() {
        notifications = [
            AppNotification(
                type: .newMessage,
                title: "New Message",
                message: "Sarah Chen sent you a message",
                userId: "user2",
                relatedId: "conversation1",
                createdAt: Date().addingTimeInterval(-300),
                isRead: false
            ),
            AppNotification(
                type: .newComment,
                title: "New Comment",
                message: "Mike Rodriguez commented on your post",
                userId: "user3",
                relatedId: "post1",
                createdAt: Date().addingTimeInterval(-1800),
                isRead: false
            ),
            AppNotification(
                type: .newLike,
                title: "New Like",
                message: "Emma Wilson liked your post",
                userId: "user4",
                relatedId: "post2",
                createdAt: Date().addingTimeInterval(-3600),
                isRead: true
            ),
            AppNotification(
                type: .newFollower,
                title: "New Follower",
                message: "David Kim started following you",
                userId: "user5",
                createdAt: Date().addingTimeInterval(-7200),
                isRead: true
            )
        ]
    }
    
    // MARK: - Add Notification
    
    func addNotification(
        type: AppNotification.NotificationType,
        title: String,
        message: String,
        userId: String? = nil,
        relatedId: String? = nil
    ) {
        let notification = AppNotification(
            type: type,
            title: title,
            message: message,
            userId: userId,
            relatedId: relatedId
        )
        
        notifications.insert(notification, at: 0)
        updateUnreadStatus()
        
        // Send local notification if app is in background
        scheduleLocalNotification(notification: notification)
    }
    
    func addMessageNotification(from userName: String, conversationId: String) {
        addNotification(
            type: .newMessage,
            title: "New Message",
            message: "\(userName) sent you a message",
            relatedId: conversationId
        )
    }
    
    // MARK: - Local Notifications
    
    private func scheduleLocalNotification(notification: AppNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message
        content.sound = .default
        content.badge = NSNumber(value: getUnreadCount())
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Notification Management
    
    func markAsRead(_ notificationId: String) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
            updateUnreadStatus()
        }
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        updateUnreadStatus()
        
        // Clear badge
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    func deleteNotification(_ notificationId: String) {
        notifications.removeAll { $0.id == notificationId }
        updateUnreadStatus()
    }
    
    func getUnreadCount() -> Int {
        notifications.filter { !$0.isRead }.count
    }
    
    private func updateUnreadStatus() {
        hasUnreadNotifications = getUnreadCount() > 0
    }
    
    // MARK: - Filter Notifications
    
    func getNotifications(ofType type: AppNotification.NotificationType) -> [AppNotification] {
        notifications.filter { $0.type == type }
    }
    
    func getUnreadNotifications() -> [AppNotification] {
        notifications.filter { !$0.isRead }
    }
}

