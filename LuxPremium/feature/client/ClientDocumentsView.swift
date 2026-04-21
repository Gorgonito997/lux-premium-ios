import SwiftUI

struct ClientDocumentsView: View {
    let developmentId: String

    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel = ClientDocumentsViewModel()

    var body: some View {
        LuxScreen {
            LuxPanel {
                LuxSectionTitle(
                    "Documentos",
                    eyebrow: "Biblioteca",
                    subtitle: "Listado preparado para adjuntar miniaturas, portadas o iconografia especifica mas adelante."
                )
            }

            if viewModel.isLoading {
                loadingState
            } else if let errorMessage = viewModel.errorMessage {
                errorState(errorMessage)
            } else if viewModel.documents.isEmpty {
                LuxEmptyState(
                    title: "No hay documentos disponibles",
                    subtitle: "Cuando haya documentacion visible la veras aqui con el mismo estilo premium.",
                    systemImage: "doc.text.image"
                )
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.documents) { document in
                        Button {
                            openDocument(document)
                        } label: {
                            documentCard(document)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task(id: developmentId) {
            await viewModel.loadDocuments(developmentId: developmentId)
        }
    }

    private var loadingState: some View {
        LuxPanel {
            VStack(spacing: 16) {
                ProgressView()
                    .tint(LuxTheme.accent)
                    .scaleEffect(1.2)

                Text("Cargando documentos")
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

    private func documentCard(_ document: DevelopmentDocument) -> some View {
        LuxPanel {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.10))

                    Image(systemName: "doc.richtext")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(LuxTheme.accent)
                }
                .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 8) {
                    Text(document.name)
                        .font(.headline)
                        .foregroundStyle(LuxTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(document.category)
                        .font(.subheadline)
                        .foregroundStyle(LuxTheme.textSecondary)

                    Text(document.fileType)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(LuxTheme.accent)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .foregroundStyle(LuxTheme.textSecondary)
            }
        }
    }

    private func openDocument(_ document: DevelopmentDocument) {
        guard let url = URL(string: document.downloadUrl) else {
            return
        }

        openURL(url)
    }
}

#Preview {
    NavigationStack {
        ClientDocumentsView(developmentId: "preview-development")
    }
}
