import SwiftUI
import UserNotifications

@main
struct SnoozeTaxApp: App {
    @StateObject private var alarmManager = AlarmManager()
    @StateObject private var debtTracker = DebtTracker()
    @StateObject private var notificationManager = NotificationManager()

    init() {
        setupAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmManager)
                .environmentObject(debtTracker)
                .environmentObject(notificationManager)
                .preferredColorScheme(.dark)
                .onAppear {
                    notificationManager.requestAuthorization()
                }
        }
    }

    private func setupAppearance() {
        // Force dark mode
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .dark
        }
    }
}
