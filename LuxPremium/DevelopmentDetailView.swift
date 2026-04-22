import Foundation
import SwiftUI

struct DevelopmentDetailView: View {
    let developmentId: String

    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel = DevelopmentDetailViewModel()

    var body: some View {
        LuxScreen {
            VStack(spacing: 24) {
                if viewModel.isLoading {
                    loadingState
                } else if let errorMessage = viewModel.errorMessage {
                    errorState(errorMessage)
                } else {
                    content
                }
            }
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task(id: developmentId) {
            await viewModel.load(developmentId: developmentId)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            hero

            if let development = viewModel.development {
                LuxPanel {
                    HStack(spacing: 12) {
                        LuxValueBadge("Estado: \(translatedAvailability(development.status))")
                        LuxValueBadge("Unidades: \(viewModel.units.count)")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        if !development.location.isEmpty {
                            LuxMetaText(text: development.location)
                        }

                        LuxMetaText(text: "Ficha premium del lote preparada para integrar carruseles, renders e imagenes de avance sin rehacer la estructura.")
                    }
                }
            }

            actions

            LuxSectionTitle(
                "Unidades",
                eyebrow: "Inventario",
                subtitle: "Cada unidad mantiene una presentacion clara y consistente con el acceso principal."
            )

            if viewModel.units.isEmpty {
                LuxEmptyState(
                    title: "No hay unidades disponibles",
                    subtitle: "Cuando se publiquen unidades visibles apareceran aqui con el mismo estilo visual."
                )
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.units) { unit in
                        unitCard(unit)
                    }
                }
            }
        }
    }

    private var hero: some View {
        LuxPanel {
            if let development = viewModel.development {
                LuxSectionTitle(
                    development.name.isEmpty ? "Detalle del lote" : development.name,
                    eyebrow: "Detalle",
                    subtitle: "Vista preparada para portada principal, galeria y recursos multimedia."
                )
            } else {
                LuxSectionTitle(
                    "Detalle del lote",
                    eyebrow: "Detalle",
                    subtitle: "Vista preparada para portada principal, galeria y recursos multimedia."
                )
            }

            LuxImagePlaceholder(
                title: "Imagen principal",
                subtitle: "Aqui podreis conectar la imagen de portada o el render principal de la promocion.",
                height: 210
            )
        }
    }

    private var actions: some View {
        LuxPanel {
            LuxSectionTitle(
                "Recursos",
                eyebrow: "Accesos",
                subtitle: "Documentacion e imagenes externas agrupadas con el mismo lenguaje visual."
            )

            NavigationLink {
                ClientDocumentsView(developmentId: developmentId)
            } label: {
                Text("Ver documentos")
            }
            .buttonStyle(LuxPrimaryButtonStyle())

            if let development = viewModel.development {
                if !development.driveImagesFolderUrl.isEmpty {
                    Button {
                        openUrl(development.driveImagesFolderUrl)
                    } label: {
                        Text("Ver imagenes 3D")
                    }
                    .buttonStyle(LuxSecondaryButtonStyle())
                }

                if !development.driveWorkImagesFolderUrl.isEmpty {
                    Button {
                        openUrl(development.driveWorkImagesFolderUrl)
                    } label: {
                        Text("Ver imagenes de obra")
                    }
                    .buttonStyle(LuxSecondaryButtonStyle())
                }
            }
        }
    }

    private var loadingState: some View {
        LuxPanel {
            VStack(spacing: 16) {
                ProgressView()
                    .tint(LuxTheme.accent)
                    .scaleEffect(1.2)

                Text("Cargando promocion")
                    .font(.headline)
                    .foregroundStyle(LuxTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }
    }

    private func errorState(_ message: String) -> some View {
        LuxPanel {
            VStack(spacing: 14) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(LuxTheme.warning)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(LuxTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func unitCard(_ unit: PropertyUnit) -> some View {
        LuxPanel {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(unit.id)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(LuxTheme.textPrimary)

                        Text(unit.typology)
                            .font(.subheadline)
                            .foregroundStyle(LuxTheme.textSecondary)
                    }

                    Spacer()

                    LuxValueBadge(translatedAvailability(unit.availability), inverted: isAvailable(unit.availability))
                }

                Text(formatPrice(unit.price))
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)

                LuxMetaText(text: "Superficie: \(Int(unit.sqm)) m2")

                LuxMetaText(text: "Dormitorios: \(unit.bedrooms)")

                LuxMetaText(text: "Certificado energetico: \(unit.energyCertificate)")
            }
        }
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
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func translatedAvailability(_ value: String) -> String {
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

    private func isAvailable(_ value: String) -> Bool {
        value.lowercased().contains("available")
    }
}

#Preview {
    NavigationStack {
        DevelopmentDetailView(developmentId: "preview-development")
    }
}
