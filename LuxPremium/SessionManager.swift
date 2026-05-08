import Foundation
import Combine
import FirebaseAuth

@MainActor
final class SessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUid: String?

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

    func logOut() {
        do {
            try Auth.auth().signOut()
            currentUid = nil
            isAuthenticated = false
        } catch {
            currentUid = Auth.auth().currentUser?.uid
            isAuthenticated = currentUid != nil
        }
    }

    deinit {
        if let authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }
}
