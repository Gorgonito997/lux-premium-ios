import Foundation
import Combine
import FirebaseAuth

@MainActor
final class SessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUid: String? = nil

    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenAuthState()
    }

    private func listenAuthState() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUid = user?.uid
                self?.isAuthenticated = user != nil
            }
        }
    }

    deinit {
        if let authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }

        func logOut() {
            do {
                try Auth.auth().signOut()
                // Al hacer esto, Firebase avisará al "listener" y
                // isAuthenticated se pondrá en false automáticamente.
            } catch {
                print("Error al cerrar sesión: \(error.localizedDescription)")
            }
        }
}
