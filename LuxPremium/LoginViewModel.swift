import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var state = AuthUiState()

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository = AuthRepository()) {
        self.authRepository = authRepository
    }

    func signIn() async {
        let email = state.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = state.password

        guard !email.isEmpty, !password.isEmpty else {
            state.errorMessage = "Introduce email y contrasena."
            return
        }

        state.isLoading = true
        state.errorMessage = nil

        do {
            let uid = try await authRepository.signIn(email: email, password: password)
            state.uid = uid
        } catch {
            state.errorMessage = error.localizedDescription
        }

        state.isLoading = false
    }

    func signOut() {
        do {
            try authRepository.signOut()
            state.uid = nil
            state.role = nil
            state.password = ""
            state.errorMessage = nil
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }
}
