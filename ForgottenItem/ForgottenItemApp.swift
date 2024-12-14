import SwiftUI

@main
struct ForgottenItemApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            CheckCategoryView()
        }
    }
}
