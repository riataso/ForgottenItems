import Foundation
import UserNotifications

class NotificationSender {
    static let shared = NotificationSender()

    private init() {}

    /// 通知の作成
    func scheduleNotification(notificationDate: Date, id: UUID, listTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "リマインダー"
        content.body = "\(listTitle)で未チェックのものがあります。\n 持ち物を確認してください！"
        content.sound = UNNotificationSound.default
        let component = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: notificationDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: component,
            repeats: false
        )
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)

        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error {
                print("通知のスケジュールでエラーが発生しました: \(error.localizedDescription)")
            } else {
                print("通知がスケジュールされました")
            }
        }
    }

    /// 通知を更新（削除して再登録）
    func updateNotification(notificationDate: Date, identifier: UUID, listTitle: String) {
        // 既存の通知を削除
        cancelNotification(identifier: identifier)
        // 新しい通知をスケジュール
        scheduleNotification(notificationDate: notificationDate, id: identifier, listTitle: listTitle)
    }

    /// 通知をキャンセル
    func cancelNotification(identifier: UUID) {
        let center = UNUserNotificationCenter.current()
        let identifierStr = identifier.uuidString
        center.removePendingNotificationRequests(withIdentifiers: [identifierStr])
        print("通知がキャンセルされました。識別子: \(identifier)")
    }
}
