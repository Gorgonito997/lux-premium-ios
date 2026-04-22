import SwiftUI

struct RootView: View {
    @StateObject private var sessionManager = SessionManager()
    @State private var role: String = "CLIENT"
    @State private var isLoadingRole: Bool = false
    @State private var roleErrorMessage: String?

    // 1. AÑADIMOS LA VARIABLE DEL IDIOMA AQUÍ
    // Esto guarda el idioma en el iPhone y avisa a todas las pantallas si cambia
    @AppStorage("app_language") private var language: String = "es"

    private let authRepository = AuthRepository()

    var body: some View {
        Group {
            if sessionManager.isAuthenticated, let _ = sessionManager.currentUid {

                ClientHomeScreen(
                    onLogout: {
                        // 1. Llama a la función de tu SessionManager para cerrar la sesión en Firebase
                        sessionManager.logOut()
                    },
                    onNavigateToAssistant: {
                        print("Ir al asistente IA")
                    },
                    onNavigateToDetail: { propertyId in
                        print("Navegar a los detalles de la propiedad: \(propertyId)")
                    },
                    viewModel: ClientHomeViewModel()
                )

            } else {
                LoginView()
            }
        }
        // 2. INYECTAMOS EL IDIOMA A TODA LA APP AQUÍ
        // Esto le dice a SwiftUI: "Traduce todo lo que haya dentro del Group a este idioma"
        .environment(\.locale, Locale(identifier: language))
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
