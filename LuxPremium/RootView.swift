import SwiftUI

struct RootView: View {
    @StateObject private var sessionManager = SessionManager()
    @State private var role: String = "CLIENT"
    @State private var isLoadingRole: Bool = false
    @State private var roleErrorMessage: String?

    // --- Variables de Navegación del Broker ---
    @State private var brokerSelectedBaseId: String?
    @State private var brokerSelectedDevelopmentId: String?
    @State private var brokerDetailDestination: BrokerDetailDestination?
    @State private var brokerProposalUnit: PropertyUnit?

    // --- NUEVAS: Variables de Navegación del Cliente ---
    @State private var clientSelectedDevelopmentId: String?
    @State private var clientDetailDestination: ClientDetailDestination?

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
            // Lógica de navegación del Broker (ya la tenías)
            if let brokerSelectedDevelopmentId {
                brokerDevelopmentContent(developmentId: brokerSelectedDevelopmentId)
            } else if let brokerSelectedBaseId {
                BrokerPromotionLotsView(
                    baseId: brokerSelectedBaseId,
                    onBack: { self.brokerSelectedBaseId = nil },
                    onNavigateToDetail: { devId in brokerSelectedDevelopmentId = devId }
                )
            } else {
                BrokerHomeScreen(
                    onLogout: sessionManager.logOut,
                    onNavigateToAssistant: {},
                    onNavigateToLots: { baseId in
                        brokerSelectedDevelopmentId = nil
                        brokerSelectedBaseId = baseId
                    }
                )
            }
        } else {
            // --- Lógica de Navegación del Cliente Corregida ---
            if let devId = clientSelectedDevelopmentId {
                if clientDetailDestination == .documents {
                    // Pantalla de Documentos del Cliente
                    ClientDocumentsScreen(
                        devId: devId,
                        onBack: { clientDetailDestination = nil }
                    )
                } else {
                    // Pantalla de Detalle del Cliente
                    ClientDevelopmentDetailScreen(
                        devId: devId,
                        onBack: { clientSelectedDevelopmentId = nil },
                        onNavigateToDocuments: { clientDetailDestination = .documents },
                        onNavigateToAssistant: { print("Abrir Asistente IA") }
                    )
                }
            } else {
                // Pantalla Home del Cliente
                ZStack(alignment: .top) {
                    ClientHomeScreen(
                        onLogout: { sessionManager.logOut() },
                        onNavigateToAssistant: { print("Ir al asistente IA") },
                        onNavigateToDetail: { propertyId in
                            // Al pulsar la tarjeta, guardamos el ID para navegar
                            self.clientSelectedDevelopmentId = propertyId
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
    }

    private var normalizedRole: String {
        let trimmedRole = role.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedRole.isEmpty ? "CLIENT" : trimmedRole.uppercased()
    }

    // (Aquí va tu función brokerDevelopmentContent que ya tenías...)
    @ViewBuilder
    private func brokerDevelopmentContent(developmentId: String) -> some View {
        if let brokerProposalUnit {
            ProposalScreen(
                devId: developmentId,
                unitId: brokerProposalUnit.id,
                originalPrice: Double(brokerProposalUnit.price),
                typology: brokerProposalUnit.typology,
                onBack: { self.brokerProposalUnit = nil }
            )
        } else if brokerDetailDestination == .documents {
            BrokerDocumentsScreen(devId: developmentId, onBack: { brokerDetailDestination = nil })
        } else if brokerDetailDestination == .contracts {
            BrokerContractsScreen(devId: developmentId, onBack: { brokerDetailDestination = nil })
        } else {
            BrokerDevelopmentDetailScreen(
                devId: developmentId,
                onBack: {
                    brokerDetailDestination = nil
                    brokerProposalUnit = nil
                    brokerSelectedDevelopmentId = nil
                },
                onNavigateToProposal: { unit in brokerProposalUnit = unit },
                onNavigateToDocuments: { brokerDetailDestination = .documents },
                onNavigateToContracts: { brokerDetailDestination = .contracts },
                onNavigateToAssistant: { _ in }
            )
        }
    }

    private func loadRoleIfNeeded() async {
        guard let uid = sessionManager.currentUid else {
            role = "CLIENT"
            isLoadingRole = false
            return
        }
        isLoadingRole = true
        do {
            role = try await authRepository.getUserRole(uid: uid)
        } catch {
            role = "CLIENT"
            roleErrorMessage = error.localizedDescription
        }
        isLoadingRole = false
    }
}

// MARK: - Enums de Destino
private enum BrokerDetailDestination: Equatable {
    case documents, contracts
}

private enum ClientDetailDestination: Equatable {
    case documents
}

// MARK: - Subvistas Auxiliares (Login, Loading, etc.)
private struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    var body: some View { LoginScreen(viewModel: viewModel) }
}

private struct RoleLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView().tint(.white)
                Text("Preparando tu experiencia").foregroundColor(.white)
            }
        }
    }
}

private struct RoleErrorBanner: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.caption)
            .padding()
            .background(Color.red.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
