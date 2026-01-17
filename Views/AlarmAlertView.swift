import SwiftUI

struct AlarmAlertView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @EnvironmentObject var debtTracker: DebtTracker

    @State private var pulseAnimation = false
    @State private var glowIntensity: CGFloat = 0.0

    var body: some View {
        ZStack {
            // Intense red background pulse
            RadialGradient(
                colors: [
                    Color.red.opacity(glowIntensity * 0.4),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 500
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    glowIntensity = 1.0
                }
            }

            VStack(spacing: 0) {
                Spacer()

                // Alarm time
                if let alarm = alarmManager.currentAlarm {
                    VStack(spacing: 16) {
                        Image(systemName: "alarm.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.white)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)

                        Text(alarm.formattedTime)
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("WAKE UP")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(5)
                    }
                    .padding(.bottom, 60)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            pulseAnimation = true
                        }
                    }
                }

                Spacer()

                // Buttons
                VStack(spacing: 20) {
                    // Wake Up button
                    Button(action: {
                        HapticManager.shared.stopAlarmHaptics()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            alarmManager.dismissAlarm()
                        }
                    }) {
                        Text("Wake Up")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .green.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: .green.opacity(0.6), radius: 30, y: 15)
                    }

                    // Snooze button (conditional)
                    if let alarm = alarmManager.currentAlarm, alarm.canSnooze {
                        Button(action: {
                            HapticManager.shared.stopAlarmHaptics()
                            debtTracker.addSnoozeDebt(alarmTime: alarm.formattedTime)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                alarmManager.snoozeAlarm()
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text("Snooze")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))

                                Text("9 min - $1.99")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .opacity(0.8)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        LinearGradient(
                                            colors: [.red, .red.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: .red.opacity(0.6), radius: 30, y: 15)
                        }
                    } else {
                        // Max snoozes reached
                        VStack(spacing: 8) {
                            Text("No more snoozes!")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.red.opacity(0.6))

                            Text("You've hit the limit")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 2)
                                )
                        )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 60)
            }
        }
    }
}
