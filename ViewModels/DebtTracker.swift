import Foundation
import SwiftUI

class DebtTracker: ObservableObject {
    @Published var debtRecords: [DebtRecord] = []
    @Published var partnerVenmoUsername: String = ""

    private let debtsKey = "debtRecords"
    private let venmoKey = "partnerVenmo"

    init() {
        loadDebts()
        loadVenmoUsername()
    }

    var totalUnpaidDebt: Double {
        debtRecords.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    var currentWeekDebt: WeeklyDebt? {
        let calendar = Calendar.current
        let now = Date()

        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return nil
        }

        let weekRecords = debtRecords.filter { record in
            !record.isPaid && record.date >= weekStart && record.date <= weekEnd
        }

        return WeeklyDebt(weekStart: weekStart, weekEnd: weekEnd, records: weekRecords)
    }

    func addSnoozeDebt(alarmTime: String) {
        let debt = DebtRecord(alarmTime: alarmTime)
        debtRecords.append(debt)
        saveDebts()
        HapticManager.shared.notification(type: .error)
    }

    func markWeekAsPaid() {
        guard let weekDebt = currentWeekDebt else { return }

        let recordIDs = Set(weekDebt.records.map { $0.id })
        debtRecords = debtRecords.map { record in
            var updated = record
            if recordIDs.contains(record.id) {
                updated.isPaid = true
            }
            return updated
        }

        saveDebts()
        HapticManager.shared.notification(type: .success)
    }

    func openVenmoPayment() {
        guard !partnerVenmoUsername.isEmpty else { return }
        guard let weekDebt = currentWeekDebt else { return }

        let amount = weekDebt.totalAmount
        let note = "Snooze tax - worth it? 😴"

        // Venmo deep link format: venmo://paycharge?txn=pay&recipients=USERNAME&amount=AMOUNT&note=NOTE
        var components = URLComponents()
        components.scheme = "venmo"
        components.host = "paycharge"
        components.queryItems = [
            URLQueryItem(name: "txn", value: "pay"),
            URLQueryItem(name: "recipients", value: partnerVenmoUsername),
            URLQueryItem(name: "amount", value: String(format: "%.2f", amount)),
            URLQueryItem(name: "note", value: note)
        ]

        if let url = components.url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                HapticManager.shared.impact(style: .medium)
            } else {
                // Fallback to Venmo website
                let webURL = URL(string: "https://venmo.com/\(partnerVenmoUsername)")!
                UIApplication.shared.open(webURL)
            }
        }
    }

    func saveVenmoUsername(_ username: String) {
        partnerVenmoUsername = username
        UserDefaults.standard.set(username, forKey: venmoKey)
    }

    private func saveDebts() {
        if let encoded = try? JSONEncoder().encode(debtRecords) {
            UserDefaults.standard.set(encoded, forKey: debtsKey)
        }
    }

    private func loadDebts() {
        if let data = UserDefaults.standard.data(forKey: debtsKey),
           let decoded = try? JSONDecoder().decode([DebtRecord].self, from: data) {
            debtRecords = decoded
        }
    }

    private func loadVenmoUsername() {
        partnerVenmoUsername = UserDefaults.standard.string(forKey: venmoKey) ?? ""
    }
}
