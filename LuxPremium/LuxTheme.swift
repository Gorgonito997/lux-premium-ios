import SwiftUI

enum LuxTheme {
    static let accent = Color(red: 0.78, green: 0.67, blue: 0.42)
    static let accentStrong = Color(red: 0.62, green: 0.50, blue: 0.26)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)
    static let panelFill = Color.white.opacity(0.14)
    static let panelBorder = Color.white.opacity(0.18)
    static let shadow = Color.black.opacity(0.28)
    static let success = Color(red: 0.43, green: 0.80, blue: 0.59)
    static let warning = Color(red: 0.92, green: 0.68, blue: 0.32)
    static let danger = Color(red: 0.90, green: 0.41, blue: 0.35)
}

struct LuxBackground: View {
    var body: some View {
        ZStack {
            Image("fondo_login")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.30),
                    Color.black.opacity(0.72)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

struct LuxScreen<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            LuxBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    content
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
    }
}

struct LuxPanel<Content: View>: View {
    let padding: CGFloat
    let content: Content

    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LuxTheme.panelFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(LuxTheme.panelBorder, lineWidth: 1)
                )
        )
        .shadow(color: LuxTheme.shadow, radius: 24, x: 0, y: 16)
    }
}

struct LuxSectionTitle: View {
    let eyebrow: String
    let title: String
    let subtitle: String?

    init(_ title: String, eyebrow: String = "", subtitle: String? = nil) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !eyebrow.isEmpty {
                Text(eyebrow.uppercased())
                    .font(.caption.weight(.semibold))
                    .tracking(2)
                    .foregroundStyle(LuxTheme.accent)
            }

            Text(title)
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(LuxTheme.textPrimary)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(LuxTheme.textSecondary)
            }
        }
    }
}

struct LuxImagePlaceholder: View {
    let title: String
    let subtitle: String
    var height: CGFloat = 220

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    LuxTheme.accentStrong.opacity(0.75),
                    Color.black.opacity(0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(LuxTheme.accent)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(LuxTheme.textPrimary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(LuxTheme.textSecondary)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
    }
}

struct LuxInfoPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(1.4)
                .foregroundStyle(LuxTheme.textSecondary)

            Text(value)
                .font(.headline)
                .foregroundStyle(LuxTheme.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.10))
        )
    }
}

struct LuxEmptyState: View {
    let title: String
    let subtitle: String
    var systemImage: String = "sparkles"

    var body: some View {
        LuxPanel {
            VStack(alignment: .center, spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(LuxTheme.accent)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(LuxTheme.textPrimary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(LuxTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct LuxPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.black.opacity(0.84))
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LuxTheme.accent)
            )
            .opacity(configuration.isPressed ? 0.88 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
    }
}

struct LuxSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(LuxTheme.textPrimary)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )
            )
            .opacity(configuration.isPressed ? 0.88 : 1)
    }
}

struct LuxInputModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundStyle(LuxTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
            .tint(LuxTheme.accent)
    }
}

extension View {
    func luxInputStyle() -> some View {
        modifier(LuxInputModifier())
    }
}
