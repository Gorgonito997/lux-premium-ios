import SwiftUI

struct ClientDocumentsView: View {
    let developmentId: String

    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel = ClientDocumentsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading {
                Spacer()
                ProgressView("Cargando documentos")
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
            } else if viewModel.documents.isEmpty {
                Spacer()
                Text("No hay documentos disponibles.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                List(viewModel.documents) { document in
                    Button {
                        openDocument(document)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(document.name)
                                .font(.headline)

                            Text(document.category)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(document.fileType)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .navigationTitle("Documentos")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: developmentId) {
            await viewModel.loadDocuments(developmentId: developmentId)
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
