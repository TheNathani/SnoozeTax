import Foundation

struct Alarm: Identifiable, Codable {
    let id: UUID
    var time: Date
    var isEnabled: Bool
    var snoozeCount: Int
    var lastSnoozeDate: Date?

    init(id: UUID = UUID(), time: Date, isEnabled: Bool = true, snoozeCount: Int = 0) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.snoozeCount = snoozeCount
    }

    var canSnooze: Bool {
        return snoozeCount < 3
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}
