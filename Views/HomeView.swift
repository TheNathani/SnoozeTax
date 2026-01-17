import SwiftUI

struct HomeView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @EnvironmentObject var debtTracker: DebtTracker

    @Binding var showingAlarmSetter: Bool
    @Binding var showingSettings: Bool

    @State private var timeScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Debt glow background
            if debtTracker.totalUnpaidDebt > 0 {
                DebtGlowView(amount: debtTracker.totalUnpaidDebt)
            }

            VStack(spacing: 0) {
                Spacer()

                // Main alarm time display
                if let alarm = alarmManager.currentAlarm {
                    VStack(spacing: 12) {
                        Text(alarm.formattedTime)
                            .font(.system(size: 88, weight: .thin, design: .rounded))
                            .foregroundColor(.white)
                            .scaleEffect(timeScale)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                    timeScale = 1.05
                                }
                            }

                        Text("NEXT ALARM")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(3)

                        // Delete alarm button
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                alarmManager.deleteAlarm()
                            }
                        }) {
                            Text("Delete")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.red.opacity(0.7))
                                .padding(.top, 20)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.white.opacity(0.3))

                        Text("No alarm set")
                            .font(.system(size: 24, weight: .thin, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))

                        Text("Swipe up to set")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))
                            .tracking(2)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // Debt counter
                if debtTracker.totalUnpaidDebt > 0 {
                    PaymentBanner()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.bottom, 40)

            // Settings button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.shared.impact(style: .light)
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.3))
                            .padding(20)
                    }
                }
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { gesture in
                    if gesture.translation.height < -50 {
                        HapticManager.shared.impact(style: .medium)
                        showingAlarmSetter = true
                    }
                }
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: alarmManager.currentAlarm)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: debtTracker.totalUnpaidDebt)
    }
}

struct PaymentBanner: View {
    @EnvironmentObject var debtTracker: DebtTracker

    var body: some View {
        VStack(spacing: 12) {
            Text("YOU OWE")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.red.opacity(0.6))
                .tracking(2)

            Text("$\(String(format: "%.2f", debtTracker.totalUnpaidDebt))")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.red)

            if let weekDebt = debtTracker.currentWeekDebt, weekDebt.totalAmount > 0 {
                Button(action: {
                    debtTracker.openVenmoPayment()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "creditcard.fill")
                        Text("Pay \(debtTracker.partnerVenmoUsername.isEmpty ? "Partner" : debtTracker.partnerVenmoUsername)")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .red.opacity(0.5), radius: 20, y: 10)
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}
