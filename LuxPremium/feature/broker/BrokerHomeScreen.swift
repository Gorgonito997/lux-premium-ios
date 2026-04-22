import SwiftUI

struct BrokerHomeScreen: View {
    var onLogout: () -> Void
    var onNavigateToLots: (String) -> Void

    @StateObject private var viewModel: BrokerHomeViewModel

    init(
        onLogout: @escaping () -> Void,
        onNavigateToLots: @escaping (String) -> Void
    ) {
        self.onLogout = onLogout
        self.onNavigateToLots = onNavigateToLots
        _viewModel = StateObject(wrappedValue: BrokerHomeViewModel())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                content
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
        } else if let errorMessage = viewModel.errorMessage {
            BrokerHomeErrorView(
                message: errorMessage,
                onRetry: {
                    Task { await viewModel.loadPromotions() }
                }
            )
            .padding(24)
        } else if viewModel.promotionGroups.isEmpty {
            BrokerHomeEmptyView()
                .padding(24)
        } else {
            ScrollView {
                LazyVStack(spacing: 20) {
                    header

                    ForEach(viewModel.promotionGroups) { group in
                        let coverId = group.developments.first?.id ?? group.baseId

                        DevelopmentCard(
                            title: group.displayName,
                            location: group.location,
                            price: lotsLabel(for: group.developments.count),
                            status: "",
                            id: coverId,
                            badgeCount: 0,
                            onClick: {
                                onNavigateToLots(group.baseId)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Promociones broker")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Consulta las promociones activas y entra al listado de lotes de cada una.")
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer().frame(height: 16)

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 1)

            Spacer().frame(height: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func lotsLabel(for count: Int) -> String {
        count == 1 ? "1 lote disponible" : "\(count) lotes disponibles"
    }
}

private struct BrokerHomeErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 28))
                .foregroundColor(.white)

            Text("No se pudieron cargar las promociones")
                .font(.headline)
                .foregroundColor(.white)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button("Reintentar", action: onRetry)
                .foregroundColor(.black)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct BrokerHomeEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2.crop.circle")
                .font(.system(size: 30))
                .foregroundColor(.white)

            Text("No hay promociones disponibles")
                .font(.headline)
                .foregroundColor(.white)

            Text("Cuando existan promociones visibles para broker apareceran aqui.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    BrokerHomeScreen(
        onLogout: {},
        onNavigateToLots: { _ in }
    )
}
