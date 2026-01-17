import Foundation
import SwiftUI
import Combine

class AlarmManager: ObservableObject {
    @Published var currentAlarm: Alarm?
    @Published var isAlarmRinging: Bool = false

    private let userDefaultsKey = "savedAlarm"

    init() {
        loadAlarm()
    }

    func setAlarm(time: Date) {
        let alarm = Alarm(time: time)
        currentAlarm = alarm
        saveAlarm()
        scheduleNotification(for: alarm)
        HapticManager.shared.impact(style: .medium)
    }

    func snoozeAlarm() {
        guard var alarm = currentAlarm, alarm.canSnooze else { return }

        alarm.snoozeCount += 1
        alarm.lastSnoozeDate = Date()

        // Snooze for 9 minutes
        let snoozeTime = Calendar.current.date(byAdding: .minute, value: 9, to: Date()) ?? Date()
        alarm.time = snoozeTime

        currentAlarm = alarm
        saveAlarm()
        scheduleNotification(for: alarm)
        isAlarmRinging = false

        HapticManager.shared.notification(type: .warning)
    }

    func dismissAlarm() {
        guard let alarm = currentAlarm else { return }

        // If alarm was snoozed and now dismissed, reset for next day
        if alarm.snoozeCount > 0 {
            var newAlarm = alarm
            newAlarm.snoozeCount = 0
            newAlarm.lastSnoozeDate = nil

            // Set for tomorrow at the original time
            if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: alarm.time) {
                newAlarm.time = tomorrow
                currentAlarm = newAlarm
                saveAlarm()
                scheduleNotification(for: newAlarm)
            }
        }

        isAlarmRinging = false
        HapticManager.shared.notification(type: .success)
    }

    func deleteAlarm() {
        currentAlarm = nil
        saveAlarm()
        cancelNotifications()
        HapticManager.shared.impact(style: .light)
    }

    func triggerAlarm() {
        isAlarmRinging = true
        HapticManager.shared.startAlarmHaptics()
    }

    private func scheduleNotification(for alarm: Alarm) {
        NotificationManager.shared.scheduleAlarmNotification(for: alarm)
    }

    private func cancelNotifications() {
        NotificationManager.shared.cancelAllNotifications()
    }

    private func saveAlarm() {
        if let alarm = currentAlarm {
            if let encoded = try? JSONEncoder().encode(alarm) {
                UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            }
        } else {
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }

    private func loadAlarm() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let alarm = try? JSONDecoder().decode(Alarm.self, from: data) {
            currentAlarm = alarm
        }
    }
}
