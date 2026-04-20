import Foundation

struct AuthUiState {
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var uid: String?
    var role: String?
    var errorMessage: String?

    var isLoggedIn: Bool {
        uid != nil
    }
}
