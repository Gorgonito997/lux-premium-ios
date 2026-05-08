import SwiftUI

struct RootView: View {
    @StateObject private var sessionManager = SessionManager()
    @State private var role: String = "CLIENT"
    @State private var isLoadingRole: Bool = false
    @State private var roleErrorMessage: String?
    @State private var brokerSelectedBaseId: String?
    @State private var brokerSelectedDevelopmentId: String?
    @State private var brokerDetailDestination: BrokerDetailDestination?
    @State private var brokerProposalUnit: PropertyUnit?

    @AppStorage("app_language") private var language: String = "es"

    private let authRepository = AuthRepository()

    var body: some View {
        Group {
            if sessionManager.isAuthenticated, sessionManager.currentUid != nil {
                authenticatedContent
            } else {
                LoginView()
            }
        }
        .environment(\.locale, Locale(identifier: language))
        .task(id: sessionManager.currentUid) {
            await loadRoleIfNeeded()
        }
    }

    @ViewBuilder
    private var authenticatedContent: some View {
        if isLoadingRole {
            RoleLoadingView()
        } else if normalizedRole == "BROKER" {
            if let brokerSelectedDevelopmentId {
                brokerDevelopmentContent(developmentId: brokerSelectedDevelopmentId)
            } else if let brokerSelectedBaseId {
                BrokerPromotionLotsView(
                    baseId: brokerSelectedBaseId,
                    onBack: {
                        self.brokerSelectedBaseId = nil
                    },
                    onNavigateToDetail: { developmentId in
                        brokerSelectedDevelopmentId = developmentId
                    }
                )
            } else {
                BrokerHomeScreen(
                    onLogout: sessionManager.logOut,
                    onNavigateToAssistant: {},
                    onNavigateToLots: { baseId in
                        brokerSelectedDevelopmentId = nil
                        brokerDetailDestination = nil
                        brokerProposalUnit = nil
                        brokerSelectedBaseId = baseId
                    }
                )
            }
        } else {
            ZStack(alignment: .top) {
                ClientHomeScreen(
                    onLogout: {
                        sessionManager.logOut()
                    },
                    onNavigateToAssistant: {
                        print("Ir al asistente IA")
                    },
                    onNavigateToDetail: { propertyId in
                        print("Navegar a los detalles de la propiedad: \(propertyId)")
                    }
                )

                if let roleErrorMessage, !roleErrorMessage.isEmpty {
                    RoleErrorBanner(message: roleErrorMessage)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }
            }
        }
    }

    private var normalizedRole: String {
        let trimmedRole = role.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedRole.isEmpty ? "CLIENT" : trimmedRole.uppercased()
    }

    @ViewBuilder
    private func brokerDevelopmentContent(developmentId: String) -> some View {
        if let brokerProposalUnit {
            ProposalScreen(
                devId: developmentId,
                unitId: brokerProposalUnit.id,
                originalPrice: Double(brokerProposalUnit.price),
                typology: brokerProposalUnit.typology,
                onBack: {
                    self.brokerProposalUnit = nil
                }
            )
        } else if brokerDetailDestination == .documents {
            BrokerDocumentsScreen(
                devId: developmentId,
                onBack: {
                    brokerDetailDestination = nil
                }
            )
        } else if brokerDetailDestination == .contracts {
            BrokerContractsScreen(
                devId: developmentId,
                onBack: {
                    brokerDetailDestination = nil
                }
            )
        } else {
            BrokerDevelopmentDetailScreen(
                devId: developmentId,
                onBack: {
                    brokerDetailDestination = nil
                    brokerProposalUnit = nil
                    brokerSelectedDevelopmentId = nil
                },
                onNavigateToProposal: { unit in
                    brokerProposalUnit = unit
                },
                onNavigateToDocuments: {
                    brokerDetailDestination = .documents
                },
                onNavigateToContracts: {
                    brokerDetailDestination = .contracts
                },
                onNavigateToAssistant: { _ in }
            )
        }
    }

    private func loadRoleIfNeeded() async {
        guard let uid = sessionManager.currentUid else {
            role = "CLIENT"
            isLoadingRole = false
            roleErrorMessage = nil
            brokerSelectedBaseId = nil
            brokerSelectedDevelopmentId = nil
            brokerDetailDestination = nil
            brokerProposalUnit = nil
            return
        }

        isLoadingRole = true
        roleErrorMessage = nil
        brokerSelectedBaseId = nil
        brokerSelectedDevelopmentId = nil
        brokerDetailDestination = nil
        brokerProposalUnit = nil

        do {
            role = try await authRepository.getUserRole(uid: uid)
        } catch {
            role = "CLIENT"
            roleErrorMessage = error.localizedDescription
        }

        isLoadingRole = false
    }
}

private enum BrokerDetailDestination: Equatable {
    case documents
    case contracts
}

private struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        LoginScreen(viewModel: viewModel)
    }
}

private struct RoleLoadingView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.1)

                Text("Preparando tu experiencia")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Estamos validando tu perfil de acceso.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(24)
        }
    }
}

private struct RoleErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)

            Text("No se pudo cargar el rol. Se ha abierto el flujo cliente. \(message)")
                .font(.footnote)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, y: 4)
    }
}

#Preview {
    RootView()
}
