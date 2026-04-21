import SwiftUI

struct LoginScreen: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        LuxScreen {
            VStack(spacing: 24) {
                hero
                formCard
            }
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
        }
    }

    private var hero: some View {
        VStack(spacing: 18) {
            Image("logotipo")
                .resizable()
                .scaledToFit()
                .frame(width: 148, height: 148)
                .shadow(color: LuxTheme.shadow, radius: 20, x: 0, y: 12)

            VStack(spacing: 10) {
                Text("LuxPremium")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(LuxTheme.textPrimary)

                Text("Acceso privado a promociones, lotes, documentos y seguimiento de obra.")
                    .font(.body)
                    .foregroundStyle(LuxTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var formCard: some View {
        LuxPanel(padding: 24) {
            LuxSectionTitle(
                "Inicia sesion",
                eyebrow: "Bienvenido",
                subtitle: "Mantiene el acceso actual, solo actualizamos el diseno para alinearlo con la identidad visual."
            )

            VStack(alignment: .leading, spacing: 10) {
                fieldLabel("Email")
                TextField("nombre@correo.com", text: $viewModel.state.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .disabled(viewModel.state.isLoading)
                    .luxInputStyle()
            }

            VStack(alignment: .leading, spacing: 10) {
                fieldLabel("Contrasena")
                SecureField("Introduce tu contrasena", text: $viewModel.state.password)
                    .disabled(viewModel.state.isLoading)
                    .luxInputStyle()
            }

            if let errorMessage = viewModel.state.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(LuxTheme.danger)
            }

            Button {
                Task {
                    await viewModel.signIn()
                }
            } label: {
                if viewModel.state.isLoading {
                    ProgressView()
                        .tint(Color.black.opacity(0.84))
                } else {
                    Text("Entrar")
                }
            }
            .buttonStyle(LuxPrimaryButtonStyle())
            .disabled(viewModel.state.isLoading)
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.8)
            .foregroundStyle(LuxTheme.textSecondary)
    }
}

#Preview {
    LoginScreen(viewModel: LoginViewModel())
}
