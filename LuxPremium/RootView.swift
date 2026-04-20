import SwiftUI

struct RootView: View {
    @StateObject private var sessionManager = SessionManager()
    @State private var role: String = "CLIENT"
    @State private var isLoadingRole: Bool = false
    @State private var roleErrorMessage: String?

    private let authRepository = AuthRepository()

    var body: some View {
        Group {
            if sessionManager.isAuthenticated, let uid = sessionManager.currentUid {
                HomeClienteView(
                    uid: uid,
                    role: role,
                    isLoadingRole: isLoadingRole,
                    roleErrorMessage: roleErrorMessage
                )
            } else {
                LoginView()
            }
        }
        .task(id: sessionManager.currentUid) {
            await loadRoleIfNeeded()
        }
    }

    private func loadRoleIfNeeded() async {
        guard let uid = sessionManager.currentUid else {
            role = "CLIENT"
            roleErrorMessage = nil
            return
        }

        isLoadingRole = true
        roleErrorMessage = nil

        do {
            role = try await authRepository.getUserRole(uid: uid)
        } catch {
            role = "CLIENT"
            roleErrorMessage = error.localizedDescription
        }

        isLoadingRole = false
    }
}

private struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("LuxPremium")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Inicia sesion")
                .font(.headline)

            TextField("Email", text: $viewModel.state.email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel.state.isLoading)

            SecureField("Contrasena", text: $viewModel.state.password)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel.state.isLoading)

            if let errorMessage = viewModel.state.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                Task {
                    await viewModel.signIn()
                }
            } label: {
                if viewModel.state.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Entrar")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.state.isLoading)
        }
        .frame(maxWidth: 420)
        .padding()
    }
}

#Preview {
    RootView()
}
