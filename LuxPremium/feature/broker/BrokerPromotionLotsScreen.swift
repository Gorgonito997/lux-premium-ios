import SwiftUI

struct BrokerPromotionLotsScreen: View {
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
            ZStack(alignment: .bottomTrailing) {
                Color.black.ignoresSafeArea()

                content

                PremiumContactFab()
                    .padding(16)
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(baseId.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .tracking(1.5)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if viewModel.developments.isEmpty {
            Text("No hay lotes disponibles")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Todas las unidades")
                            .font(.title2)
                            .foregroundColor(.white)

                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 1)
                    }
                    .padding(.bottom, 8)

                    ForEach(viewModel.developments) { lot in
                        LotItem(lot: lot, onClick: {
                            onNavigateToDetail(lot.id)
                        })
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
    }
}
// MARK: - Componente Fila de Lote

struct LotItem: View {
    let lot: Development
    let onClick: () -> Void

    private var cleanId: String {
        let parts = lot.id.components(separatedBy: "_")
        guard let lastPart = parts.last else { return lot.id }

        if lastPart.lowercased().hasPrefix("lote") {
            let number = lastPart.dropFirst(4)
            return "Lote \(number)"
        }
        return lot.id
    }

    var body: some View {
        Button(action: onClick) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(cleanId)
                        .font(.caption)
                        .fontWeight(.bold)
                        .tracking(1)
                        .foregroundColor(.blue) // Cambiar al color primary de tu tema

                    Text(lot.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text(lot.location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                HStack(spacing: 12) {
                    LotStatusBadge(status: lot.status)

                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue.opacity(0.7))
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(20)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Componente Etiqueta de Estado

struct LotStatusBadge: View {
    let status: String

    var body: some View {
        let info = getStatusInfo(status)

        Text(info.label.uppercased())
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(info.backgroundColor)
            .foregroundColor(info.textColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(info.textColor.opacity(0.2), lineWidth: 1)
            )
    }

    private func getStatusInfo(_ status: String) -> (label: String, textColor: Color, backgroundColor: Color) {
        switch status.lowercased() {
        case "available":
            return ("DISPONÍVEL", Color(hex: 0x81C784), Color(hex: 0x1B5E20).opacity(0.1))
        case "reserved":
            return ("RESERVADO", Color(hex: 0xFFFFB74D), Color(hex: 0xE65100).opacity(0.1))
        case "sold":
            return ("VENDIDO", Color(hex: 0xE57373), Color(hex: 0xB71C1C).opacity(0.1))
        default:
            return (status, .gray, .gray.opacity(0.1))
        }
    }
}
