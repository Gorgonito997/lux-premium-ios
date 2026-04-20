import SwiftUI

struct HomeClienteView: View {
    let uid: String
    let role: String
    let isLoadingRole: Bool
    let roleErrorMessage: String?

    @StateObject private var viewModel = ClientHomeViewModel()

    private let authRepository = AuthRepository()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                header

                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Cargando promociones")
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else if viewModel.promotionGroups.isEmpty {
                    Spacer()
                    Text("No hay promociones disponibles.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    List(viewModel.promotionGroups) { group in
                        NavigationLink {
                            ClientPromotionLotsView(group: group)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(group.displayName)
                                    .font(.headline)

                                Text(group.location)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text("Lotes: \(group.developments.count)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .task {
                await viewModel.loadDevelopments()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Promociones")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                Button("Cerrar sesion") {
                    signOut()
                }
                .buttonStyle(.bordered)
            }

            Text("UID: \(uid)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if isLoadingRole {
                ProgressView("Cargando role")
            } else {
                Text("Role: \(role)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let roleErrorMessage {
                Text(roleErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
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
