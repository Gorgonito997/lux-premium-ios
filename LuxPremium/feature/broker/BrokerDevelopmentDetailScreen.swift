import SwiftUI

struct BrokerDevelopmentDetailScreen: View {
    let devId: String
    let onBack: () -> Void
    let onNavigateToProposal: (PropertyUnit) -> Void
    let onNavigateToDocuments: () -> Void
    let onNavigateToContracts: () -> Void
    let onNavigateToAssistant: (PropertyUnit?) -> Void

    @StateObject private var viewModel: BrokerDevelopmentDetailViewModel

    init(
        devId: String,
        onBack: @escaping () -> Void,
        onNavigateToProposal: @escaping (PropertyUnit) -> Void,
        onNavigateToDocuments: @escaping () -> Void,
        onNavigateToContracts: @escaping () -> Void,
        onNavigateToAssistant: @escaping (PropertyUnit?) -> Void
    ) {
        self.devId = devId
        self.onBack = onBack
        self.onNavigateToProposal = onNavigateToProposal
        self.onNavigateToDocuments = onNavigateToDocuments
        self.onNavigateToContracts = onNavigateToContracts
        self.onNavigateToAssistant = onNavigateToAssistant
        _viewModel = StateObject(wrappedValue: BrokerDevelopmentDetailViewModel(devId: devId))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Fondo base
                Color.black.ignoresSafeArea()

                content

                // FAB Overlay
                PremiumContactFab()
                    .padding(16)
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                }
            }
            .task {
                await viewModel.loadData()
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
        } else if let development = viewModel.development {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Imagen de cabecera
                    if !development.coverImageUrl.isEmpty {
                        AsyncImage(url: URL(string: development.coverImageUrl.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(2.0, contentMode: .fill)
                            } else {
                                Color.gray.opacity(0.3).aspectRatio(2.0, contentMode: .fill)
                            }
                        }
                        .clipped()
                    }

                    // Contenido principal de la promoción
                    VStack(alignment: .leading, spacing: 16) {
                        Text(development.name)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Text(development.location)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))

                        Spacer().frame(height: 8)

                        // Botón Asistente IA Promoción
                        Button(action: { onNavigateToAssistant(nil) }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Asistente IA")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.blue.opacity(0.12)) // Reemplaza Color.blue por el de tu tema si es distinto
                            .foregroundColor(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                            )
                        }

                        Spacer().frame(height: 0)

                        // Tarjetas de Documentos y Contratos
                        HStack(spacing: 12) {
                            PremiumCompactActionCard(
                                title: "Documentos",
                                icon: "doc.text.fill",
                                onClick: onNavigateToDocuments
                            )
                            PremiumCompactActionCard(
                                title: "Contratos",
                                icon: "hammer.fill",
                                onClick: onNavigateToContracts
                            )
                        }

                        // Banco de imágenes (Si hay URL)
                        if !development.driveImagesFolderUrl.isEmpty {
                            Spacer().frame(height: 0)
                            PremiumCompactActionCard(
                                title: "Ver banco de imágenes",
                                icon: "photo.fill",
                                onClick: {
                                    if let url = URL(string: development.driveImagesFolderUrl.trimmingCharacters(in: .whitespacesAndNewlines)) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                        }

                        Spacer().frame(height: 16)

                        Text("TODAS LAS UNIDADES")
                            .font(.caption)
                            .fontWeight(.bold)
                            .tracking(1.2)
                            .foregroundColor(.white)

                        Spacer().frame(height: 0)

                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 1)

                        Spacer().frame(height: 0)
                    }
                    .padding(24)

                    // Lotes / Unidades
                    LazyVStack(spacing: 20) {
                        if viewModel.units.isEmpty {
                            Text("No hay unidades disponibles")
                                .foregroundColor(.white.opacity(0.5))
                                .padding(24)
                        } else {
                            ForEach(viewModel.units) { unit in
                                UnitCard(
                                    unit: unit,
                                    onProposal: { onNavigateToProposal(unit) },
                                    onAssistant: { onNavigateToAssistant(unit) }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 80) // Espacio para que el último elemento no quede oculto bajo el FAB
                }
            }
        }
    }
}

// MARK: - Componentes Visuales

struct PremiumCompactActionCard: View {
    let title: String
    let icon: String
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .frame(height: 60)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

struct UnitCard: View {
    let unit: PropertyUnit
    let onProposal: () -> Void
    let onAssistant: () -> Void

    var body: some View {
        let statusInfo = getStatusDisplayInfo(status: unit.availability)

        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FRAÇÃO \(unit.id)".uppercased())
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(unit.typology)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                Spacer()
                Text(formatCurrency(unit.price))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }

            HStack(spacing: 24) {
                UnitInfoTag(icon: "ruler.fill", text: "\(formatSqm(unit.sqm)) m²")
                UnitInfoTag(icon: "bed.double.fill", text: "\(unit.bedrooms)")
                UnitInfoTag(icon: "bolt.fill", text: unit.energyCertificate)
                Spacer()
            }

            Spacer().frame(height: 4)

            HStack {
                // Etiqueta de estado
                Text(statusInfo.label.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusInfo.backgroundColor)
                    .foregroundColor(statusInfo.textColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(statusInfo.textColor.opacity(0.2), lineWidth: 1)
                    )

                Spacer()

                // Botones solo si está "Available"
                if unit.availability.lowercased() == "available" {
                    HStack(spacing: 8) {
                        Button(action: onAssistant) {
                            Image(systemName: "sparkles")
                                .frame(width: 44, height: 44)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.45), lineWidth: 1)
                                )
                                .foregroundColor(.white)
                        }

                        Button(action: onProposal) {
                            Text("PROPONER COMPRA")
                                .font(.caption)
                                .fontWeight(.bold)
                                .frame(height: 44)
                                .padding(.horizontal, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(Color(UIColor.darkGray).opacity(0.3)) // Simula el MaterialTheme.colorScheme.surface
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
    }

    // Funciones de formato de la tarjeta
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) €"
    }

    private func formatSqm(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    // Helper de colores y etiquetas
    private func getStatusDisplayInfo(status: String) -> (label: String, textColor: Color, backgroundColor: Color) {
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

struct UnitInfoTag: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .font(.system(size: 14))
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

// Extensión para usar los mismos códigos Hexadecimales de Android
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}