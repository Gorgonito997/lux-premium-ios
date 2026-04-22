import SwiftUI

struct ClientHomeScreen: View {
    // Callbacks de navegación
    var onLogout: () -> Void
    var onNavigateToAssistant: () -> Void
    var onNavigateToDetail: (String) -> Void

    // Tu ViewModel real
    @ObservedObject var viewModel: ClientHomeViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                // --- GESTIÓN DE ESTADOS ---
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color.accentColor)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Text(errorMessage)
                            .foregroundColor(.red)

                        // ¡El botón ahora soporta funciones async!
                        Button("Reintentar") {
                            Task {
                                await viewModel.loadDevelopments()
                            }
                        }
                    }
                    .padding(24)
                } else if viewModel.promotionGroups.isEmpty { // <--- CORREGIDO AQUÍ
                    Text("No hay promociones disponibles")
                        .font(.body)
                        .foregroundColor(Color(UIColor.label).opacity(0.6))
                } else {
                    // --- LISTA PRINCIPAL ---
                    ScrollView {
                        LazyVStack(spacing: 20) {

                            // Cabecera estática
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Bienvenido,")
                                    .font(.title2)
                                    .foregroundColor(Color(UIColor.label))

                                Spacer().frame(height: 8)

                                Text("Encuentra tu próximo hogar exclusivo")
                                    .font(.body)
                                    .foregroundColor(Color(UIColor.label).opacity(0.6))

                                Spacer().frame(height: 16)

                                Rectangle()
                                    .fill(Color(UIColor.separator).opacity(0.3))
                                    .frame(width: 40, height: 1)

                                Spacer().frame(height: 24)

                                // --- BANNER GIGANTE DE IA ---
                                Button(action: onNavigateToAssistant) {
                                    HStack(spacing: 16) {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.accentColor)
                                            .frame(width: 56, height: 56)
                                            .overlay(
                                                Image(systemName: "sparkles")
                                                    .foregroundColor(.white)
                                            )

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Asistente Lux")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color(UIColor.label))

                                            Text("Pregúntame lo que necesites")
                                                .font(.subheadline)
                                                .foregroundColor(Color(UIColor.label).opacity(0.7))
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                        }
                                        Spacer()
                                    }
                                    .padding(20)
                                }
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                )
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            // Tarjetas de propiedades (CORREGIDO AQUÍ TAMBIÉN)
                            ForEach(viewModel.promotionGroups, id: \.baseId) { group in
                                let development = group.representativeDevelopment

                                DevelopmentCard(
                                    title: development.name,
                                    location: development.location,
                                    price: development.status,
                                    status: "",
                                    id: development.id,
                                    badgeCount: 0,
                                    onClick: {
                                        onNavigateToDetail(development.id)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }
                }
            }
            // --- TopAppBar ---
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("INICIO CLIENTE")
                        .font(.system(size: 14, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(Color(UIColor.label))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onLogout) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(Color(UIColor.label))
                    }
                }
            }
            // --- FloatingActionButton ---
            .overlay(alignment: .bottomTrailing) {
                PremiumContactFab()
                    .padding(16)
            }
            // --- DISPARADOR INICIAL (Carga los datos automáticamente) ---
            .task {
                if viewModel.promotionGroups.isEmpty {
                    await viewModel.loadDevelopments()
                }
            }
        }
    }
}
