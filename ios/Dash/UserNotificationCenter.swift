//
//  UserNotificationManager.swift
//  ETC
//
//  Created by Yuji Nakayama on 2019/06/03.
//  Copyright © 2019 Yuji Nakayama. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseMessaging

class UserNotificationCenter: NSObject, UNUserNotificationCenterDelegate {
    static let shared = UserNotificationCenter()

    let authorizationOptions: UNAuthorizationOptions = [.sound, .alert]
    let presentationOptions: UNNotificationPresentationOptions = [.sound, .alert]

    var notificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }

    let notificationHistory = LatestUserNotificationHistory()

    override init() {
        super.init()
        notificationCenter.delegate = self
    }

    func setUp() {
        requestAuthorization()
        UIApplication.shared.registerForRemoteNotifications()
    }

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: authorizationOptions) { (granted, error) in
            logger.info((granted, error))
        }
    }

    func requestDelivery(_ notification: UserNotificationProtocol) {
        logger.info(notification)
        guard notification.shouldBeDelivered(history: notificationHistory) else { return }
        deliver(notification)
    }

    private func deliver(_ notification: UserNotificationProtocol) {
        logger.info(notification)

        UNUserNotificationCenter.current().add(notification.makeRequest()) { (error) in
            if let error = error {
                logger.error(error)
            }
        }

        notificationHistory.append(notification)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        logger.info(notification)

        Messaging.messaging().appDidReceiveMessage(notification.request.content.userInfo)

        notificationCenter.getNotificationSettings { [unowned self] (settings) in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                // Show the stock notification UI even when this app is in the foreground
                completionHandler(self.presentationOptions)
            default:
                return
            }
        }
    }
}

class LatestUserNotificationHistory {
    let dropOutTimeInterval: TimeInterval = 5

    private var notifications: [UserNotificationProtocol] = []

    func append(_ notification: UserNotificationProtocol) {
        notifications.append(notification)

        Timer.scheduledTimer(withTimeInterval: dropOutTimeInterval, repeats: false) { [weak self] (timer) in
            guard let self = self else { return }
            self.notifications.removeFirst()
        }
    }

    func contains(where predicate: (UserNotificationProtocol) -> Bool) -> Bool {
        return notifications.contains(where: predicate)
    }
}
