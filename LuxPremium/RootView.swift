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
        LoginScreen(viewModel: viewModel)
    }
}

#Preview {
    RootView()
}
