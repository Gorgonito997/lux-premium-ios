import Foundation
import SwiftUI

struct DevelopmentDetailView: View {
    let developmentId: String

    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel = DevelopmentDetailViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading {
                Spacer()
                ProgressView("Cargando promocion")
                    .frame(maxWidth: .infinity)
                Spacer()
            } else if let errorMessage = viewModel.errorMessage {
                Spacer()
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                content
            }
        }
        .padding()
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: developmentId) {
            await viewModel.load(developmentId: developmentId)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let development = viewModel.development {
                VStack(alignment: .leading, spacing: 8) {
                    Text(development.name)
                        .font(.title)
                        .fontWeight(.semibold)

                    Text(development.location)
                        .foregroundColor(.secondary)

                    Text(development.status)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }

            actions

            Text("Unidades")
                .font(.title2)
                .fontWeight(.semibold)

            if viewModel.units.isEmpty {
                Spacer()
                Text("No hay unidades disponibles.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                List(viewModel.units) { unit in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(unit.id)
                            .font(.headline)

                        Text(unit.typology)
                            .font(.subheadline)

                        Text(formatPrice(unit.price))
                            .font(.title3)
                            .fontWeight(.semibold)

                        HStack(spacing: 12) {
                            Text("\(unit.sqm, specifier: "%.0f") m²")
                            Text("\(unit.bedrooms) hab.")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)

                        Text(availabilityLabel(unit.availability))
                            .font(.caption)
                            .foregroundColor(availabilityColor(unit.availability))

                        Text("Certificado energetico: \(unit.energyCertificate)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(.plain)
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 8) {
            NavigationLink {
                ClientDocumentsView(developmentId: developmentId)
            } label: {
                Text("Ver documentos")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            if let development = viewModel.development {
                if !development.driveImagesFolderUrl.isEmpty {
                    Button {
                        openUrl(development.driveImagesFolderUrl)
                    } label: {
                        Text("Ver imagenes 3D")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                if !development.driveWorkImagesFolderUrl.isEmpty {
                    Button {
                        openUrl(development.driveWorkImagesFolderUrl)
                    } label: {
                        Text("Ver imagenes de obra")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        openURL(url)
    }

    private func formatPrice(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "pt_PT")
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func availabilityLabel(_ value: String) -> String {
        let lower = value.lowercased()

        if lower.contains("available") {
            return "Disponible"
        } else if lower.contains("reserved") {
            return "Reservado"
        } else if lower.contains("sold") {
            return "Vendido"
        }

        return value.capitalized
    }

    private func availabilityColor(_ value: String) -> Color {
        let lower = value.lowercased()

        if lower.contains("available") {
            return .green
        } else if lower.contains("reserved") {
            return .orange
        } else if lower.contains("sold") {
            return .red
        }

        return .gray
    }
}

#Preview {
    NavigationStack {
        DevelopmentDetailView(developmentId: "preview-development")
    }
}
