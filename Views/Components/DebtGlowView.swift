import SwiftUI

struct DebtGlowView: View {
    let amount: Double

    @State private var pulseAnimation = false
    @State private var rotationAnimation: Double = 0

    var glowIntensity: Double {
        min(amount / 50.0, 1.0) // Max intensity at $50
    }

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.red.opacity(glowIntensity * 0.3),
                            Color.red.opacity(glowIntensity * 0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 100,
                        endRadius: 400
                    )
                )
                .frame(width: 800, height: 800)
                .scaleEffect(pulseAnimation ? 1.1 : 0.9)
                .blur(radius: 50)

            // Inner pulsing glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.red.opacity(glowIntensity * 0.4),
                            Color.red.opacity(glowIntensity * 0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .scaleEffect(pulseAnimation ? 0.9 : 1.1)
                .blur(radius: 40)

            // Rotating ambient light
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.red.opacity(glowIntensity * 0.2),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 600, height: 600)
                    .blur(radius: 60)
                    .rotationEffect(.degrees(rotationAnimation + Double(index * 120)))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }

            withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
                rotationAnimation = 360
            }
        }
    }
}
