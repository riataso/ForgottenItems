import Foundation
import UserNotifications

class NotificationSender {

    func sendPush() {
        let content = UNMutableNotificationContent()
        content.title = "Pushテスト"
        content.body = "テスト通知用"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "alerm_id", content: content, trigger: trigger)

//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
}


