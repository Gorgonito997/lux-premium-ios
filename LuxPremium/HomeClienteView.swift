import SwiftUI

struct HomeClienteView: View {
    let uid: String
    let role: String
    let isLoadingRole: Bool
    let roleErrorMessage: String?

    private let authRepository = AuthRepository()

    var body: some View {
        VStack(spacing: 16) {
            Text("Home Cliente")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("UID: \(uid)")
                .font(.footnote)
                .multilineTextAlignment(.center)

            if isLoadingRole {
                ProgressView("Cargando role")
            } else {
                Text("Role: \(role)")
                    .font(.footnote)
            }

            if let roleErrorMessage {
                Text(roleErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Cerrar sesion") {
                signOut()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private func signOut() {
        do {
            try authRepository.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    HomeClienteView(
        uid: "preview-uid",
        role: "CLIENT",
        isLoadingRole: false,
        roleErrorMessage: nil
    )
}
