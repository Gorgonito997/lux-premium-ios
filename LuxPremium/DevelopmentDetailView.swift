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
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(development.location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(development.status)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
                    VStack(alignment: .leading, spacing: 6) {
                        Text(unit.typology)
                            .font(.headline)

                        Text(priceText(unit.price))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Superficie: \(unit.sqm, specifier: "%.2f") m2")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Dormitorios: \(unit.bedrooms)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text(availabilityText(unit.availability))
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Certificado energetico: \(unit.energyCertificate)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
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
    }

    private func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        openURL(url)
    }

    private func priceText(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? "\(price)"
        return "Precio: \(formattedPrice) EUR"
    }

    private func availabilityText(_ availability: String) -> String {
        let value = availability.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? "Disponibilidad: No indicada" : "Disponibilidad: \(value)"
    }
}

#Preview {
    NavigationStack {
        DevelopmentDetailView(developmentId: "preview-development")
    }
}
