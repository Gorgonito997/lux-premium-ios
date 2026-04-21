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
            LuxScreen {
                VStack(spacing: 24) {
                    header

                    if viewModel.isLoading {
                        loadingState(title: "Cargando promociones")
                    } else if let errorMessage = viewModel.errorMessage {
                        errorState(errorMessage)
                    } else if viewModel.promotionGroups.isEmpty {
                        LuxEmptyState(
                            title: "Aun no hay promociones visibles",
                            subtitle: "En cuanto haya promociones publicadas apareceran aqui con el mismo formato visual del acceso.",
                            systemImage: "building.2.crop.circle"
                        )
                    } else {
                        VStack(spacing: 16) {
                            ForEach(viewModel.promotionGroups) { group in
                                NavigationLink {
                                    ClientPromotionLotsView(group: group)
                                } label: {
                                    promotionCard(group)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.loadDevelopments()
            }
        }
    }

    private var header: some View {
        LuxPanel {
            LuxSectionTitle(
                "Promociones",
                eyebrow: "Area cliente",
                subtitle: "Explora las promociones disponibles con la nueva presentacion del area privada."
            )

            HStack(spacing: 12) {
                LuxValueBadge("Cliente: \(shortUid)")
                LuxValueBadge(isLoadingRole ? "Role: Cargando..." : "Role: \(role)")
            }

            if let roleErrorMessage {
                Text(roleErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(LuxTheme.warning)
            }

            Button("Cerrar sesion") {
                signOut()
            }
            .buttonStyle(LuxSecondaryButtonStyle())
        }
    }

    private var shortUid: String {
        String(uid.prefix(10))
    }

    private func promotionCard(_ group: ClientPromotionGroup) -> some View {
        LuxPanel {
            LuxImagePlaceholder(
                title: group.displayName,
                subtitle: "Espacio preparado para la imagen principal de la promocion.",
                height: 168
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(group.displayName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(LuxTheme.textPrimary)

                if !group.location.isEmpty {
                    LuxMetaText(text: group.location)
                }

                LuxMetaText(text: "\(group.developments.count) lotes disponibles")
            }
        }
    }

    private func loadingState(title: String) -> some View {
        LuxPanel {
            VStack(spacing: 16) {
                ProgressView()
                    .tint(LuxTheme.accent)
                    .scaleEffect(1.2)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(LuxTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }
    }

    private func errorState(_ message: String) -> some View {
        LuxPanel {
            VStack(spacing: 14) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(LuxTheme.warning)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(LuxTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
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
