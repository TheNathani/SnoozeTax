import SwiftUI

struct ContentView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @EnvironmentObject var debtTracker: DebtTracker

    @State private var showingAlarmSetter = false
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            // Main content
            if alarmManager.isAlarmRinging {
                AlarmAlertView()
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 1.2).combined(with: .opacity)
                    ))
            } else {
                HomeView(
                    showingAlarmSetter: $showingAlarmSetter,
                    showingSettings: $showingSettings
                )
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showingAlarmSetter) {
            AlarmSetterView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: alarmManager.isAlarmRinging)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AlarmTriggered"))) { _ in
            alarmManager.triggerAlarm()
        }
    }
}
