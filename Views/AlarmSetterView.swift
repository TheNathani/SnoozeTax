import SwiftUI

struct AlarmSetterView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedHour = 7
    @State private var selectedMinute = 0
    @State private var isAM = true
    @State private var showConfirmation = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                // Header
                VStack(spacing: 8) {
                    Text("SET ALARM")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(3)

                    Text(formattedTime)
                        .font(.system(size: 72, weight: .thin, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.top, 60)

                Spacer()

                // Time picker wheels
                HStack(spacing: 0) {
                    // Hour picker
                    Picker("Hour", selection: $selectedHour) {
                        ForEach(1...12, id: \.self) { hour in
                            Text("\(hour)")
                                .font(.system(size: 36, weight: .regular, design: .rounded))
                                .tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    .onChange(of: selectedHour) { _ in
                        HapticManager.shared.selection()
                    }

                    Text(":")
                        .font(.system(size: 48, weight: .thin, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 8)

                    // Minute picker
                    Picker("Minute", selection: $selectedMinute) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text(String(format: "%02d", minute))
                                .font(.system(size: 36, weight: .regular, design: .rounded))
                                .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    .onChange(of: selectedMinute) { _ in
                        HapticManager.shared.selection()
                    }

                    // AM/PM picker
                    Picker("Period", selection: $isAM) {
                        Text("AM")
                            .font(.system(size: 28, weight: .regular, design: .rounded))
                            .tag(true)
                        Text("PM")
                            .font(.system(size: 28, weight: .regular, design: .rounded))
                            .tag(false)
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    .onChange(of: isAM) { _ in
                        HapticManager.shared.selection()
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Set button
                Button(action: setAlarm) {
                    HStack(spacing: 12) {
                        Image(systemName: "alarm.fill")
                            .font(.system(size: 24))

                        Text("Set Alarm")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: .white.opacity(0.3), radius: 20, y: 10)
                    .scaleEffect(showConfirmation ? 0.95 : 1.0)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }

            // Close button
            VStack {
                HStack {
                    Button(action: {
                        HapticManager.shared.impact(style: .light)
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(20)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var formattedTime: String {
        let hour = selectedHour
        let minute = String(format: "%02d", selectedMinute)
        let period = isAM ? "AM" : "PM"
        return "\(hour):\(minute) \(period)"
    }

    private func setAlarm() {
        var hour = selectedHour
        if !isAM && hour != 12 {
            hour += 12
        } else if isAM && hour == 12 {
            hour = 0
        }

        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour
        components.minute = selectedMinute

        if let alarmTime = calendar.date(from: components) {
            var finalTime = alarmTime

            // If the time has already passed today, set it for tomorrow
            if finalTime < Date() {
                finalTime = calendar.date(byAdding: .day, value: 1, to: finalTime) ?? finalTime
            }

            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showConfirmation = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                alarmManager.setAlarm(time: finalTime)
                dismiss()
            }
        }
    }
}
