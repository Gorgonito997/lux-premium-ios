import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthRepository {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    func signIn(email: String, password: String) async throws -> String {
        let result = try await auth.signIn(withEmail: email, password: password)
        let uid = result.user.uid
        return uid
    }

    func signOut() throws {
        try auth.signOut()
    }

    func getCurrentUserId() -> String? {
        auth.currentUser?.uid
    }

    func getUserRole(uid: String) async throws -> String {
        let document = try await db.collection("users").document(uid).getDocument()
        return document.get("role") as? String ?? "CLIENT"
    }
}
