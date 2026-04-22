import SwiftUI

struct BrokerPromotionLotsView: View {
    let baseId: String
    let onBack: () -> Void
    let onNavigateToDetail: (String) -> Void

    @StateObject private var viewModel: BrokerPromotionLotsViewModel

    init(
        baseId: String,
        onBack: @escaping () -> Void,
        onNavigateToDetail: @escaping (String) -> Void
    ) {
        self.baseId = baseId
        self.onBack = onBack
        self.onNavigateToDetail = onNavigateToDetail
        _viewModel = StateObject(wrappedValue: BrokerPromotionLotsViewModel())
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
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Promociones")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .task(id: baseId) {
                await viewModel.loadLots(baseId: baseId)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.white)
        } else if let errorMessage = viewModel.errorMessage {
            BrokerLotsErrorView(
                message: errorMessage,
                onRetry: {
                    Task { await viewModel.loadLots(baseId: baseId) }
                }
            )
            .padding(24)
        } else if viewModel.developments.isEmpty {
            BrokerLotsEmptyView(baseId: baseId)
                .padding(24)
        } else {
            ScrollView {
                LazyVStack(spacing: 20) {
                    header

                    ForEach(viewModel.developments) { development in
                        DevelopmentCard(
                            title: displayLotTitle(for: development),
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
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Lotes de la promoción")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(baseId)
                .font(.headline)
                .foregroundColor(.gray)

            Spacer().frame(height: 16)

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 1)

            Spacer().frame(height: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func displayLotTitle(for development: Development) -> String {
        let trimmedName = development.name.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedName.isEmpty {
            return trimmedName
        }

        return development.id
    }
}

private struct BrokerLotsErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 28))
                .foregroundColor(.white)

            Text("No se pudieron cargar los lotes")
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

private struct BrokerLotsEmptyView: View {
    let baseId: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 30))
                .foregroundColor(.white)

            Text("No hay lotes disponibles")
                .font(.headline)
                .foregroundColor(.white)

            Text("La promoción \(baseId) no tiene lotes visibles en este momento.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    BrokerPromotionLotsView(
        baseId: "promo-preview",
        onBack: {},
        onNavigateToDetail: { _ in }
    )
}
