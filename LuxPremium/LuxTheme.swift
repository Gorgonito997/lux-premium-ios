import SwiftUI
import UIKit

enum LuxTheme {
    static let accent = Color(hex: "EDEDED")
    static let accentStrong = Color(hex: "CFCFCF")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "BDBDBD")
    static let mutedText = Color(hex: "9E9E9E")
    static let panelFill = Color(hex: "111111").opacity(0.55)
    static let panelBorder = Color(hex: "383838")
    static let controlFill = Color(hex: "181818").opacity(0.8)
    static let controlBorder = Color(hex: "383838")
    static let shadow = Color.black.opacity(0.22)
    static let success = Color(hex: "A8E6B0")
    static let warning = Color(hex: "F1C27D")
    static let danger = Color(hex: "F19999")
}

struct LuxBackground: View {
    var body: some View {
        ZStack {
            Image("fondo_login")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.10)
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
                .padding(.horizontal, 24)
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
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LuxTheme.panelFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(LuxTheme.panelBorder, lineWidth: 1)
                )
        )
        .shadow(color: LuxTheme.shadow, radius: 20, x: 0, y: 10)
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
                    .font(.system(size: 12, weight: .medium))
                    .tracking(0.8)
                    .foregroundStyle(LuxTheme.textSecondary)
            }

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(LuxTheme.textPrimary)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(LuxTheme.mutedText)
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
                    Color(hex: "202020").opacity(0.82),
                    Color.black.opacity(0.62)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(Color(hex: "CCCCCC"))

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
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(LuxTheme.controlBorder, lineWidth: 1)
        )
    }
}

struct LuxMetaText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(LuxTheme.textSecondary)
    }
}

struct LuxValueBadge: View {
    let text: String
    let inverted: Bool

    init(_ text: String, inverted: Bool = false) {
        self.text = text
        self.inverted = inverted
    }

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(inverted ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(inverted ? LuxTheme.accent : LuxTheme.controlFill)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(inverted ? LuxTheme.accent : LuxTheme.controlBorder, lineWidth: 1)
            )
    }
}

struct LuxToolbarChip: View {
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .foregroundStyle(.white)
            .padding(10)
            .background(Color(hex: "141414").opacity(0.8))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "2A2A2A"), lineWidth: 1)
            )
    }
}

struct LuxInputField: View {
    @Binding var value: String
    var label: String
    var keyboardType: UIKeyboardType = .default
    var isPassword: Bool = false
    var isPasswordVisible: Binding<Bool>? = nil

    var body: some View {
        ZStack(alignment: .leading) {
            if value.isEmpty {
                Text(label)
                    .foregroundStyle(LuxTheme.textSecondary)
                    .padding(.horizontal, 16)
            }

            HStack {
                if isPassword, let visible = isPasswordVisible {
                    if visible.wrappedValue {
                        TextField("", text: $value)
                            .foregroundStyle(.white)
                            .keyboardType(keyboardType)
                            .submitLabel(.done)
                    } else {
                        SecureField("", text: $value)
                            .foregroundStyle(.white)
                            .submitLabel(.done)
                    }

                    Button(action: { visible.wrappedValue.toggle() }) {
                        Image(systemName: visible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(Color(hex: "CCCCCC"))
                    }
                } else {
                    TextField("", text: $value)
                        .foregroundStyle(.white)
                        .keyboardType(keyboardType)
                        .submitLabel(.next)
                }
            }
            .padding()
        }
        .background(LuxTheme.controlFill)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(LuxTheme.controlBorder, lineWidth: 1)
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
                    .foregroundStyle(Color(hex: "CCCCCC"))

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
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white)
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
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LuxTheme.controlFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(LuxTheme.controlBorder, lineWidth: 1)
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
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LuxTheme.controlFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(LuxTheme.controlBorder, lineWidth: 1)
                    )
            )
            .tint(.white)
    }
}

extension View {
    func luxInputStyle() -> some View {
        modifier(LuxInputModifier())
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64

        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
