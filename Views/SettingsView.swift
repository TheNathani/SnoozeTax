import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var debtTracker: DebtTracker
    @Environment(\.dismiss) var dismiss

    @State private var venmoUsername: String = ""
    @State private var showingSaved = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                // Header
                VStack(spacing: 8) {
                    Text("SETTINGS")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(3)
                }
                .padding(.top, 60)

                Spacer()

                // Venmo username input
                VStack(alignment: .leading, spacing: 16) {
                    Text("Partner's Venmo Username")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1)

                    HStack {
                        Text("@")
                            .font(.system(size: 24, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))

                        TextField("username", text: $venmoUsername)
                            .font(.system(size: 24, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onAppear {
                                venmoUsername = debtTracker.partnerVenmoUsername
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )

                    Text("You'll pay them at the end of each week")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.horizontal, 30)

                // Debt history
                if !debtTracker.debtRecords.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Debt History")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(1)

                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(debtTracker.debtRecords.prefix(10)) { record in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(record.alarmTime)
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                                .foregroundColor(.white)

                                            Text(record.date, style: .date)
                                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                                .foregroundColor(.white.opacity(0.5))
                                        }

                                        Spacer()

                                        Text("$\(String(format: "%.2f", record.amount))")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(record.isPaid ? .green : .red)

                                        if record.isPaid {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.05))
                                    )
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                    }
                    .padding(.horizontal, 30)
                }

                Spacer()

                // Save button
                Button(action: saveSettings) {
                    HStack(spacing: 12) {
                        if showingSaved {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20))
                        }

                        Text(showingSaved ? "Saved!" : "Save")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: .white.opacity(0.2), radius: 15, y: 8)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.shared.impact(style: .light)
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(20)
                    }
                }
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func saveSettings() {
        debtTracker.saveVenmoUsername(venmoUsername)
        HapticManager.shared.notification(type: .success)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showingSaved = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingSaved = false
            }
        }
    }
}
