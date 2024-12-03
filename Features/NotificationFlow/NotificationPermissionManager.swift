import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    /// アプリ起動時の処理
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        print("___application:didFinishLaunchingWithOptions")

        // Push通知許諾処理
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) {_ , error in //
            if let error {
                // 通知が拒否された場合
                print(error.localizedDescription)
            } else {
                print("Push通知許諾OK")
            }
        }
        application.registerForRemoteNotifications()
        return true
    }
}
