import SwiftUI

struct ClientHomeScreen: View {
    var onLogout: () -> Void
    var onNavigateToAssistant: () -> Void
    var onNavigateToDetail: (String) -> Void

    @ObservedObject var viewModel: ClientHomeViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo Negro Puro
                Color.black.ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Text(errorMessage).foregroundColor(.red)
                        Button("Reintentar") {
                            Task { await viewModel.loadDevelopments() }
                        }
                        .foregroundColor(.white)
                    }
                    .padding(24)
                } else if viewModel.promotionGroups.isEmpty {
                    Text("No hay promociones disponibles")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {

                            // --- CABECERA ---
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Bienvenido a Lux Premium")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                Text("Descubre nuestras promociones más selectas.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Spacer().frame(height: 16)

                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 1)

                                Spacer().frame(height: 24)

                                // --- BANNER ASISTENTE IA ---
                                Button(action: onNavigateToAssistant) {
                                    HStack(spacing: 16) {
                                        // Icono blanco con destellos negros
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.white)
                                            .frame(width: 56, height: 56)
                                            .overlay(
                                                Image(systemName: "sparkles")
                                                    .foregroundColor(.black)
                                                    .font(.system(size: 24))
                                            )

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Asistente IA")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)

                                            Text("Pregunta por esta promoción, la unidad o los siguientes pasos")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                        }
                                        Spacer()
                                    }
                                    .padding(20)
                                }
                                .background(Color(white: 0.12)) // Gris muy oscuro
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            // --- TARJETAS ---
                            ForEach(viewModel.promotionGroups) { group in
                                let firstDev = group.developments.first

                                DevelopmentCard(
                                    title: group.displayName,
                                    location: group.location,
                                    price: firstDev?.status ?? "",
                                    status: "",
                                    id: firstDev?.id ?? group.baseId,
                                    badgeCount: 0,
                                    onClick: {
                                        if let devId = firstDev?.id {
                                            onNavigateToDetail(devId)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            // Forzamos que la barra superior sea negra con texto blanco
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("CATÁLOGO EXCLUSIVO")
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
            .overlay(alignment: .bottomTrailing) {
                PremiumContactFab()
                    .padding(20)
            }
            .task {
                if viewModel.promotionGroups.isEmpty {
                    await viewModel.loadDevelopments()
                }
            }
        }
    }
}
