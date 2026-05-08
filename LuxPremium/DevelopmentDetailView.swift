import Foundation
import SwiftUI

struct DevelopmentDetailView: View {
    let developmentId: String
    let onBack: (() -> Void)?
    let onOpenDocuments: ((String) -> Void)?
    let onOpenContracts: ((String) -> Void)?
    let onOpenProposal: ((String) -> Void)?

    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel: DevelopmentDetailViewModel

    init(
        developmentId: String,
        onBack: (() -> Void)? = nil,
        onOpenDocuments: ((String) -> Void)? = nil,
        onOpenContracts: ((String) -> Void)? = nil,
        onOpenProposal: ((String) -> Void)? = nil
    ) {
        self.developmentId = developmentId
        self.onBack = onBack
        self.onOpenDocuments = onOpenDocuments
        self.onOpenContracts = onOpenContracts
        self.onOpenProposal = onOpenProposal
        _viewModel = StateObject(wrappedValue: DevelopmentDetailViewModel())
    }

    var body: some View {
        LuxScreen {
            VStack(spacing: 24) {
                if viewModel.isLoading {
                    loadingState
                } else if viewModel.development == nil, let errorMessage = viewModel.errorMessage {
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
        .toolbar {
            if let onBack {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Lotes")
                        }
                    }
                    .foregroundStyle(LuxTheme.textPrimary)
                }
            }
        }
        .task(id: developmentId) {
            await viewModel.load(developmentId: developmentId)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let errorMessage = viewModel.errorMessage, viewModel.development != nil {
                inlineWarning(errorMessage)
            }

            hero

            if let development = viewModel.development {
                LuxPanel {
                    HStack(spacing: 12) {
                        LuxValueBadge("Estado: \(translatedAvailability(development.status))")
                        LuxValueBadge("Unidades: \(viewModel.units.count)")
                        LuxValueBadge("Docs: \(viewModel.documents.count)")
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
            documentsSection

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

            if let development = viewModel.development {
                Image(DevelopmentImageMapper.mapIdToDrawable(development.id))
                    .resizable()
                    .scaledToFill()
                    .frame(height: 210)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                LuxImagePlaceholder(
                    title: "Imagen principal",
                    subtitle: "Aqui podreis conectar la imagen de portada o el render principal de la promocion.",
                    height: 210
                )
            }
        }
    }

    private var actions: some View {
        LuxPanel {
            LuxSectionTitle(
                isBrokerMode ? "Acciones broker" : "Recursos",
                eyebrow: "Accesos",
                subtitle: isBrokerMode
                    ? "Accesos preparados para documentos, contratos y propuesta sin bloquear el flujo actual."
                    : "Documentacion e imagenes externas agrupadas con el mismo lenguaje visual."
            )

            if let onOpenDocuments {
                Button {
                    onOpenDocuments(developmentId)
                } label: {
                    Text("Documentos")
                }
                .buttonStyle(LuxPrimaryButtonStyle())
            } else {
                NavigationLink {
                    ClientDocumentsScreen(developmentId: developmentId)
                } label: {
                    Text("Ver documentos")
                }
                .buttonStyle(LuxPrimaryButtonStyle())
            }

            if let onOpenContracts {
                Button {
                    onOpenContracts(developmentId)
                } label: {
                    Text("Contracts")
                }
                .buttonStyle(LuxSecondaryButtonStyle())
            }

            if let onOpenProposal {
                Button {
                    onOpenProposal(developmentId)
                } label: {
                    Text("Proposal")
                }
                .buttonStyle(LuxSecondaryButtonStyle())
            }

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

    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            LuxSectionTitle(
                "Documentacion",
                eyebrow: "Soporte",
                subtitle: "Resumen de documentos visibles ya cargados para este development."
            )

            if viewModel.documents.isEmpty {
                LuxEmptyState(
                    title: "No hay documentos visibles",
                    subtitle: "El detail sigue operativo y quedara listo para conectar el bloque final de documentos."
                )
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.documents) { document in
                        documentCard(document)
                    }
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

    private func inlineWarning(_ message: String) -> some View {
        LuxPanel {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(LuxTheme.warning)

                    Text("Parte del contenido no se ha podido cargar")
                        .font(.headline)
                        .foregroundStyle(LuxTheme.textPrimary)
                }

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(LuxTheme.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

    private func documentCard(_ document: DevelopmentDocument) -> some View {
        LuxPanel {
            VStack(alignment: .leading, spacing: 8) {
                Text(document.name.isEmpty ? document.id : document.name)
                    .font(.headline)
                    .foregroundStyle(LuxTheme.textPrimary)
                    .multilineTextAlignment(.leading)

                if !document.category.isEmpty {
                    LuxMetaText(text: document.category)
                }

                LuxValueBadge(document.fileType.isEmpty ? "Documento" : document.fileType)
            }
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

    private var isBrokerMode: Bool {
        onOpenDocuments != nil || onOpenContracts != nil || onOpenProposal != nil || onBack != nil
    }
}

#Preview {
    NavigationStack {
        DevelopmentDetailView(developmentId: "preview-development")
    }
}
