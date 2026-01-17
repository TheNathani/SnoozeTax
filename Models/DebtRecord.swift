import Foundation

struct DebtRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double
    let alarmTime: String
    var isPaid: Bool

    init(id: UUID = UUID(), date: Date = Date(), amount: Double = 1.99, alarmTime: String, isPaid: Bool = false) {
        self.id = id
        self.date = date
        self.amount = amount
        self.alarmTime = alarmTime
        self.isPaid = isPaid
    }
}

struct WeeklyDebt: Identifiable {
    let id = UUID()
    let weekStart: Date
    let weekEnd: Date
    let records: [DebtRecord]

    var totalAmount: Double {
        records.reduce(0) { $0 + $1.amount }
    }

    var formattedAmount: String {
        String(format: "$%.2f", totalAmount)
    }
}
