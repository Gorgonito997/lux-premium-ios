import SwiftUI

struct BrokerHomeScreen: View {
    let onLogout: () -> Void
    let onNavigateToAssistant: () -> Void
    let onNavigateToLots: (String) -> Void

    @StateObject private var viewModel: BrokerHomeViewModel

    init(
        onLogout: @escaping () -> Void,
        onNavigateToAssistant: @escaping () -> Void,
        onNavigateToLots: @escaping (String) -> Void
    ) {
        self.onLogout = onLogout
        self.onNavigateToAssistant = onNavigateToAssistant
        self.onNavigateToLots = onNavigateToLots
        // Asumimos que ya tienes tu BrokerHomeViewModel creado
        _viewModel = StateObject(wrappedValue: BrokerHomeViewModel())
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
                    Text("BROKER DESK")
                        .font(.system(size: 13, weight: .bold))
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
                if viewModel.promotionGroups.isEmpty {
                    await viewModel.loadPromotions()
                }
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
                Text("Error al cargar las promociones")
                    .foregroundColor(.red)

                Button("Reintentar") {
                    Task { await viewModel.loadPromotions() }
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if viewModel.promotionGroups.isEmpty {
            Text("No hay promociones disponibles")
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else {
            ScrollView {
                LazyVStack(spacing: 20) {

                    // HEADER (Título y Banner IA)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Promociones broker")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 1)

                        Spacer().frame(height: 16)

                        // BANNER DEL ASISTENTE IA
                        Button(action: onNavigateToAssistant) {
                            HStack(spacing: 16) {
                                // Icono IA
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.blue) // Reemplaza por tu color primario
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

                                    Text("Consulta rápida de información y dudas sobre las promociones.")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
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

                    // LISTA DE PROMOCIONES
                    ForEach(viewModel.promotionGroups) { group in
                        let count = group.developments.count
                        let coverId = group.developments.first?.id ?? group.baseId

                        DevelopmentCard(
                            title: group.displayName,
                            location: group.location,
                            price: lotsLabel(for: count),
                            status: "",
                            id: coverId,
                            badgeCount: 0,
                            onClick: {
                                // Aquí puedes llamar también a viewModel.onPromotionClicked(group) si lo necesitas
                                onNavigateToLots(group.baseId)
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

    private func lotsLabel(for count: Int) -> String {
        count == 1 ? "1 lote disponible" : "\(count) lotes disponibles"
    }
}
