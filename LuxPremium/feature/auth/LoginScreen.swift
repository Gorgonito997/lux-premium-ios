import SwiftUI

struct LoginScreen: View {
    @ObservedObject var viewModel: LoginViewModel

    @State private var passwordVisible = false
    @State private var selectedRole = "CLIENT"

    var body: some View {
        LuxScreen {
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                hero
                Spacer().frame(height: 16)
                formCard
                Spacer().frame(height: 32)
            }
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .overlay(alignment: .topTrailing) {
            Menu {
                Button("English") { }
                Button("Español") { }
                Button("Português") { }
            } label: {
                LuxToolbarChip(systemImage: "globe")
            }
            .padding(.trailing, 14)
            .padding(.top, 10)
        }
    }

    private var hero: some View {
        VStack(spacing: 0) {
            Image("logotipo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 130)
                .padding(.horizontal, 20)

            Spacer().frame(height: 14)

            Text("ACCESO RESERVADO")
                .foregroundStyle(Color(hex: "E0E0E0"))
                .font(.system(size: 13, weight: .light))
                .tracking(1.2)
        }
    }

    private var formCard: some View {
        LuxPanel(padding: 22) {
            LuxSectionTitle(
                "Iniciar sesion",
                subtitle: "Introduce tus credenciales para continuar"
            )

            Spacer().frame(height: 4)

            fieldLabel("Selecciona el tipo de acceso")

            HStack(spacing: 12) {
                Button("Cliente") {
                    selectedRole = "CLIENT"
                }
                .buttonStyle(LuxRoleButtonStyle(isSelected: selectedRole == "CLIENT"))

                Button("Broker") {
                    selectedRole = "BROKER"
                }
                .buttonStyle(LuxRoleButtonStyle(isSelected: selectedRole == "BROKER"))
            }

            Spacer().frame(height: 8)

            LuxInputField(
                value: $viewModel.state.email,
                label: "Correo electronico",
                keyboardType: .emailAddress
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .disabled(viewModel.state.isLoading)

            LuxInputField(
                value: $viewModel.state.password,
                label: "Contrasena",
                isPassword: true,
                isPasswordVisible: $passwordVisible
            )
            .disabled(viewModel.state.isLoading)

            HStack {
                Spacer()

                Button("¿Olvidaste tu contrasena?") { }
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "CFCFCF"))
                    .padding(.top, 8)
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
                        .tint(.black)
                } else {
                    Text("ENTRAR")
                        .font(.callout)
                        .fontWeight(.semibold)
                }
            }
            .buttonStyle(LuxPrimaryButtonStyle())
            .disabled(viewModel.state.isLoading)

            Button(action: { }) {
                HStack(spacing: 6) {
                    Text("G")
                        .fontWeight(.bold)
                    Text("Continuar con Google")
                        .fontWeight(.semibold)
                }
                .font(.callout)
            }
            .buttonStyle(LuxSecondaryButtonStyle())

            Divider()
                .background(Color(hex: "232323"))

            HStack(spacing: 4) {
                Text("¿No tienes cuenta?")
                    .foregroundStyle(Color(hex: "AFAFAF"))

                Button("Registrate") { }
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color(hex: "BDBDBD"))
            .tracking(0.8)
    }
}

private struct LuxRoleButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(isSelected ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? LuxTheme.accent : LuxTheme.controlFill)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? LuxTheme.accent : Color(hex: "2E2E2E"), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.92 : 1)
    }
}

#Preview {
    LoginScreen(viewModel: LoginViewModel())
}
