import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AppUser {
    let id: String
    let role: String
    let personalDriveFolderUrl: String?
}

final class AuthRepository {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    func signIn(email: String, password: String) async throws -> String {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let result = try await auth.signIn(withEmail: normalizedEmail, password: password)
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

    func getCurrentUserProfile() async throws -> AppUser? {
            guard let uid = auth.currentUser?.uid else { return nil }

            let document = try await db.collection("users").document(uid).getDocument()

            let role = document.get("role") as? String ?? "CLIENT"
            let personalDriveFolderUrl = document.get("personalDriveFolderUrl") as? String

            return AppUser(
                id: uid,
                role: role,
                personalDriveFolderUrl: personalDriveFolderUrl
            )
        }
}
