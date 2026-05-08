import SwiftUI

struct ClientHomeScreen: View {
    let onLogout: () -> Void
    let onNavigateToAssistant: () -> Void
    let onNavigateToDetail: (String) -> Void

    @StateObject private var viewModel: ClientHomeViewModel

    init(
        onLogout: @escaping () -> Void,
        onNavigateToAssistant: @escaping () -> Void,
        onNavigateToDetail: @escaping (String) -> Void
    ) {
        self.onLogout = onLogout
        self.onNavigateToAssistant = onNavigateToAssistant
        self.onNavigateToDetail = onNavigateToDetail

        // Asumimos que tienes un ClientHomeViewModel creado
        _viewModel = StateObject(wrappedValue: ClientHomeViewModel())
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Fondo oscuro
                Color.black.ignoresSafeArea()

                content

                // Botón flotante de contacto
                PremiumContactFab()
                    .padding(16)
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ÁREA DE CLIENTE") // Sustituto del stringResource R.string.client_home_title
                        .font(.caption)
                        .fontWeight(.semibold)
                        .tracking(1.5)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onLogout) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.white)
                    }
                }
            }
            .task {
                // Equivalente al loadDevelopments de Android
                await viewModel.loadDevelopments()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if let errorMessage = viewModel.errorMessage {
            VStack(spacing: 16) {
                Text(errorMessage)
                    .foregroundColor(.red)

                Button("Reintentar") {
                    Task { await viewModel.loadDevelopments() }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .foregroundColor(.black)
                .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if viewModel.promotions.isEmpty {
            Text("No hay propiedades disponibles") // R.string.broker_home_empty equivalente
                .foregroundColor(.white.opacity(0.6))
                .font(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else {
            ScrollView {
                LazyVStack(spacing: 20) {

                    // HEADER (Textos de bienvenida y Banner IA)
                    headerView

                    // LISTA DE TARJETAS
                    ForEach(viewModel.promotions) { promotion in
                        // Accedemos a la representativa igual que en el código Kotlin
                        let development = promotion.representativeDevelopment

                        DevelopmentCard(
                            title: development.name,
                            location: development.location,
                            price: development.status, // En tu Kotlin pasas el status al parámetro price
                            status: "",
                            id: promotion.baseId,
                            badgeCount: 0,
                            onClick: {
                                onNavigateToDetail(development.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

                Spacer().frame(height: 80) // Espacio para el FAB
            }
        }
    }

    // MARK: - Componente Header (Textos + Banner IA)
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Bienvenido") // R.string.client_home_welcome
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Accede a la información y documentos de tus propiedades.") // R.string.client_home_subtitle
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 8)

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 1)
                .padding(.bottom, 16)

            // --- BANNER GIGANTE DE IA PARA EL CLIENTE ---
            Button(action: onNavigateToAssistant) {
                HStack(spacing: 16) {
                    // Icono IA
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.blue) // Usa el color principal de tu tema
                            .frame(width: 56, height: 56)
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    }

                    // Textos
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Asistente IA")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Consulta rápida de información y dudas.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
                .padding(20)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
}
