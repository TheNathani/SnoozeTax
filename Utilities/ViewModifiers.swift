import SwiftUI

// MARK: - Glass Morphism Effect
struct GlassMorphism: ViewModifier {
    var blurRadius: CGFloat = 10
    var opacity: Double = 0.15

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(
                Color.white.opacity(opacity)
            )
            .blur(radius: blurRadius)
    }
}

extension View {
    func glassMorphism(blurRadius: CGFloat = 10, opacity: Double = 0.15) -> some View {
        modifier(GlassMorphism(blurRadius: blurRadius, opacity: opacity))
    }
}

// MARK: - Fluid Button Style
struct FluidButtonStyle: ButtonStyle {
    var backgroundColor: Color = .white
    var foregroundColor: Color = .black
    var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    HapticManager.shared.impact(style: hapticStyle)
                }
            }
    }
}

extension View {
    func fluidButtonStyle(
        backgroundColor: Color = .white,
        foregroundColor: Color = .black,
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    ) -> some View {
        buttonStyle(FluidButtonStyle(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            hapticStyle: hapticStyle
        ))
    }
}

// MARK: - Floating Effect
struct FloatingModifier: ViewModifier {
    @State private var isFloating = false

    let duration: Double
    let distance: CGFloat

    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -distance : distance)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    isFloating = true
                }
            }
    }
}

extension View {
    func floating(duration: Double = 2.0, distance: CGFloat = 10) -> some View {
        modifier(FloatingModifier(duration: duration, distance: distance))
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Depth Effect
struct DepthEffect: ViewModifier {
    var depth: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.3), radius: depth, x: 0, y: depth / 2)
            .shadow(color: .black.opacity(0.1), radius: depth * 2, x: 0, y: depth)
    }
}

extension View {
    func depthEffect(_ depth: CGFloat = 10) -> some View {
        modifier(DepthEffect(depth: depth))
    }
}
