import SwiftUI

struct RootView: View {
    @StateObject private var sessionManager = SessionManager()
    @State private var role: String = "CLIENT"
    @State private var isLoadingRole: Bool = false
    @State private var roleErrorMessage: String?

    private let authRepository = AuthRepository()

    var body: some View {
        Group {
            if sessionManager.isAuthenticated, let _ = sessionManager.currentUid {

                // --- AQUÍ ESTÁ EL CAMBIO PRINCIPAL ---
                ClientHomeScreen(
                    onLogout: {
                        // Aquí llamaremos a la función de cerrar sesión de tu SessionManager
                        // sessionManager.signOut()
                        print("Cerrar sesión presionado")
                    },
                    onNavigateToAssistant: {
                        print("Ir al asistente IA")
                    },
                    onNavigateToDetail: { propertyId in
                        print("Navegar a los detalles de la propiedad: \(propertyId)")
                    },
                    viewModel: ClientHomeViewModel()
                )
                // -------------------------------------

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
